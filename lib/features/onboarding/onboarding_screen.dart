import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../contexts/app_context.dart';
import '../../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Record effortlessly',
      subtitle: 'Capture any conversation with one tap',
      icon: Icons.mic_none_outlined,
      buttonText: 'Continue',
    ),
    OnboardingStep(
      title: 'Instant summaries',
      subtitle: 'Turn long conversations into clear summaries, key points, and decisions in seconds',
      icon: Icons.description_outlined,
      buttonText: 'Continue',
    ),
    OnboardingStep(
      title: 'Ask anything',
      subtitle: 'Ask AI anything about your meetings and get instant answers',
      icon: Icons.forum_outlined,
      buttonText: 'Get Started',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      HapticFeedback.mediumImpact();
      context.read<AppService>().completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using Theme colors from AppColors
    const Color primary = AppColors.primary;
    const Color onPrimary = AppColors.white;
    const Color onSurfaceVariant = AppColors.textSecondary;
    const Color backgroundStart = AppColors.cardDark;
    const Color backgroundEnd = AppColors.backgroundDark;
    final Color surfaceContainer = AppColors.cardDark.withValues(alpha: 0.8);
    final Color primaryGradientEnd = primary.withValues(alpha: 0.8);

    return Scaffold(
      backgroundColor: backgroundEnd,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [backgroundStart, backgroundEnd],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header Shell
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AI Voice Note',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.read<AppService>().completeOnboarding();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: onSurfaceVariant,
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Fixed height Hero Section to prevent jumping
                          SizedBox(
                            height: 320,
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  // Background Radial Glow
                                  Container(
                                    width: 256,
                                    height: 256,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          primary.withValues(alpha: 0.15),
                                          primary.withValues(alpha: 0),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Floating Icon Container
                                  Container(
                                    width: 128,
                                    height: 128,
                                    decoration: BoxDecoration(
                                      color: surfaceContainer,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primary.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.15),
                                          blurRadius: 80,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        step.icon,
                                        color: primary,
                                        size: 64,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 29),

                          // Typography Content - Unified fixed height container
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: SizedBox(
                              height: 140, // Fixed total height for the text area
                              child: Column(
                                children: [
                                  Text(
                                    step.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 2), // Very small gap
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 300),
                                    child: Text(
                                      step.subtitle,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: onSurfaceVariant,
                                        fontSize: 14,
                                        height: 1.5,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Footer Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                  child: Column(
                    children: [
                      // Pagination Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_steps.length, (index) {
                          if (index == _currentPage) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildActiveDot(primary),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildDot(onSurfaceVariant.withValues(alpha: 0.2)),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      // Main Button
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [primary, primaryGradientEnd],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _onNextPressed,
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                _steps[_currentPage].buttonText,
                                style: const TextStyle(
                                  color: onPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildActiveDot(Color color) {
    return Container(
      width: 24,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
  });
}


