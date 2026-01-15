import 'package:flutter/foundation.dart';
import '../models/meeting.dart';
import 'repository.dart';

class MeetingService extends ChangeNotifier {
  List<MeetingResponse> _meetings = [];
  bool _isLoading = false;

  List<MeetingResponse> get meetings => List.unmodifiable(_meetings);
  bool get isLoading => _isLoading;

  Future<void> loadMeetings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await Repository.getMeetings();

      _meetings = data..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    } catch (e, stack) {
      debugPrint('Load meetings failed: $e');
      debugPrintStack(stackTrace: stack);
      _meetings = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  MeetingResponse? getById(String id) {
    for (final meeting in _meetings) {
      if (meeting.id == id) return meeting;
    }
    return null;
  }
}
