import 'dart:io';

class Configuration {
  static String appidStr = 'h697c2a0d45144';
  static String appidkeyStr = 'a9066bb9ca581fd1c0ad828b68faf8d7a';

  static String summaryReward = 'n697c2a3480a4d';
  static String transcriptReward = 'n697c2a33996b6';

  static String interstitial = 'n697c2a34cf827';

  static String bannerPlacementID = Platform.isIOS
      ? 'b5bacaccb61c29'
      : 'b62b01a36e4572';
  static String nativePlacementID = Platform.isIOS
      ? 'b5bacac5f73476'
      : 'b6305efb12d408';
  static String splashPlacementID = Platform.isIOS
      ? 'b5c22f0e5cc7a0'
      : 'b62b0272f8762f';

  static String rewardedShowCustomExt = 'RewardedShowCustomExt';
  static String interstitialShowCustomExt = 'InterstitialShowCustomExt';
  static String splashShowCustomExt = 'SplashShowCustomExt';
  static String bannerShowCustomExt = 'BannerShowCustomExt';
  static String nativeShowCustomExt = 'NativeShowCustomExt';

  static String rewarderSceneID = Platform.isIOS ? 'f5e54970dc84e6' : '';
  static String autoRewarderSceneID = Platform.isIOS ? 'f5e54970dc84e6' : '';

  static String interstitialSceneID = Platform.isIOS ? 'f5e549727efc49' : '';
  static String autoInterstitialSceneID = Platform.isIOS
      ? 'f5e549727efc49'
      : '';

  static String nativeSceneID = Platform.isIOS ? 'f600938967feb5' : '';

  static String bannerSceneID = Platform.isIOS ? 'f600938d045dd3' : '';

  static String splashSceneID = Platform.isIOS ? 'f5e549727efc49' : '';

  static String debugKey = Platform.isIOS
      ? '99117a5bf26ca7a1923b3fed8e5371d3ab68c25c'
      : '';
}
