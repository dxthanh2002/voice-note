import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        hoverColor: AppColors.primary,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const Icon(
            Icons.play_arrow,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
