import 'dart:async';

import 'package:aimateflutter/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/dialogs/delete_dialog.dart';
import '../../components/dialogs/rename_dialog.dart';
import '../../models/meeting.dart';
import '../../navigation/routes.dart';
import '../../services/repository.dart';
import '../../services/data/recordings.dart';
import '../../utils/console.dart';

class RecordingsViewModel extends ChangeNotifier {
  // State
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;
  // List<MeetingResponse> _recordings = [];
  List<Recording> _recordings = [];

  bool _isLoading = false;
  String _searchTitle = '';

  Timer? _debounce;

  // ============ Getters ============
  bool get isSearchExpanded => _isSearchExpanded;
  bool get isLoading => _isLoading;
  List<Recording> get recordings => List.unmodifiable(_recordings);

  RecordingsViewModel() {
    searchController.addListener(() {
      // Optional: Add any search controller listeners if needed
      if (searchController.text != _searchTitle) {
        searchRecordings(searchController.text);
      }
    });
  }

  // ============ Setup ============

  Future<void> loadRecordings() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      Console.log("LOADING RECORDINGS");

      final recordings = await DatabaseService().searchRecordings(_searchTitle);
      _recordings = recordings;
      //
    } catch (e) {
      Console.error("FAIL LOAD RECORDING");
      _recordings = [];
    } finally {
      _setLoading(false);
    }
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
  // Future<void> loadRecordings() async {
  //   _setLoading(true);
  //   await _loadRecordings();
  //   _setLoading(false);
  // }

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
    _searchTitle = query.trim();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      loadRecordings();
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

  Future<void> deleteRecording(BuildContext context, String meetingId) async {
    final confirmed = await showDeleteDialog(
      context,
      title: 'Delete Recording?',
    );

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      try {
        await Repository.deleteMeeting(meetingId);
        await loadRecordings();
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
    String meetingId,
    String meetingTitle,
  ) async {
    final newName = await showRenameDialog(context, initialTitle: meetingTitle);

    if (newName != null &&
        newName.isNotEmpty &&
        newName != meetingTitle &&
        context.mounted) {
      // TODO:
      await _renameRecording(context, meetingTitle, newName);
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
