import 'dart:async';
import 'package:flutter/material.dart';

class _ProcessInfo {
  Timer? timer;
  VoidCallback? onSuccess;
  VoidCallback? onError;
  bool isRunning = false;
}

class ProcessingService {
  // Singleton pattern
  static final ProcessingService _instance = ProcessingService._internal();
  factory ProcessingService() => _instance;
  ProcessingService._internal();

  // Store ongoing processes
  final Map<String, _ProcessInfo> _processes = {};

  // Start or resume processing for a meeting
  void startPolling({
    required String meetingId,
    required Future<bool> Function() checkFunction,
    required VoidCallback onSuccess,
    required VoidCallback onError,
    Duration interval = const Duration(seconds: 5),
  }) {
    // Cancel existing if any
    stopPolling(meetingId);

    final info = _ProcessInfo()
      ..onSuccess = onSuccess
      ..onError = onError
      ..isRunning = true;

    _processes[meetingId] = info;

    // Start polling
    info.timer = Timer.periodic(interval, (_) async {
      try {
        final isDone = await checkFunction();
        if (isDone) {
          stopPolling(meetingId);
          onSuccess();
        }
      } catch (e) {
        stopPolling(meetingId);
        onError();
      }
    });
  }

  // Stop polling for a specific meeting
  void stopPolling(String meetingId) {
    final info = _processes[meetingId];
    info?.timer?.cancel();
    _processes.remove(meetingId);
  }

  // Check if a meeting is being processed
  bool isProcessing(String meetingId) {
    return _processes.containsKey(meetingId) &&
        _processes[meetingId]!.isRunning;
  }

  // Clean up all
  void dispose() {
    for (final info in _processes.values) {
      info.timer?.cancel();
    }
    _processes.clear();
  }
}
