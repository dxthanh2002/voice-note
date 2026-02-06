import 'package:event_bus/event_bus.dart';
import 'package:secmtp_sdk/at_index.dart';

class EventBusUtil {
  static final EventBus eventBus = EventBus();
}

// 定义枚举类型
enum AdEventType {
  loading,
  ready,
  failed,
  not_ready,
  close,
}

// 事件类
class AdEvent {
  final String placementId;
  final AdEventType type;
  AdEvent({
    required this.placementId,
    required this.type,
  });
}

class NativeAdWidgetEvent {
  final PlatformNativeWidget nativeWidget;
  NativeAdWidgetEvent({
    required this.nativeWidget,
  });
}
