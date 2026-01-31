import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:secmtp_sdk/at_index.dart';

import '../config/topon_placement.dart';

/// ===============================
/// NativeManager (TopOn)
/// - Chỉ quản lý SDK + state
/// - KHÔNG async widget
/// - KHÔNG MediaQuery
/// ===============================
class NativeManager {
  static bool _inited = false;
  static bool _isLoading = false;

  /// ================= INIT =================
  static void init() {
    if (_inited) return;
    _inited = true;

    ATListenerManager.nativeEventHandler.listen((event) {
      switch (event.nativeStatus) {
        case NativeStatus.nativeAdDidFinishLoading:
          log('🟢 Native loaded: ${event.placementID}');
          _isLoading = false;
          break;

        case NativeStatus.nativeAdFailToLoadAD:
          log('❌ Native load failed: ${event.requestMessage}');
          _isLoading = false;
          break;

        case NativeStatus.nativeAdDidShowNativeAd:
          log('✅ Native shown');
          break;

        case NativeStatus.nativeAdDidClick:
          log('👉 Native clicked');
          break;

        case NativeStatus.nativeAdDidTapCloseButton:
          log('❌ Native closed');
          remove();
          load(); // preload lại cho lần sau
          break;

        default:
          break;
      }
    });
  }

  /// ================= LOAD =================
  static Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    log('⏳ Loading native ad...');

    await ATNativeManager.loadNativeAd(
      placementID: TopOnPlacement.native,
      extraMap: {
        ATCommon.isNativeShow(): false,
        ATCommon.getAdSizeKey(): ATNativeManager.createNativeSubViewAttribute(
          300,
          250,
        ),
        ATNativeManager.isAdaptiveHeight(): true,
      },
    );
  }

  /// ================= READY =================
  static Future<bool> isReady() {
    return ATNativeManager.nativeAdReady(
      placementID: TopOnPlacement.native,
    );
  }

  /// ================= BUILD =================
  /// ⚠️ GỌI TRONG UI – KHÔNG async
  static Widget buildWidget({
    required double width,
    required double height,
  }) {
    return PlatformNativeWidget(
      TopOnPlacement.native,
      {
        /// ROOT
        ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
          width,
          height,
          backgroundColorStr: '#FFFFFF',
        ),

        /// ICON
        ATNativeManager.appIcon(): ATNativeManager.createNativeSubViewAttribute(
          50,
          50,
          x: 12,
          y: 12,
          cornerRadius: 8,
        ),

        /// TITLE
        ATNativeManager.mainTitle():
            ATNativeManager.createNativeSubViewAttribute(
          width - 160,
          20,
          x: 72,
          y: 12,
          textSize: 15,
        ),

        /// DESC
        ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
          width - 160,
          40,
          x: 72,
          y: 36,
          textSize: 13,
        ),

        /// IMAGE
        ATNativeManager.mainImage():
            ATNativeManager.createNativeSubViewAttribute(
          width - 24,
          180,
          x: 12,
          y: 80,
          cornerRadius: 8,
        ),

        /// CTA
        ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
          100,
          36,
          x: width - 112,
          y: height - 48,
          textSize: 14,
          textColorStr: '#FFFFFF',
          backgroundColorStr: '#2095F1',
          textAlignmentStr: 'center',
          cornerRadius: 18,
        ),

        /// DISLIKE
        ATNativeManager.dislike(): ATNativeManager.createNativeSubViewAttribute(
          20,
          20,
          x: width - 28,
          y: 8,
        ),
      },
    );
  }

  /// ================= REMOVE =================
  static Future<void> remove() {
    return ATNativeManager.removeNativeAd(
      placementID: TopOnPlacement.native,
    );
  }
}
