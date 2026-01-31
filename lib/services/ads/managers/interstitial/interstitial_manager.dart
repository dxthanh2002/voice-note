import 'dart:developer';
import 'package:secmtp_sdk/at_index.dart';

import 'interstitial_instance.dart';
import 'interstitial_state.dart';

class InterstitialManager {
  static bool _initialized = false;

  /// Registry: placementId → instance
  static final Map<String, InterstitialAdInstance> _instances = {};

  /// ================= INIT =================

  static void init() {
    if (_initialized) return;
    _initialized = true;

    ATListenerManager.interstitialEventHandler.listen(_onEvent);
    log('[Interstitial] Manager init');
  }

  /// ================= INTERNAL =================

  static InterstitialAdInstance _get(String placementId) {
    return _instances.putIfAbsent(
      placementId,
      () => InterstitialAdInstance(placementId),
    );
  }

  /// ================= PUBLIC API =================

  static bool isReady(String placementId) {
    return _instances[placementId]?.isReady ?? false;
  }

  static void load(String placementId) {
    final inst = _get(placementId);

    if (inst.state == InterstitialState.loading ||
        inst.state == InterstitialState.ready) {
      return;
    }

    log('[Interstitial][$placementId] load');
    inst.state = InterstitialState.loading;

    ATInterstitialManager.loadInterstitialAd(
      placementID: placementId,
      extraMap: const {},
    );
  }

  static void show(String placementId) {
    final inst = _get(placementId);

    log('[Interstitial][$placementId] show state=${inst.state}');

    if (inst.state != InterstitialState.ready) {
      log('[Interstitial][$placementId] ❌ not ready');
      return;
    }

    inst.state = InterstitialState.showing;

    ATInterstitialManager.showInterstitialAd(
      placementID: placementId,
    );
  }

  /// ================= EVENT =================

  static void _onEvent(ATInterstitialResponse event) {
    final placementId = event.placementID;
    final inst = _instances[placementId];

    if (inst == null) {
      log('[Interstitial][$placementId] ⚠️ event for unknown placement');
      return;
    }

    log('[Interstitial][$placementId] event=${event.interstatus}');

    switch (event.interstatus) {
      case InterstitialStatus.interstitialAdDidFinishLoading:
        inst.state = InterstitialState.ready;
        inst.retryCount = 0;
        break;

      case InterstitialStatus.interstitialDidShowSucceed:
        inst.state = InterstitialState.showing;
        break;

      case InterstitialStatus.interstitialAdDidClose:
        inst.reset();
        break;

      case InterstitialStatus.interstitialFailedToShow:
      case InterstitialStatus.interstitialAdFailToLoadAD:
      case InterstitialStatus.interstitialDidFailToPlayVideo:
        inst.reset();

        if (inst.retryCount < InterstitialAdInstance.maxRetry) {
          inst.retryCount++;
          Future.delayed(const Duration(seconds: 10), () {
            load(placementId);
          });
        }
        break;

      default:
        break;
    }
  }
}
