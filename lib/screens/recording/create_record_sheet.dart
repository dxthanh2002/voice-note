import 'package:flutter/material.dart';

import '../../navigation/app_routes.dart';
import '../../theme/colors.dart';

class CreateRecordSheet extends StatelessWidget {
  const CreateRecordSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),

              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bản ghi mới',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.close,
                          color: AppColors.textMuted,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Primary action - Start Recording Now
              _PrimaryRecordButton(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.recordDetail);
                },
              ),
              const SizedBox(height: 12),

              // Secondary actions - Grid layout
              Row(
                children: [
                  Expanded(
                    child: _SecondaryOptionCard(
                      icon: Icons.calendar_month,
                      iconBackgroundColor: const Color(
                        0xFF6366F1,
                      ).withValues(alpha: 0.2),
                      iconColor: const Color(0xFF818CF8),
                      title: 'Đặt lịch ghi âm',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Schedule recording
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SecondaryOptionCard(
                      icon: Icons.upload_file,
                      iconBackgroundColor: const Color(
                        0xFFF97316,
                      ).withValues(alpha: 0.2),
                      iconColor: const Color(0xFFFB923C),
                      title: 'Nhập âm thanh',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Import audio
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Primary recording button - large blue button with arrow
class _PrimaryRecordButton extends StatelessWidget {
  const _PrimaryRecordButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bắt đầu ghi âm ngay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chạm để bắt đầu',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward,
                color: Colors.white.withValues(alpha: 0.7),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary option card for Schedule and Import
class _SecondaryOptionCard extends StatelessWidget {
  const _SecondaryOptionCard({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundDark.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.dividerDark.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
