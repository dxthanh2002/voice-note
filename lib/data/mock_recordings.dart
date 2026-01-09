class Recording {
  final String id;
  final String title;
  final DateTime date;
  final Duration duration;
  final bool hasSummary;

  const Recording({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.hasSummary,
  });
}

final List<Recording> mockRecordings = [
  Recording(
    id: '1',
    title: 'Họp kế hoạch Quý 4',
    date: DateTime(2023, 10, 25),
    duration: const Duration(minutes: 45, seconds: 32),
    hasSummary: true,
  ),
  Recording(
    id: '2',
    title: 'Thảo luận dự án mới',
    date: DateTime(2023, 10, 24),
    duration: const Duration(hours: 1, minutes: 12, seconds: 15),
    hasSummary: false,
  ),
  Recording(
    id: '3',
    title: 'Cập nhật hàng tuần',
    date: DateTime(2023, 10, 22),
    duration: const Duration(minutes: 28, seconds: 50),
    hasSummary: true,
  ),
  Recording(
    id: '4',
    title: 'Phỏng vấn ứng viên Dev',
    date: DateTime(2023, 10, 21),
    duration: const Duration(minutes: 55, seconds: 10),
    hasSummary: false,
  ),
];
