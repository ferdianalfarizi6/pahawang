import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Gradient Card Component
/// Inspired by Linear, Stripe, and shadcn/ui
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding,
    this.margin,
    this.onTap,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? EdgeInsets.zero,
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              gradient: gradient ?? AppTheme.primaryGradient,
              borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowGlow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
