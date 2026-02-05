// transcript_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aimateflutter/services/database.dart';
import 'package:aimateflutter/services/repository.dart';
import 'package:aimateflutter/models/transcript.dart';

enum TranscriptState { loading, none, processing, done, failed }

class TranscriptViewModel extends ChangeNotifier {
  final String? id;
  final DatabaseService _db = DatabaseService();

  TranscriptState _state = TranscriptState.loading; // initial state is loading
  List<TranscriptItem> _transcriptItems = [];
  String _errorMessage = '';
  bool _isPolling = false;
  Timer? _pollingTimer;

  TranscriptState get state => _state;
  List<TranscriptItem> get transcriptItems => _transcriptItems;
  String get errorMessage => _errorMessage;
  bool get isPolling => _isPolling;

  TranscriptViewModel({this.id}) {
    _checkStatus();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _isPolling = false;
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (id == null) return;

    try {
      final detail = await Repository.getMeetingbyId(id!);

      switch (detail.meeting.transcriptStatus) {
        case 'DONE' when detail.transcripts.isNotEmpty:
          // reset
          _transcriptItems = detail.transcripts;
          _state = TranscriptState.done;
          notifyListeners();
          return;
        case 'PROCESSING':
          _state = TranscriptState.processing;
          _isPolling = true;
          notifyListeners();
          _startPolling();
          return;
        case 'FAILED':
          _state = TranscriptState.failed;
          _errorMessage = 'Transcription previously failed.';
          notifyListeners();
          return;
        case 'NONE':
          _state = TranscriptState.none;
          notifyListeners();
          return;
      }
    } catch (e) {
      _state = TranscriptState.failed;
      _errorMessage = 'Error checking transcript status: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> startTranscription() async {
    if (id == null) return;

    _state = TranscriptState.processing;
    _isPolling = true;
    notifyListeners();

    try {
      await _db.updateRecordingStatus(meetingId: id!, status: 'processing');

      final detail = await Repository.getMeetingbyId(id!);
      if (detail.meeting.transcriptStatus == 'NONE') {
        final savedRecording = await _db.getRecording(id!);
        if (savedRecording == null) {
          throw Exception('Recording not found in database');
        }

        final presigned = await Repository.getPresignedUrl(
          id!,
          savedRecording.title,
          savedRecording.duration,
        );

        await Repository.uploadAudioToServer(
          presigned.url,
          savedRecording.filePath,
        );

        await Repository.confirm(presigned.audioId);
      }

      _startPolling();
    } catch (e) {
      _isPolling = false;
      _state = TranscriptState.failed;
      _errorMessage = 'Unable to create transcript: ${e.toString()}';
      notifyListeners();
      await _db.updateRecordingStatus(meetingId: id!, status: 'failed');
    }
  }

  void _startPolling() {
    if (!_isPolling) return;

    _pollingTimer?.cancel();
    // intervel 5 second each polling
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isPolling) {
        timer.cancel();
        return;
      }

      try {
        final statusResponse = await Repository.transcriptStatus(id!);

        if (statusResponse == 'DONE') {
          final detail = await Repository.getMeetingbyId(id!);
          await _db.updateRecordingStatus(meetingId: id!, status: 'done');
          // await _db.updateTranscriptActivation(
          //   meetingId: id!,
          //   isActivated: true,
          // );

          _transcriptItems = detail.transcripts;
          _state = TranscriptState.done;
          _isPolling = false;
          notifyListeners();
          timer.cancel();
        } else if (statusResponse == 'FAILED') {
          await _db.updateRecordingStatus(meetingId: id!, status: 'failed');
          _state = TranscriptState.failed;
          _errorMessage = 'Transcription failed. Please try again.';
          _isPolling = false;
          notifyListeners();
          timer.cancel();
        }
      } catch (e) {
        debugPrint('Error polling transcript: $e');
      }
    });
  }
}
