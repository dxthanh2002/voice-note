// lib/ads/core/event/ad_event.dart
enum AdEventType {
  loading,
  ready,
  not_ready,
  failed,
  showing,
  closed,
  clicked,
}

class AdEvent {
  final String placementId;
  final AdEventType type;

  AdEvent({
    required this.placementId,
    required this.type,
  });
}
