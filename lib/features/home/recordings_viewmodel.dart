import 'dart:async';

import 'package:aimateflutter/services/database.dart';
import 'package:aimateflutter/services/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../navigation/routes.dart';
import '../../services/ads/ads.dart';
import '../../services/recording.dart';
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
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();

    // Only search if query changed
    if (query != _searchTitle) {
      _searchTitle = query;

      // Debounce the search
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
        loadRecordings();
      });
    }
  }

  // ============ Setup ============

  Future<void> loadRecordings() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      Console.log("LOADING RECORDINGS");

      final recordings = await DatabaseService().searchRecordings(_searchTitle);
      if (recordings.length != 0) {
        for (var recording in recordings) {
          Console.log("${recording.title} STATUS: ${recording.status}");
          Console.log("ID: ${recording.meetingId}");
          Console.log("duration : ${recording.duration}");
          Console.log("==========");
        }
      }
      final recordingsSV = await Repository.getMeetings("");
      for (var recording in recordingsSV) {
        Console.log("${recording.title} STATUS: ${recording.transcriptStatus}");
        Console.log("ID: ${recording.id}");

        Console.log("duration : ${recording.duration}");
        Console.log("==========");
      }
      _recordings = recordings;
      //
    } catch (e, stackTrace) {
      Console.error("FAIL LOAD RECORDING $e", stackTrace);
      _recordings = [];
    } finally {
      _setLoading(false);
    }
  }

  // ============ Dispose ============
  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ============ Recording Management ============

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
    // clearSearch();
    notifyListeners();
  }

  // ============ Recording Actions ============
  void navigateToRecordingDetail(BuildContext context, String meetingId) async {
    // InterstitialManager.show();

    HapticFeedback.selectionClick();
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.recordDetail,
      arguments: meetingId,
    );

    if (result == true) {
      await loadRecordings();
    }
  }

  Future<void> deleteRecording(BuildContext context, String meetingId) async {
    await RecordingService.deleteRecording(context, meetingId, refresh: true);
  }

  Future<void> renameRecording(
    BuildContext context,
    String meetingId,
    String meetingTitle,
  ) async {
    await RecordingService.renameRecording(
      context,
      meetingId,
      meetingTitle,
      refresh: true,
    );
  }
}
