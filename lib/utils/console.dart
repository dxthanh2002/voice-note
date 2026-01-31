import 'package:flutter/foundation.dart';

class Console {
  static void logPreview(String label, dynamic data) {
    if (data == null) return;

    if (kDebugMode) {
      final dataStr = data.toString();
      if (dataStr.isEmpty) return;

      final preview = dataStr.length > 400
          ? '${dataStr.substring(0, 400)}...'
          : dataStr;

      debugPrint('  ● $label: $preview');
    }
  }

  static void log(dynamic message) {
    if (kDebugMode) {
      debugPrint(' 🔍 DEBUG: $message');
    }
  }

  static void warning(dynamic message) {
    if (kDebugMode) {
      debugPrint(' ⚠️ WARNING: $message');
    }
  }

  static void error(dynamic message, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint(' ❌ ERROR: $message');
      if (stackTrace != null) {
        debugPrint(' 🗺️ STACKTRACE: $stackTrace');
      }
    }
  }

  static void lifecycle(String event) {
    if (kDebugMode) {
      debugPrint(' 🔄 LIFECYCLE: $event');
    }
  }
}
