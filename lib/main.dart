import 'package:aimateflutter/services/meeting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'contexts/app_context.dart';
import 'navigation/app_navigator.dart';
import 'screens/main/navigation_tab.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/bootstrap.dart';
import 'theme/app_theme.dart';
import 'theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Bootstrap.init();
  runApp(const MeetingRecorderApp());
}

class MeetingRecorderApp extends StatelessWidget {
  const MeetingRecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..boot()),
        ChangeNotifierProvider(create: (_) => MeetingService()),
      ],
      child: MaterialApp(
        title: 'Meeting Recorder',
        theme: buildAppTheme(),
        onGenerateRoute: buildRoute,
        home: const AppRoot(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.booted) { // loading
          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        
        // Show onboarding for first time users, otherwise go to main
        if (!state.onboarded) {
          return const OnboardingScreen();
        }

        return const MainTabsScreen();
      },
    );
  }
}


