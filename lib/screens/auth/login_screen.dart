import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../services/device.dart';
import '../../services/repository.dart';
import '../../services/client_request.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
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
                  const SizedBox(height: 40),
                  // Title
                  Text(
                    'Record & Summarize\nMeetings Easily',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(height: 1.2),
                  ),
                  const SizedBox(height: 48),
                  // Google button
                  _SocialLoginButton(
                    onPressed: () => _handleLogin(context),
                    icon: Icons.g_mobiledata,
                    label: 'Continue with Google',
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.textPrimaryLight,
                  ),
                  const SizedBox(height: 12),
                  // Apple button
                  _SocialLoginButton(
                    onPressed: () => _handleLogin(context),
                    icon: Icons.apple,
                    label: 'Continue with Apple',
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                  ),
                  const SizedBox(height: 32),
                  // Terms
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      final platform = DeviceService.getPlatform();

      final response = await Repository.login(deviceId, platform);

      debugPrint('New token: ${response.accessToken}');
      debugPrint('User: ${response.user.id}');

      setAuthToken(response.accessToken);

      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      debugPrint('Login error: $e');
    }
    // Navigator.pushReplacementNamed(context, '/');
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: backgroundColor == AppColors.white
                ? BorderSide(color: AppColors.dividerLight)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
