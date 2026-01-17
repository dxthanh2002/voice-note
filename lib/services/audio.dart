import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum RecordingState { idle, recording, paused, stopped }

class AudioService {
  RecorderController? _recorderController;

  RecorderController get recorderController {
    _recorderController ??= RecorderController();
    return _recorderController!;
  }

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

  void _initRecorder() {
    _recorderController ??= RecorderController();
  }

  RecorderSettings _getRecorderSettings() {
    return const RecorderSettings(
      androidEncoderSettings: AndroidEncoderSettings(
        androidEncoder: AndroidEncoder.aacLc,
      ),
      iosEncoderSettings: IosEncoderSetting(
        iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
      ),
      sampleRate: 44100,
      bitRate: 128000,
    );
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
      _initRecorder();

      // Request all permissions
      final granted = await requestPermissions();
      if (!granted) {
        debugPrint('Permissions not granted');
        return false;
      }

      // Check permission using RecorderController
      final hasRecordPermission = await _recorderController!.checkPermission();
      if (!hasRecordPermission) {
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

      // Start recording
      await _recorderController!.record(
        path: _currentFilePath,
        recorderSettings: _getRecorderSettings(),
      );

      _state = RecordingState.recording;
      _recordedDuration = Duration.zero;
      _stateController.add(_state);

      // Start duration timer
      _startDurationTimer();

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
      await _recorderController!.pause();
      _state = RecordingState.paused;
      _stateController.add(_state);
      _stopDurationTimer();
    } catch (e) {
      debugPrint('Error pausing recording: $e');
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    if (_state != RecordingState.paused) return;

    try {
      await _recorderController!.record();
      _state = RecordingState.recording;
      _stateController.add(_state);
      _startDurationTimer();
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
      // If paused, resume first before stopping (audio_waveforms bug workaround)
      if (_state == RecordingState.paused) {
        await _recorderController!.record();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      await _recorderController!.stop();
      _state = RecordingState.stopped;
      _stateController.add(_state);
      _stopDurationTimer();

      debugPrint('Recording stopped. File saved to: $_currentFilePath');

      // Verify file exists
      if (_currentFilePath != null) {
        final file = File(_currentFilePath!);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        debugPrint('File exists: $exists, size: $size bytes');
      }

      return _currentFilePath;
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
      await _recorderController!.stop();
      _recorderController!.reset();

      // Delete the file if it exists
      if (_currentFilePath != null) {
        final file = File(_currentFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

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

  /// Dispose resources
  void dispose() {
    _durationTimer?.cancel();
    _durationController.close();
    _stateController.close();
    _recorderController?.dispose();
  }
}
