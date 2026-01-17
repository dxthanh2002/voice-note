import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main/navigation_tab.dart';
import '../screens/onboarding/onboarding_screen.dart';

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

    case AppRoutes.recordDetail:
      final id = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => RecordDetailScreen(id: id));
    case AppRoutes.upgrade:
      return MaterialPageRoute(builder: (_) => const UpgradeScreen());
    default:
      return MaterialPageRoute(builder: (_) => const MainTabsScreen());
  }
}
