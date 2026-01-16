import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../services/device.dart';
import '../../services/repository.dart';
import '../../services/client_request.dart';
import '../../components/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final deviceId = await DeviceService.getDeviceId();
      final platform = DeviceService.getPlatform();

      final response = await Repository.login(deviceId, platform);

      debugPrint('New token: ${response.accessToken}');
      debugPrint('User: ${response.user.id}');

      setAuthToken(response.accessToken);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
                  AppButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    icon: Icons.g_mobiledata,
                    label: 'Continue with Google',
                    isLoading: _isLoading,
                    fullWidth: true,
                    // Simulate Google Button Style
                    variant: AppButtonVariant.outline,
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.textPrimaryLight,
                  ),
                  const SizedBox(height: 12),
                  // Apple button
                  AppButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    icon: Icons.apple,
                    label: 'Continue with Apple',
                    isLoading: _isLoading,
                    fullWidth: true,
                    // Simulate Apple Button Style
                    variant: AppButtonVariant.primary,
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
}
