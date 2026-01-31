// lib/ads/managers/banner_manager.dart
import 'dart:developer';

import 'package:secmtp_sdk/at_index.dart';
import '../config/topon_placement.dart';

/// BannerManager
/// - Quản lý STATE banner (loading / showing)
/// - SDK AnyThink (ATBannerManager) chỉ là bridge gọi native
/// - Banner hiển thị bằng native overlay (KHÔNG widget)
class BannerManager {
  static bool _isLoading = false;
  static bool _isShowing = false;
  static bool _inited = false;

  /// GỌI 1 LẦN DUY NHẤT (sau khi SDK init)
  static void init() {
    if (_inited) return;
    _inited = true;

    ATListenerManager.bannerEventHandler.listen((value) {
      log('📢 Banner event: '
          'status=${value.bannerStatus}, '
          'placement=${value.placementID}, '
          'msg=${value.requestMessage}');

      switch (value.bannerStatus) {
        case BannerStatus.bannerAdDidFinishLoading:
          _isLoading = false;
          break;

        case BannerStatus.bannerAdFailToLoadAD:
          _isLoading = false;
          break;

        case BannerStatus.bannerAdDidShowSucceed:
          _isShowing = true;
          break;

        case BannerStatus.bannerAdTapCloseButton:
          _isShowing = false;
          Future.delayed(const Duration(seconds: 30), load);
          break;

        default:
          break;
      }
    });
  }

  /// LOAD BANNER
  static Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    log('⏳ Loading banner');
    log('📌 placementId = ${TopOnPlacement.banner}');

    await ATBannerManager.loadBannerAd(
      placementID: TopOnPlacement.banner,
      extraMap: {
        /// size banner
        ATCommon.getAdSizeKey():
            ATBannerManager.createLoadBannerAdSize(320, 50),

        /// hiển thị native overlay
        ATCommon.isNativeShow(): true,
      },
    );
  }

  /// SHOW BANNER Ở DƯỚI MÀN HÌNH
  static Future<void> showBottom() async {
    log('📣 Try show banner');

    final ready = await ATBannerManager.bannerAdReady(
      placementID: TopOnPlacement.banner,
    );

    if (ready == true) {
      log('✅ Banner ready → show');
      await ATBannerManager.showAdInPosition(
        placementID: TopOnPlacement.banner,
        position: ATCommon.getAdATBannerAdShowingPositionBottom(),
      );
      _isShowing = true;
    } else {
      log('⏳ Banner not ready → try load');
      load();
    }
  }

  /// ẨN BANNER (CÒN CACHE)
  static Future<void> hide() async {
    if (!_isShowing) return;

    await ATBannerManager.hideBannerAd(
      placementID: TopOnPlacement.banner,
    );
    _isShowing = false;
  }

  /// REMOVE BANNER (GIẢI PHÓNG HOÀN TOÀN)
  static Future<void> remove() async {
    await ATBannerManager.removeBannerAd(
      placementID: TopOnPlacement.banner,
    );
    _isShowing = false;
  }

  static void _reload() {
    _isLoading = false;
    load();
  }
}
