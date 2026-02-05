import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aimateflutter/services/database.dart';
import 'package:aimateflutter/services/repository.dart';

enum SummaryState { loading, none, processing, done, error }

class SummaryViewModel extends ChangeNotifier {
  final String? id;

  SummaryViewModel({this.id}) {
    _checkStatus();
  }

  final DatabaseService _db = DatabaseService();

  SummaryState _state = SummaryState.loading;
  String? _summaryContent;
  String? _errorMessage;

  SummaryState get state => _state;
  String? get summaryContent => _summaryContent;
  String? get errorMessage => _errorMessage;

  Future<void> _checkStatus() async {
    if (id == null) {
      _state = SummaryState.none;
      notifyListeners();
      return;
    }

    try {
      final recording = await _db.getRecording(id!);
      final isActivated = recording?.isSummaryActivated ?? false;

      if (!isActivated) {
        _state = SummaryState.none;
        notifyListeners();
        return;
      }

      final statusResponse = await Repository.getStatusSummary(id!);

      if (statusResponse.summaryStatus == 'DONE') {
        final summaryResponse = await Repository.getSummary(id!);
        _summaryContent = summaryResponse.content;
        _state = SummaryState.done;
        notifyListeners();
      } else if (statusResponse.summaryStatus == 'ERROR') {
        _state = SummaryState.error;
        _errorMessage = 'Summary generation ERROR.';
        notifyListeners();
      } else {
        // still processing
        _state = SummaryState.processing;
        await Future.delayed(const Duration(seconds: 2));
        notifyListeners();
        getSummary();
      }
    } catch (e) {
      _state = SummaryState.error;
      _errorMessage = 'Error checking summary status: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> getSummary() async {
    if (id == null) return;

    final recording = await _db.getRecording(id!);
    if (recording?.status != 'done') {
      throw Exception('Please generate transcript before creating a summary');
    }

    await _db.updateSummaryActivation(meetingId: id!, isActivated: true);

    final summaryResponse = await Repository.getSummary(id!);

    _summaryContent = summaryResponse.content;
    _state = SummaryState.done;
    notifyListeners();
  }
}
