import 'package:flutter/material.dart';

import '../data/recordings_repository.dart';
import '../navigation/app_routes.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main/main_tabs_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/recording/active_record_screen.dart';
import '../screens/recording/record_detail_screen.dart';
import '../screens/subscription/upgrade_screen.dart';

Route<dynamic> buildRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const MainTabsScreen());
    case AppRoutes.activeRecord:
      return MaterialPageRoute(builder: (_) => const ActiveRecordScreen());
    case AppRoutes.recordDetail:
      final recording = settings.arguments as Recording?;
      return MaterialPageRoute(
        builder: (_) => RecordDetailScreen(recording: recording),
      );
    case AppRoutes.upgrade:
      return MaterialPageRoute(builder: (_) => const UpgradeScreen());
    default:
      return MaterialPageRoute(builder: (_) => const MainTabsScreen());
  }
}
