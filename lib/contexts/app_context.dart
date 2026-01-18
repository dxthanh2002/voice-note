import 'package:flutter/foundation.dart';

import '../services/storage.dart';

/// App-level state for Meeting Recorder
class AppState extends ChangeNotifier {
  bool _booted = false;
  bool _onboarded = false;

  bool get booted => _booted;
  bool get onboarded => _onboarded;

  Future<void> boot() async {
    if (_booted) return;

    final token = await StorageService.get(AppStorageKeys.accessToken);
    final isNewUser =
        await StorageService.get(AppStorageKeys.isNewUser) == 'true';

    if (token != null && !isNewUser) {
      _onboarded = true;
    } else {
      _onboarded = false;
    }

    _booted = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await StorageService.set(AppStorageKeys.isNewUser, 'false');
    _onboarded = true;
    notifyListeners();
  }
}
