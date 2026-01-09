import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    return info.id;
  }
  if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    return info.identifierForVendor ?? 'unknown-device';
  }
  return 'unknown-device';
}

Future<String> getPushToken() async {
  // Push token requires Firebase Messaging setup; return empty until configured.
  return '';
}
