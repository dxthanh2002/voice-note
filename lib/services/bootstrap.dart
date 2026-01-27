import '../utils/constants.dart';
import 'api.dart';
import 'storage.dart';
import 'device.dart';


class Bootstrap {
  static Future<void> init() async {
    
    final token = await StorageService.get(AppStorageKeys.accessToken);

    if (token != null) {
      // Token exists → nothing to do
      api.options.headers["Authorization"] = token;
      return;
    }

    // No token → login with device
    final response = await DeviceService.login(APP_CODE);

    // Save token
    await StorageService.set(
      AppStorageKeys.accessToken,
      response.accessToken,
    );

    await StorageService.set(
      AppStorageKeys.isNewUser,
      response.isNewUser.toString(),
    );

    api.options.headers["Authorization"] = response.accessToken;

  }

  
}
