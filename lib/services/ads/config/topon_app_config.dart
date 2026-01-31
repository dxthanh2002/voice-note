// lib/ads/config/topon_app_config.dart
import 'dart:io';

class TopOnAppConfig {
  static String get appId =>
      Platform.isIOS ? 'a5b0e8491845b3' : 'h68f8791a6a432';

  static String get appKey => Platform.isIOS
      ? '7eae0567827cfe2b22874061763f30c9'
      : 'a99ecb5202860c614fad911c8983e2815';

  static String get debugKey =>
      Platform.isIOS ? '99117a5bf26ca7a1923b3fed8e5371d3ab68c25c' : '';
}
