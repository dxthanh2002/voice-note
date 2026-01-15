import 'package:intl/intl.dart';
import 'dart:convert';

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

String formatDuration(Duration? duration) {
  if (duration == null) return 'Đang ghi';

  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  if (duration.inHours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

void _printFormatted(dynamic data) {
  const encoder = JsonEncoder.withIndent('  ');
  final formatted = encoder.convert(data);
  print(formatted);
}
