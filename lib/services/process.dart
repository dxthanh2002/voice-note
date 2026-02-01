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

  // Store listeners for each meeting
  final Map<String, List<VoidCallback>> _listeners = {};

  // Add listener for processing status changes
  void addListener(String meetingId, VoidCallback listener) {
    _listeners.putIfAbsent(meetingId, () => []);
    if (!_listeners[meetingId]!.contains(listener)) {
      _listeners[meetingId]!.add(listener);
    }
  }

  // Remove listener
  void removeListener(String meetingId, VoidCallback listener) {
    _listeners[meetingId]?.remove(listener);
  }

  // Notify all listeners for a meeting
  void _notifyListeners(String meetingId) {
    _listeners[meetingId]?.forEach((listener) {
      try {
        listener();
      } catch (e) {
        debugPrint('Error in processing listener: $e');
      }
    });
  }

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

    // Notify listeners that processing started
    _notifyListeners(meetingId);

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

    // Notify listeners that processing stopped
    _notifyListeners(meetingId);
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
    _listeners.clear();
  }
}
