import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'app_button.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: onPressed,
      icon: Icons.play_arrow,
      size: AppButtonSize.small,
      variant: AppButtonVariant.secondary,
      backgroundColor: AppColors.cardDark,
      // Custom border behavior for PlayButton using AppButton might need adjustments
      // or we accept the standard AppButton look which is cleaner.
      // Based on standardization, we should stick to standard if possible.
    );
  }
}
