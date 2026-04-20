import 'package:aimateflutter/utils/constants.dart';
import 'package:flutter/foundation.dart';

import '../services/api.dart';
import '../services/device.dart';
import '../services/repository.dart';
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

    final bool success = await loginDevice();

    if (success) {
      Console.log("success");
    } else {
      Console.log("fail to login");
    }

    // final storedToken = await StorageService.get(AppStorageKeys.accessToken);
    // final isNewUser =
    //     await StorageService.get(AppStorageKeys.isNewUser) == 'true';

    // if (storedToken != null && !isNewUser) {
    //   Console.log("TEST: $storedToken");
    //   api.options.headers['Authorization'] = "Bearer $storedToken";

    //   _onboarded = true;
    // } else {
    //   // api.options.headers['Authorization'] = "Bearer $storedToken";
    //   _onboarded = false;
    // }

    _booted = true;
    _onboarded = false;
    notifyListeners();
  }

  static Future<bool> loginDevice() async {
    try {
      final deviceId = await DeviceService.getId();
      final platform = DeviceService.getPlatform();
      final response = await Repository.login(deviceId, platform, APP_CODE);

      final accessToken = response.accessToken;

      if (accessToken.isNotEmpty) {
        api.options.headers['token'] = accessToken;

        return true;
      }
      return false;
    } catch (e) {
      Console.error("loginDevice failed: $e");
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    await StorageService.set(AppStorageKeys.isNewUser, 'false');
    _onboarded = true;
    notifyListeners();
  }
}
