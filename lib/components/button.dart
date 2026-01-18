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
      size: AppButtonSize.medium,
      variant: AppButtonVariant.secondary,
      backgroundColor: AppColors.cardDark,
    );
  }
}
