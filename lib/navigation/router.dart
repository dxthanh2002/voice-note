import 'package:flutter/material.dart';

import 'routes.dart';
import '../features/auth/login_screen.dart';
import '../features/main/navigation_tab.dart';
import '../features/onboarding/onboarding_screen.dart';

import '../features/recording/record_detail_screen.dart';
import '../features/subscription/upgrade_screen.dart';

Route<dynamic> AppRouter(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const MainTabsScreen());

    case AppRoutes.recordDetail:
      final id = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => RecordDetailScreen(id: id));
    case AppRoutes.upgrade:
      return MaterialPageRoute(builder: (_) => const UpgradeScreen());
    default:
      return MaterialPageRoute(builder: (_) => const MainTabsScreen());
  }
}
