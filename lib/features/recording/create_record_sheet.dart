import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/bouncing_button.dart';
import '../../navigation/routes.dart';
import '../../theme/colors.dart';
import 'widgets/recording_modal.dart';

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
                    'New recording',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Close',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _PrimaryRecordButton(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  final meetingId = await RecordingModal.show(context);

                  if (meetingId != null && meetingId.isNotEmpty) {
                    navigator.pushNamed(
                      AppRoutes.recordDetail,
                      arguments: meetingId,
                    );
                  }
                },
              ),

              const SizedBox(height: 12),

              // Secondary actions - Grid layout
              // Row(
              //   children: [
              //     Expanded(
              //       child: _SecondaryOptionCard(
              //         icon: Icons.calendar_month,
              //         iconBackgroundColor: const Color(
              //           0xFF6366F1,
              //         ).withValues(alpha: 0.2),
              //         iconColor: const Color(0xFF818CF8),
              //         title: 'Đặt lịch ghi âm',
              //         onTap: () {
              //           Navigator.pop(context);
              //           // TODO: Schedule recording
              //         },
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: _SecondaryOptionCard(
              //         icon: Icons.upload_file,
              //         iconBackgroundColor: const Color(
              //           0xFFF97316,
              //         ).withValues(alpha: 0.2),
              //         iconColor: const Color(0xFFFB923C),
              //         title: 'Nhập âm thanh',
              //         onTap: () {
              //           Navigator.pop(context);
              //           // TODO: Import audio
              //         },
              //       ),
              //     ),
              //   ],
              // ),
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
    return BouncingButton(
      semanticLabel: 'Start recording now, tap to begin',
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start recording now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to begin',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.white.withValues(alpha: 0.7),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
