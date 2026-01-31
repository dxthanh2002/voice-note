import 'package:secmtp_sdk/at_index.dart';

import 'core/topon_initializer.dart';
import 'managers/interstitial_manager.dart';
import 'managers/rewarded_manager.dart';
import 'managers/native_manager.dart';

class AdsInitializer {
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;

    ATListenerManager.initEventHandler.listen((value) async {
      if (value.consentDismiss != null) {
        await TopOnInitializer.init();
        // await TopOnInitializer.init(enableLog: true);

        InterstitialManager.init();
        InterstitialManager.load();

        RewardedManager.init();
        RewardedManager.load();

        NativeManager.init();
        NativeManager.load();

        _initialized = true;
      }
    });

    ATInitManger.showGDPRConsentDialog();
  }
}
