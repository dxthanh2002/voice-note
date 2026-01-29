import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

enum RecordingState { idle, recording, paused, stopped }

class AudioService {
  AudioRecorder? _recorder;

  RecordingState _state = RecordingState.idle;
  RecordingState get state => _state;

  String? _currentFilePath;
  String? get currentFilePath => _currentFilePath;

  Duration _recordedDuration = Duration.zero;
  Duration get recordedDuration => _recordedDuration;

  Timer? _durationTimer;
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  Stream<Duration> get durationStream => _durationController.stream;

  final StreamController<RecordingState> _stateController =
      StreamController<RecordingState>.broadcast();
  Stream<RecordingState> get stateStream => _stateController.stream;

  // Amplitude metering for real-time waveform
  StreamSubscription<Amplitude>? _ampSubscription;
  final StreamController<double> _ampController =
      StreamController<double>.broadcast();
  Stream<double> get amplitudeStream => _ampController.stream;
  static const _ampInterval = Duration(milliseconds: 50);

  Future<void> _initRecorder() async {
    if (_recorder == null) {
      _recorder = AudioRecorder();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Get the recordings directory path
  /// Path: /storage/emulated/0/Recordings/Recapit/
  static Future<String> getRecordingsDirectory() async {
    if (Platform.isAndroid) {
      // Try to get public Recordings directory
      final dirs = await getExternalStorageDirectories(
        type: StorageDirectory.music,
      );

      if (dirs != null && dirs.isNotEmpty) {
        // dirs.first is like /storage/emulated/0/Android/data/[package]/files/Music
        // We need to get /storage/emulated/0/Recordings/Recapit
        final basePath = dirs.first.path.split('/Android/data').first;
        final recordingsDir = p.join(basePath, 'Recordings', 'Recapit');

        debugPrint('Creating recordings directory: $recordingsDir');

        final dir = Directory(recordingsDir);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return recordingsDir;
      }

      // Fallback: use external storage directory
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final basePath = extDir.path.split('/Android/data').first;
        final recordingsDir = p.join(basePath, 'Recordings', 'Recapit');

        final dir = Directory(recordingsDir);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return recordingsDir;
      }
    }

    // iOS or final fallback
    final directory = await getApplicationDocumentsDirectory();
    final recordingsDir = p.join(directory.path, 'Recordings');
    final dir = Directory(recordingsDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return recordingsDir;
  }

  /// Request all required permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      debugPrint('Android SDK: $sdkInt');

      // Request microphone permission
      final micStatus = await Permission.microphone.request();
      debugPrint('Microphone permission: $micStatus');
      if (!micStatus.isGranted) {
        debugPrint('Microphone permission denied');
        return false;
      }

      // Android 13+ (API 33+): Request READ_MEDIA_AUDIO
      if (sdkInt >= 33) {
        final audioStatus = await Permission.audio.request();
        debugPrint('Audio permission (Android 13+): $audioStatus');
        // Not strictly required for recording, but good to have
      }
      // Android < 10 (API 29): Request storage permission
      else if (sdkInt < 29) {
        final storageStatus = await Permission.storage.request();
        debugPrint('Storage permission (Android < 10): $storageStatus');
        if (!storageStatus.isGranted) {
          debugPrint('Storage permission denied');
          return false;
        }
      }

      return true;
    }

    // iOS
    final micStatus = await Permission.microphone.request();
    return micStatus.isGranted;
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Start recording
  Future<bool> startRecording() async {
    try {
      await _initRecorder();
      // Request all permissions
      final granted = await requestPermissions();
      if (!granted) {
        debugPrint('Permissions not granted');
        return false;
      }

      // Check if device supports recording
      if (!await _recorder!.hasPermission()) {
        debugPrint('Recorder does not have permission');
        return false;
      }

      // Get recordings directory
      final recordingsDir = await getRecordingsDirectory();
      debugPrint('Recordings directory: $recordingsDir');

      // Generate file path with M4A extension
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentFilePath = p.join(recordingsDir, 'recording_$timestamp.m4a');
      debugPrint('Recording to: $_currentFilePath');

      // Configure recording - AAC encoder for M4A format
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
        numChannels: 1,
      );

      // Start recording
      await _recorder!.start(config, path: _currentFilePath!);

      _state = RecordingState.recording;
      _recordedDuration = Duration.zero;
      _stateController.add(_state);

      // Start duration timer
      _startDurationTimer();

      // Start amplitude metering for waveform
      _startAmplitudeMetering();

      debugPrint('Recording started successfully');
      return true;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return false;
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    if (_state != RecordingState.recording) return;

    try {
      await _recorder!.pause();
      _state = RecordingState.paused;
      _stateController.add(_state);
      _stopDurationTimer();
      _stopAmplitudeMetering();
    } catch (e) {
      debugPrint('Error pausing recording: $e');
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    if (_state != RecordingState.paused) return;

    try {
      await _recorder!.resume();
      _state = RecordingState.recording;
      _stateController.add(_state);
      _startDurationTimer();
      _startAmplitudeMetering();
    } catch (e) {
      debugPrint('Error resuming recording: $e');
    }
  }

  /// Stop recording and save file
  Future<String?> stopRecording() async {
    if (_state == RecordingState.idle || _state == RecordingState.stopped) {
      return null;
    }

    try {
      final path = await _recorder!.stop();
      _state = RecordingState.stopped;
      _stateController.add(_state);
      _stopDurationTimer();
      _stopAmplitudeMetering();

      debugPrint('Recording stopped. File saved to: $path');

      // Verify file exists
      if (path != null) {
        final file = File(path);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        debugPrint('File exists: $exists, size: $size bytes');
      }

      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final exists = await file.exists();
      return exists ? await file.length() : 0;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  /// Cancel recording and delete file
  Future<void> cancelRecording() async {
    try {
      await _recorder!.stop();
      await _recorder!.cancel();
      _state = RecordingState.idle;
      _stateController.add(_state);
      _stopDurationTimer();
      _recordedDuration = Duration.zero;
      _currentFilePath = null;
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  /// Toggle pause/resume
  Future<void> togglePause() async {
    if (_state == RecordingState.recording) {
      await pauseRecording();
    } else if (_state == RecordingState.paused) {
      await resumeRecording();
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordedDuration += const Duration(seconds: 1);
      _durationController.add(_recordedDuration);
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void _startAmplitudeMetering() {
    _ampSubscription?.cancel();
    _ampSubscription = _recorder!.onAmplitudeChanged(_ampInterval).listen((
      amp,
    ) {
      final normalized = _dbToNormalized(amp.current);
      _ampController.add(normalized);
    });
  }

  void _stopAmplitudeMetering() {
    _ampSubscription?.cancel();
    _ampSubscription = null;
  }

  /// Convert dBFS [-60..0] to normalized [0..1]
  double _dbToNormalized(double db) {
    const minDb = -60.0;
    final clamped = db.clamp(minDb, 0.0);
    return (clamped - minDb) / (0.0 - minDb);
  }

  /// Dispose resources
  void dispose() {
    _durationTimer?.cancel();
    _ampSubscription?.cancel();
    _ampController.close();

    _durationController.close();
    _stateController.close();
    _recorder!.dispose();
  }
}
