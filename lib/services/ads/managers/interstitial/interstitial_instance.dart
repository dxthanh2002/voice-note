import 'interstitial_state.dart';

class InterstitialAdInstance {
  final String placementId;

  InterstitialState state = InterstitialState.idle;

  int retryCount = 0;
  static const int maxRetry = 3;

  InterstitialAdInstance(this.placementId);

  bool get isReady => state == InterstitialState.ready;

  void reset() {
    state = InterstitialState.idle;
    retryCount = 0;
  }
}
