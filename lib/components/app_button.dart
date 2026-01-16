import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDestructive = false,
    this.fullWidth = false,
    this.backgroundColor, // Override if needed
    this.foregroundColor, // Override if needed
  });

  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDestructive;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  // Standardization Constants
  static const double _radius = 16.0;

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return 32.0;
      case AppButtonSize.medium:
        return 48.0;
      case AppButtonSize.large:
        return 56.0;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16.0;
      case AppButtonSize.medium:
        return 20.0;
      case AppButtonSize.large:
        return 24.0;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 12.0;
      case AppButtonSize.medium:
        return 14.0;
      case AppButtonSize.large:
        return 16.0;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  Color get _backgroundColor {
    if (backgroundColor != null) return backgroundColor!;
    if (onPressed == null) return AppColors.cardDark.withValues(alpha: 0.5);

    if (isDestructive && variant == AppButtonVariant.primary) {
      return AppColors.error;
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return AppColors.cardDark;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    if (foregroundColor != null) return foregroundColor!;
    if (onPressed == null) return AppColors.textMuted;

    if (isDestructive && variant != AppButtonVariant.primary) {
      return AppColors.error;
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.white;
      case AppButtonVariant.secondary:
        return AppColors.textPrimary;
      case AppButtonVariant.outline:
        return AppColors.textPrimary;
      case AppButtonVariant.ghost:
        return AppColors.textSecondary;
    }
  }

  BorderSide get _borderSide {
    if (variant == AppButtonVariant.outline) {
      if (onPressed == null) {
        return BorderSide(color: AppColors.dividerDark.withValues(alpha: 0.3));
      }
      return const BorderSide(color: AppColors.dividerDark);
    }
    return BorderSide.none;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = _backgroundColor;
    final effectiveForegroundColor = _foregroundColor;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
            ),
          ),
          if (label != null) SizedBox(width: size == AppButtonSize.small ? 4 : 8),
        ] else if (icon != null) ...[
          Icon(icon, size: _iconSize, color: effectiveForegroundColor),
          if (label != null) SizedBox(width: size == AppButtonSize.small ? 4 : 8),
        ],
        if (label != null)
          Text(
            label!,
            style: TextStyle(
              color: effectiveForegroundColor,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
      ],
    );

    // InkWell with custom ripple
    final buttonContent = Material(
      color: effectiveBackgroundColor,
      borderRadius: BorderRadius.circular(_radius),
      shape: variant == AppButtonVariant.outline
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius),
              side: _borderSide,
            )
          : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(_radius),
        splashColor: effectiveForegroundColor.withValues(alpha: 0.1),
        highlightColor: effectiveForegroundColor.withValues(alpha: 0.05),
        child: Container(
          height: _height,
          padding: _padding,
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: buttonContent);
    }

    return buttonContent;
  }
}
