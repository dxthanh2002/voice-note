import 'package:flutter/material.dart';
import '../../../services/repository.dart';
import '../../../models/meeting.dart';

class CreateRecordViewModel with ChangeNotifier {
  static const String defaultTitle = 'New Meeting';
  
  bool _isSubmitting = false;
  MeetingResponse? _createdMeeting;

  // Getters
  bool get isSubmitting => _isSubmitting;
  MeetingResponse? get createdMeeting => _createdMeeting;

  // Create meeting with default title
  Future<MeetingResponse?> createMeeting() async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final meeting = await Repository.createMeeting(defaultTitle);
      _createdMeeting = meeting;
      return meeting;
    } catch (e) {
      debugPrint('Error creating meeting: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Reset state
  void reset() {
    _isSubmitting = false;
    _createdMeeting = null;
    notifyListeners();
  }
}
