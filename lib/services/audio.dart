import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum RecordingState { idle, recording, paused, stopped }

class AudioService {
  late final RecorderController _recorderController;
  RecordingState _state = RecordingState.idle;
  String? _currentFilePath;
  Duration _recordedDuration = Duration.zero;
  
  Timer? _durationTimer;
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  final StreamController<RecordingState> _stateController = StreamController<RecordingState>.broadcast();
  
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<RecordingState> get stateStream => _stateController.stream;
  RecordingState get state => _state;
  String? get currentFilePath => _currentFilePath;
  Duration get recordedDuration => _recordedDuration;

  AudioService() {
    _initController();
  }

  void _initController() {
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aacLc
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..bitRate = 128000;
  }

  Future<bool> _requestPermissions() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return false;

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        await Permission.audio.request();
      } else if (deviceInfo.version.sdkInt < 29) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) return false;
      }
    }
    
    return true;
  }

  Future<String> _getRecordingsDirectory() async {
    if (Platform.isAndroid) {
      try {
        final dir = await getExternalStorageDirectory();
        if (dir != null) {
          final basePath = dir.path.split('/Android/data').first;
          final recordingsDir = p.join(basePath, 'Recordings', 'Recapit');
          await Directory(recordingsDir).create(recursive: true);
          return recordingsDir;
        }
      } catch (e) {
        debugPrint('Error getting external storage: $e');
      }
    }
    
    final dir = await getApplicationDocumentsDirectory();
    final recordingsDir = p.join(dir.path, 'Recordings');
    await Directory(recordingsDir).create(recursive: true);
    return recordingsDir;
  }

  Future<bool> startRecording() async {
    try {
      if (_state == RecordingState.recording) return false;
      
      // Clean up any previous recording
      if (_state != RecordingState.idle) {
        await _cleanup();
      }

      // Check permissions
      if (!await _requestPermissions()) {
        debugPrint('Microphone permission denied');
        return false;
      }

      // Get directory and create file path
      final recordingsDir = await _getRecordingsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentFilePath = p.join(recordingsDir, 'recording_$timestamp.m4a');

      // Start recording
      await _recorderController.record(path: _currentFilePath);
      
      _state = RecordingState.recording;
      _recordedDuration = Duration.zero;
      _stateController.add(_state);
      
      // Start duration timer
      _durationTimer?.cancel();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordedDuration += const Duration(seconds: 1);
        _durationController.add(_recordedDuration);
      });

      debugPrint('Recording started to: $_currentFilePath');
      return true;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return false;
    }
  }

  Future<void> pauseRecording() async {
    if (_state != RecordingState.recording) return;
    
    try {
      await _recorderController.pause();
      _state = RecordingState.paused;
      _stateController.add(_state);
      _durationTimer?.cancel();
      _durationTimer = null;
    } catch (e) {
      debugPrint('Error pausing recording: $e');
    }
  }

  Future<void> resumeRecording() async {
    if (_state != RecordingState.paused) return;
    
    try {
      await _recorderController.record();
      _state = RecordingState.recording;
      _stateController.add(_state);
      
      _durationTimer?.cancel();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordedDuration += const Duration(seconds: 1);
        _durationController.add(_recordedDuration);
      });
    } catch (e) {
      debugPrint('Error resuming recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    if (_state == RecordingState.idle) return null;
    
    try {
      // Stop the controller
      await _recorderController.stop();
      
      // Update state
      _state = RecordingState.stopped;
      _stateController.add(_state);
      
      // Clean up timer
      _durationTimer?.cancel();
      _durationTimer = null;
      
      // Small delay to ensure file is written
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Verify file exists
      if (_currentFilePath != null) {
        final file = File(_currentFilePath!);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        
        debugPrint('Recording stopped. File exists: $exists, size: $size bytes');
        
        if (exists && size > 0) {
          return _currentFilePath;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      // Force cleanup on error
      await _cleanup();
      return null;
    } finally {
      // Always reset to idle after stopping
      _state = RecordingState.idle;
    }
  }

  Future<void> cancelRecording() async {
    try {
      // Stop recording if active
      if (_state == RecordingState.recording || _state == RecordingState.paused) {
        await _recorderController.stop();
      }
      
      // Delete the file if it exists
      if (_currentFilePath != null) {
        final file = File(_currentFilePath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted recording file: $_currentFilePath');
        }
      }
      
      await _cleanup();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  Future<void> _cleanup() async {
    _durationTimer?.cancel();
    _durationTimer = null;
    _recordedDuration = Duration.zero;
    _currentFilePath = null;
    _state = RecordingState.idle;
    _stateController.add(_state);
    _durationController.add(Duration.zero);
  }

  void dispose() {
    _durationTimer?.cancel();
    _durationController.close();
    _stateController.close();
    _recorderController.dispose();
  }
}
