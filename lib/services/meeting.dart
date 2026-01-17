import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/meeting.dart';
import 'repository.dart';

class MeetingService extends ChangeNotifier {
  List<MeetingResponse> _meetings = [];
  bool _isLoading = false;
  String _searchTitle = '';

  Timer? _debounce;

  List<MeetingResponse> get meetings => List.unmodifiable(_meetings);
  bool get isLoading => _isLoading;
  String get searchTitle => _searchTitle;

  Future<void> loadMeetings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await Repository.getMeetings(_searchTitle);
      _meetings = data..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    } catch (e) {
      _meetings = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔍 Called on each character typed
  void searchByTitleLive(String value) {
    _searchTitle = value;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      loadMeetings();
    });
  }

  void clearSearch() {
    _searchTitle = '';
    loadMeetings();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
