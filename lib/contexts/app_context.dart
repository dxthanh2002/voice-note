import 'package:flutter/foundation.dart';

import '../services/api.dart';
import '../services/storage.dart';
import '../utils/console.dart';

/// App-level state for Meeting Recorder
class AppService extends ChangeNotifier {
  bool _booted = false;
  bool _onboarded = false;

  bool get booted => _booted;
  bool get onboarded => _onboarded;

  AppService() {
    init();
  }

  Future<void> init() async {
    if (_booted) return;

    final storedToken = await StorageService.get(AppStorageKeys.accessToken);
    final isNewUser =
        await StorageService.get(AppStorageKeys.isNewUser) == 'true';

    if (storedToken != null && !isNewUser) {
      Console.log("TEST: $storedToken");
      api.options.headers['Authorization'] = "Bearer $storedToken";

      _onboarded = true;
    } else {
      api.options.headers['Authorization'] = "Bearer $storedToken";
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
