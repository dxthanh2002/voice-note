import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../contexts/app_context.dart';
import '../../theme/colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Logo
              Semantics(
                image: true,
                label: 'Voice Note app logo',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.mic,
                    size: 48,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Record & Summarize\nMeetings Easily',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Boost your meeting productivity, never miss any important details.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(),
              // Continue button
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.read<AppState>().completeOnboarding();
                },
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
