// lib/ads/managers/interstitial/interstitial_manager.dart
import 'dart:async';
import 'dart:developer';
import 'package:secmtp_sdk/at_index.dart';

import '../config/topon_placement.dart';

enum InterstitialState { idle, loading, ready, showing }

enum InterstitialShowResult { shown, notReady, failed }

class InterstitialManager {
  static bool _initialized = false;
  static InterstitialState _state = InterstitialState.idle;

  static Completer<InterstitialShowResult>? _showCompleter;

  static int _retryCount = 0;
  static const int _maxRetry = 3;

  static const Duration _shortRetryDelay = Duration(seconds: 10);
  static const Duration _longRetryDelay = Duration(seconds: 60);

  /// ================= INIT =================

  static void init() {
    if (_initialized) return;
    _initialized = true;

    ATListenerManager.interstitialEventHandler.listen(_onEvent);
    load();
  }

  /// ================= PUBLIC =================

  static bool get isReady => _state == InterstitialState.ready;

  static void load() {
    if (_state == InterstitialState.loading ||
        _state == InterstitialState.ready) {
      return;
    }

    log('[Interstitial] load()');
    _state = InterstitialState.loading;

    ATInterstitialManager.loadInterstitialAd(
      placementID: TopOnPlacement.interstitial,
      extraMap: const {},
    );
  }

  /// 🔥 UI chỉ gọi hàm này
  static Future<InterstitialShowResult> show() {
    log('[Interstitial] show() state=$_state');

    // ❌ NOT READY → cho user đi tiếp luôn
    if (_state != InterstitialState.ready) {
      log('[Interstitial] ❌ not ready → skip ads');
      return Future.value(InterstitialShowResult.notReady);
    }

    _state = InterstitialState.showing;
    _showCompleter = Completer<InterstitialShowResult>();

    ATInterstitialManager.showInterstitialAd(
      placementID: TopOnPlacement.interstitial,
    );

    return _showCompleter!.future;
  }

  /// ================= EVENT =================

  static void _onEvent(ATInterstitialResponse event) {
    if (event.placementID != TopOnPlacement.interstitial) return;

    log('[Interstitial] event=${event.interstatus}');

    switch (event.interstatus) {
      case InterstitialStatus.interstitialAdDidFinishLoading:
        _state = InterstitialState.ready;
        _retryCount = 0;
        log('[Interstitial] READY');
        break;

      case InterstitialStatus.interstitialDidShowSucceed:
        _state = InterstitialState.showing;
        break;

      case InterstitialStatus.interstitialAdDidClose:
        _state = InterstitialState.idle;
        _complete(InterstitialShowResult.shown);
        load();
        break;

      case InterstitialStatus.interstitialFailedToShow:
      case InterstitialStatus.interstitialDidFailToPlayVideo:
        log('[Interstitial] ❌ show failed');
        _state = InterstitialState.idle;
        _complete(InterstitialShowResult.failed);
        _retry(_shortRetryDelay);
        break;

      case InterstitialStatus.interstitialAdFailToLoadAD:
        log('[Interstitial] ❌ load failed (no fill)');
        _state = InterstitialState.idle;
        _retry(_longRetryDelay);
        break;

      default:
        break;
    }
  }

  /// ================= INTERNAL =================

  static void _complete(InterstitialShowResult result) {
    if (_showCompleter != null && !_showCompleter!.isCompleted) {
      _showCompleter!.complete(result);
    }
    _showCompleter = null;
  }

  static void _retry(Duration delay) {
    if (_retryCount >= _maxRetry) {
      log('[Interstitial] ❌ retry limit reached');
      return;
    }

    _retryCount++;
    log(
      '[Interstitial] retry $_retryCount/$_maxRetry after ${delay.inSeconds}s',
    );

    Future.delayed(delay, load);
  }
}
