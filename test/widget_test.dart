import 'package:flutter_test/flutter_test.dart';

import 'package:aimateflutter/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MeetingRecorderApp());
    expect(find.byType(MeetingRecorderApp), findsOneWidget);
  });
}
