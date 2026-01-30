import 'package:flutter/material.dart';
import '../../../services/repository.dart';
import '../../../models/meeting.dart';

class CreateRecordViewModel with ChangeNotifier {
  final TextEditingController _titleController = TextEditingController();
  bool _isSubmitting = false;
  MeetingResponse? _createdMeeting;

  // Getters
  TextEditingController get titleController => _titleController;
  bool get isSubmitting => _isSubmitting;
  MeetingResponse? get createdMeeting => _createdMeeting;
  bool get canSubmit => _titleController.text.trim().isNotEmpty;

  // Validation
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }

  // Create meeting
  Future<MeetingResponse?> createMeeting() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      return null;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final meeting = await Repository.createMeeting(title);
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
    _titleController.clear();
    _isSubmitting = false;
    _createdMeeting = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
