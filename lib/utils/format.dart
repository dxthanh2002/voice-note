import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(date.year, date.month, date.day);

  final difference = today.difference(dateOnly).inDays;

  if (difference == 0) {
    return 'Today';
  } else if (difference == 1) {
    return 'Yesterday';
  }

  return DateFormat('MMMM d, yyyy').format(date);
}

String formatDuration(Duration? duration) {
  if (duration == null || duration.inSeconds == 0) {
    return '--:--';
  }

  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  if (duration.inHours > 0) {
    return '$hours:$minutes:$seconds';
  } else {
    return '$minutes:$seconds';
  }
}

void printFormatted(dynamic data) {
  const encoder = JsonEncoder.withIndent('  ');
  final formatted = encoder.convert(data);
  debugPrint(formatted);
}
