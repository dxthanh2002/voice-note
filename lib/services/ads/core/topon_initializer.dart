import 'package:secmtp_sdk/at_index.dart';
import '../config/topon_app_config.dart';

class TopOnInitializer {
  static bool _inited = false;

  static Future<void> init({bool enableLog = false}) async {
    if (_inited) return;

    if (enableLog) {
      await _enableLog();
    }

    await _initSDK();

    _inited = true;
  }

  static Future<void> _enableLog() async {
    await ATInitManger.setLogEnabled(logEnabled: true);
  }

  static Future<void> _initSDK() async {
    await ATInitManger.initAnyThinkSDK(
      appidStr: TopOnAppConfig.appId,
      appidkeyStr: TopOnAppConfig.appKey,
    );
  }

  static Future<void> showDebugUI() async {
    await ATInitManger.showDebuggerUI(
      debugKey: TopOnAppConfig.debugKey,
    );
  }
}
