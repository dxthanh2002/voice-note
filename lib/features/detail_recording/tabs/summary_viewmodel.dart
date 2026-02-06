import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aimateflutter/services/database.dart';
import 'package:aimateflutter/services/repository.dart';

import '../../../services/ads/rewarder_sdk.dart';

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
        getSummary();
      }
    } catch (e) {
      _state = SummaryState.error;
      _errorMessage = 'Error checking summary status: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> hasTranscript() async {
    if (id == null) return false;
    final recording = await _db.getRecording(id!);
    return recording?.status == 'done';
  }

  Future<void> getSummary() async {
    if (id == null) return;

    // load ads
    RewarderManager.startShowAutoLoadRewardedVideoAd();
    await Future.delayed(const Duration(seconds: 1));

    // change state UI
    _state = SummaryState.processing;
    notifyListeners();

    final summaryResponse = await Repository.getSummary(id!);
    _summaryContent = summaryResponse.content;
    _state = SummaryState.done;

    await _db.updateSummaryActivation(meetingId: id!, isActivated: true);

    await Future.delayed(const Duration(seconds: 3));
    notifyListeners();
  }
}
