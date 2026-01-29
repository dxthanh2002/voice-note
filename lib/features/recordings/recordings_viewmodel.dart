import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/dialogs/delete_dialog.dart';
import '../../components/dialogs/rename_dialog.dart';
import '../../models/meeting.dart';
import '../../navigation/routes.dart';
import '../../services/repository.dart';

class RecordingsViewModel extends ChangeNotifier {
  // State
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;
  List<MeetingResponse> _recordings = [];

  bool _isLoading = false;
  String _searchTitle = '';

  Timer? _debounce;

  // ============ Getters ============
  bool get isSearchExpanded => _isSearchExpanded;
  bool get isLoading => _isLoading;
  List<MeetingResponse> get recordings => List.unmodifiable(_recordings);

  RecordingsViewModel() {
    _setupSearchListeners();
  }

  // ============ Setup ============
  void _setupSearchListeners() {
    searchController.addListener(() {
      // Optional: Add any search controller listeners if needed
    });
  }

  Future<void> _loadRecordings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await Repository.getMeetings(_searchTitle);
      _recordings = data..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    } catch (e) {
      _recordings = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============ Dispose ============
  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ============ Recording Management ============
  Future<void> loadRecordings() async {
    _setLoading(true);
    _loadRecordings();
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ============ Search Functionality ============
  void expandSearch() {
    HapticFeedback.selectionClick();
    _isSearchExpanded = true;
    notifyListeners();

    // Delay focus request for smooth animation
    Future.delayed(const Duration(milliseconds: 300), () {
      searchFocusNode.requestFocus();
    });
  }

  void closeSearch() {
    _isSearchExpanded = false;
    searchController.clear();
    clearSearch();
    notifyListeners();
  }

  void searchRecordings(String query) {
    _searchTitle = query;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadRecordings();
    });
  }

  void clearSearch() {
    searchController.clear();
    _searchTitle = '';
  }

  // ============ Recording Actions ============
  void navigateToRecordingDetail(BuildContext context, String meetingId) {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, AppRoutes.recordDetail, arguments: meetingId);
  }

  Future<void> onRename(
    BuildContext context,
    MeetingResponse meeting,
    String newName,
  ) async {
    if (newName.isNotEmpty && newName != meeting.title) {
      try {
        await Repository.rename(meeting.id, newName);

        // Refresh recordings list
        await loadRecordings();

        if (context.mounted) {
          // Close dialog if still open
          Navigator.of(context).pop();

          // Show success snackbar
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Renamed to "$newName"')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> deleteRecording(
    BuildContext context,
    MeetingResponse meeting,
  ) async {
    final confirmed = await showDeleteDialog(
      context,
      title: 'Delete Recording?',
    );

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      try {
        await Repository.delete(meeting.id);
        await loadRecordings();

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Deleted "${meeting.title}"')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> showRenameRecordingDialog(
    BuildContext context,
    MeetingResponse meeting,
  ) async {
    final newName = await showRenameDialog(
      context,
      initialTitle: meeting.title,
    );

    if (newName != null &&
        newName.isNotEmpty &&
        newName != meeting.title &&
        context.mounted) {
      await _renameRecording(context, meeting.id, newName);
    }
  }

  Future<void> _renameRecording(
    BuildContext context,
    String meetingId,
    String newName,
  ) async {
    try {
      await Repository.rename(meetingId, newName);
      await loadRecordings();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Renamed to "$newName"')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
