import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

class RecordingPlaceholderTab extends StatelessWidget {
  const RecordingPlaceholderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.cardDark.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.graphic_eq,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            // Message
            Text(
              'Đang ghi âm, nội dung sẽ hiển thị sau',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
