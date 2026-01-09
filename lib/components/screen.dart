import 'package:flutter/material.dart';

import '../theme/colors.dart';

class Screen extends StatelessWidget {
  const Screen({super.key, required this.child, this.padding, this.backgroundColor});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: backgroundColor ?? AppColors.backgroundDark,
        child: Container(
          padding: padding,
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}
