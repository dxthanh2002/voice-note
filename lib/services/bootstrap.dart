import 'storage.dart';
import 'device.dart';
import 'client_request.dart';


class Bootstrap {
  static Future<void> init() async {
    
    final token = await StorageService.get(AppStorageKeys.accessToken);

    if (token != null) {
      // Token exists → nothing to do
      setAuthToken(token);
      return;
    }

    // No token → login with device
    final response = await DeviceService.login();

    // Save token
    await StorageService.set(
      AppStorageKeys.accessToken,
      response.accessToken,
    );

    setAuthToken(response.accessToken);

    await StorageService.set(
      AppStorageKeys.isNewUser,
      response.isNewUser.toString(),
    );
  }

  
}
