// lib/ads/config/topon_placement.dart
import 'dart:io';

class TopOnPlacement {
  static String get rewarded =>
      Platform.isIOS ? 'n696f32d369d23' : 'n696f32d369d23';

  static String get interstitial =>
      Platform.isIOS ? 'n697c2a34cf827' : 'n697c2a34cf827';

  static String get banner =>
      Platform.isIOS ? 'n696e4270364ac' : 'n696e4270364ac';

  static String get native =>
      Platform.isIOS ? 'b5bacac5f73476' : 'b6305efb12d408';

  static String get splash =>
      Platform.isIOS ? 'b5c22f0e5cc7a0' : 'b62b0272f8762f';
}
