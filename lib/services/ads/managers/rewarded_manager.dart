// lib/ads/managers/rewarded/rewarded_manager.dart
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:secmtp_sdk/at_index.dart';

import '../config/topon_placement.dart';
import '../config/topon_scene.dart';
import '../config/topon_custom_ext.dart';

enum RewardedState { idle, loading, ready, showing }

enum RewardResultStatus { success, cancelled, failed }

class RewardResult {
  final RewardResultStatus status;
  final Map<String, dynamic>? rewardData;

  const RewardResult({required this.status, this.rewardData});

  bool get isSuccess => status == RewardResultStatus.success;
}

class RewardedManager {
  /// ================== STATE ==================
  static bool _rewardGranted = false;

  static bool _initialized = false;
  static RewardedState _state = RewardedState.idle;

  static Completer<RewardResult>? _completer;
  static Map<String, dynamic>? _pendingRewardData;

  /// ================== RETRY ==================

  static int _retryCount = 0;
  static const int _maxRetry = 2;
  static Timer? _retryTimer;

  static const Duration _retryDelay = Duration(seconds: 15);

  /// ================== INIT ==================

  static void init() {
    if (_initialized) return;
    _initialized = true;

    ATListenerManager.rewardedVideoEventHandler.listen(_onEvent);

    log('[Rewarded] init');

    load(); // 🔥 PRELOAD LẦN ĐẦU

    // ❗ KHÔNG preload vô hạn ở đây
  }

  /// ================== PUBLIC ==================

  static bool get isReady => _state == RewardedState.ready;

  /// Chủ động load (intent-based)
  static Future<void> load() async {
    if (_state == RewardedState.loading || _state == RewardedState.ready) {
      return;
    }

    log('[Rewarded] load()');
    _state = RewardedState.loading;

    await ATRewardedManager.loadRewardedVideo(
      placementID: TopOnPlacement.rewarded,
      extraMap: {
        ATRewardedManager.kATAdLoadingExtraUserIDKey(): 'user_123',
        ATRewardedManager.kATAdLoadingExtraUserDataKeywordKey(): 'rewarded',
      },
    );
  }

  /// API chính cho UI
  static Future<RewardResult?> showAndWait({
    required Map<String, dynamic> rewardData,
  }) {
    if (_state != RewardedState.ready) {
      return Future.value(null);
    }

    _rewardGranted = false; // 🔥 RESET
    _pendingRewardData = rewardData;
    _completer = Completer<RewardResult>();

    _state = RewardedState.showing;
    _showInternal();

    return _completer!.future;
  }

  /// ================== INTERNAL ==================

  static void _showInternal() {
    log('[Rewarded] show');

    if (Platform.isAndroid || TopOnScene.rewarded.isEmpty) {
      ATRewardedManager.showRewardedVideo(placementID: TopOnPlacement.rewarded);
      return;
    }

    ATRewardedManager.entryRewardedVideoScenario(
      placementID: TopOnPlacement.rewarded,
      sceneID: TopOnScene.rewarded,
    );

    ATRewardedManager.showRewardedVideoWithShowConfig(
      placementID: TopOnPlacement.rewarded,
      sceneID: TopOnScene.rewarded,
      showCustomExt: TopOnCustomExt.rewarded,
    );
  }

  static void _complete(RewardResult result) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(result);
    }

    _completer = null;
    _pendingRewardData = null;
    _state = RewardedState.idle;
  }

  static void _scheduleRetry() {
    if (_retryCount >= _maxRetry) {
      log('[Rewarded] ❌ retry limit reached');
      return;
    }

    _retryCount++;
    _retryTimer?.cancel();

    log(
      '[Rewarded] retry in ${_retryDelay.inSeconds}s ($_retryCount/$_maxRetry)',
    );

    _retryTimer = Timer(_retryDelay, () {
      load();
    });
  }

  /// ================== EVENT ==================

  static void _onEvent(event) {
    log('[Rewarded] event=${event.rewardStatus}');

    switch (event.rewardStatus) {
      case RewardedStatus.rewardedVideoDidFinishLoading:
        _state = RewardedState.ready;
        _retryCount = 0;
        break;

      case RewardedStatus.rewardedVideoDidStartPlaying:
        _state = RewardedState.showing;
        break;

      /// 🎁 SUCCESS (CHỈ XỬ LÝ 1 LẦN)
      case RewardedStatus.rewardedVideoDidRewardSuccess:
        if (_rewardGranted) return;

        _rewardGranted = true;

        _complete(
          RewardResult(
            status: RewardResultStatus.success,
            rewardData: _pendingRewardData,
          ),
        );

        break;

      /// 🚫 CLOSE
      case RewardedStatus.rewardedVideoDidClose:
        if (!_rewardGranted) {
          _complete(const RewardResult(status: RewardResultStatus.cancelled));
        }

        // ✅ load SAU KHI ĐÓNG XONG
        _state = RewardedState.idle;
        load();
        break;

      /// ❌ FAIL
      case RewardedStatus.rewardedVideoDidFailToPlay:
      case RewardedStatus.rewardedVideoDidFailToLoad:
        _complete(const RewardResult(status: RewardResultStatus.failed));

        _state = RewardedState.idle;
        _scheduleRetry();
        break;

      default:
        break;
    }
  }
}
