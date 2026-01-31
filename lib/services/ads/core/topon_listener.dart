// lib/ads/core/topon_listener.dart
import 'package:secmtp_sdk/at_index.dart';
import 'package:flutter/material.dart';

class TopOnListener {
  static void listenConsent({
    required VoidCallback onConsentGranted,
  }) {
    ATListenerManager.initEventHandler.listen((event) async {
      if (event.consentDismiss != null) {
        onConsentGranted();
      }
    });
  }
}
