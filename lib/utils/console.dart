import 'package:flutter/foundation.dart';

class Console {
  static void log(dynamic message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint(' 🔍 DEBUG [$timestamp] : $message');
    }
  }

  static void warning(dynamic message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint(' ⚠️ WARNING [$timestamp] : $message');
    }
  }

  static void error(dynamic message, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint(' ❌ ERROR [$timestamp] : $message');
      if (stackTrace != null) {
        debugPrint(' 🗺️ STACKTRACE: $stackTrace');
      }
    }
  }

  static void lifecycle(String event) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint(' 🔄 LIFECYCLE [$timestamp] : $event');
    }
  }
}
