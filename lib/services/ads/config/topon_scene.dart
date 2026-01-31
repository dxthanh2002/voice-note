// lib/ads/config/topon_scene.dart
import 'dart:io';

class TopOnScene {
  static String get rewarded => Platform.isIOS ? 'f5e54970dc84e6' : '';

  static String get interstitial => Platform.isIOS ? 'f5e549727efc49' : '';

  static String get banner => Platform.isIOS ? 'f600938d045dd3' : '';

  static String get native => Platform.isIOS ? 'f600938967feb5' : '';

  static String get splash => Platform.isIOS ? 'f5e549727efc49' : '';
}
