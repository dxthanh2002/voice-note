import 'package:aimateflutter/features/recording_control/recording_control_screen.dart';
import 'package:aimateflutter/models/meeting.dart';
import 'package:flutter/material.dart';

import '../features/detail_recording/detail_record_screen.dart';
import 'routes.dart';
import '../features/auth/login_screen.dart';
import '../features/main/bottom_navigator_tab.dart';
import '../features/onboarding/onboarding_screen.dart';

import '../features/subscription/upgrade_screen.dart';

Route<dynamic> AppRouter(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const BottomNavigatorTab());

    case AppRoutes.recordControl:
      final meeting = settings.arguments as MeetingResponse;
      return MaterialPageRoute(
        builder: (_) => RecordControlScreen(meeting: meeting),
      );

    case AppRoutes.recordDetail:
      final meetingId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => DetailRecordScreen(id: meetingId),
      );
    case AppRoutes.upgrade:
      return MaterialPageRoute(builder: (_) => const UpgradeScreen());
    default:
      return MaterialPageRoute(builder: (_) => const BottomNavigatorTab());
  }
}
