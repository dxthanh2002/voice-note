import 'package:flutter/foundation.dart';

import '../services/storage.dart';

class AppStorageKeys {
  static const String onboarded = 'onboarded';
}

/// App-level state for Meeting Recorder
class AppState extends ChangeNotifier {
  bool _booted = false;
  bool _onboarded = false;

  bool get booted => _booted;
  bool get onboarded => _onboarded;

  Future<void> boot() async {
    if (_booted) return;

    final storedOnboarded = await StorageService.get(AppStorageKeys.onboarded);
    _onboarded = storedOnboarded == 'true';

    _booted = true;
    notifyListeners();
  }

  Future<void> setOnboarded(bool value) async {
    _onboarded = value;
    await StorageService.set(AppStorageKeys.onboarded, value.toString());
    notifyListeners();
  }
}
