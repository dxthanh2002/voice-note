import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.id;
    }

    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return info.identifierForVendor ?? 'unknown-device';
    }

    return 'unknown-device';
  }

  static String getPlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }
}
