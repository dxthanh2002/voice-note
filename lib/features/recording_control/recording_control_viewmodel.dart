import 'dart:async';
import 'package:flutter/material.dart';

import '../../../services/database.dart';
import '../../../services/audio.dart';
import '../../../utils/console.dart';

enum RecordingScreenState { loading, initial, recording, paused }

class RecordingViewModel with ChangeNotifier {
  RecordingScreenState _state = RecordingScreenState.loading;
  AudioService? _audioService;
  Duration _duration = Duration.zero;
  List<double> _waveHeights = [];
  double _smoothedAmp = 0.0;
  StreamSubscription<double>? _ampSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<RecordingState>? _stateSubscription;

  RecordingViewModel() {
    _waveHeights = List.generate(18, (_) => 0.1);
  }

  // Getters
  RecordingScreenState get state => _state;
  Duration get duration => _duration;
  List<double> get waveHeights => _waveHeights;
  bool get isRecording => _state == RecordingScreenState.recording;
  bool get isPaused => _state == RecordingScreenState.paused;
  bool get isLoading => _state == RecordingScreenState.loading;
  bool get isRecordingOrPaused => isRecording || isPaused;

  // Initialization
  Future<void> initializeRecording() async {
    _updateState(RecordingScreenState.initial);
    await startRecording();
  }

  Future<bool> startRecording() async {
    _audioService = AudioService();

    // Listen to duration updates
    _durationSubscription = _audioService!.durationStream.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    // Listen to recording state changes
    _stateSubscription = _audioService!.stateStream.listen((state) {
      if (state == RecordingState.recording) {
        _updateState(RecordingScreenState.recording);
        _startAmplitudeListening();
      } else if (state == RecordingState.paused) {
        _updateState(RecordingScreenState.paused);
        _ampSubscription?.cancel();
      }
    });

    final success = await _audioService!.startRecording();
    if (!success) {
      return false;
    }

    return true;
  }

  void _updateState(RecordingScreenState newState) {
    _state = newState;
    notifyListeners();
  }

  void _startAmplitudeListening() {
    _ampSubscription?.cancel();
    _ampSubscription = _audioService!.amplitudeStream.listen((amp) {
      if (_state != RecordingScreenState.recording) return;

      // Exponential smoothing
      _smoothedAmp = 0.3 * amp + 0.7 * _smoothedAmp;

      // Gate noise floor - lowered to 0.02 for better sensitivity
      final value = _smoothedAmp < 0.02 ? 0.1 : _smoothedAmp;

      _waveHeights.removeAt(0);
      _waveHeights.add(value);
      notifyListeners();
    });
  }

  Future<void> togglePause() async {
    await _audioService?.togglePause();
  }

  Future<void> stopRecording({
    required String title,
    required String meetingId,
  }) async {
    if (_audioService == null) return;

    final filePath = await _audioService!.stopRecording();

    if (filePath == null) {
      Console.log('No file path returned from recording');
      return;
    }

    // final fileName = p.basename(filePath);
    final duration = _audioService!.recordedDuration.inSeconds;
    Console.log('Recording saved: $filePath');

    try {
      // save to local
      await DatabaseService().save(
        meetingId: meetingId,
        title: title,
        filePath: filePath,
        duration: duration,
        status: 'raw',
      );

      final data = await DatabaseService().getRecording(meetingId);

      Console.log("CHECKING NEW SAVE RECORD");
      Console.log(data?.meetingId);
      Console.log(data?.title);
      Console.log(data?.filePath);
      Console.log(data?.duration);
      //
    } catch (e) {
      debugPrint('Error creating meeting in LOCAL DATABASE: $e');
      rethrow;
    }
  }

  void updateDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }

  void disposeResources() {
    _ampSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    _audioService?.dispose();
  }

  @override
  void dispose() {
    disposeResources();
    super.dispose();
  }
}
