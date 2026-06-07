import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Modern Badge Component
/// Inspired by Linear, Stripe, and shadcn/ui
class Badge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final BadgeVariant variant;

  const Badge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.variant = BadgeVariant.default_,
  });

  factory Badge.primary(String label) {
    return Badge(label: label, variant: BadgeVariant.primary);
  }

  factory Badge.secondary(String label) {
    return Badge(label: label, variant: BadgeVariant.secondary);
  }

  factory Badge.success(String label) {
    return Badge(label: label, variant: BadgeVariant.success);
  }

  factory Badge.warning(String label) {
    return Badge(label: label, variant: BadgeVariant.warning);
  }

  factory Badge.error(String label) {
    return Badge(label: label, variant: BadgeVariant.error);
  }

  factory Badge.info(String label) {
    return Badge(label: label, variant: BadgeVariant.info);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color txtColor;

    switch (variant) {
      case BadgeVariant.primary:
        bgColor = theme.colorScheme.primaryContainer;
        txtColor = theme.colorScheme.primary;
        break;
      case BadgeVariant.secondary:
        bgColor = theme.colorScheme.secondaryContainer;
        txtColor = theme.colorScheme.secondary;
        break;
      case BadgeVariant.success:
        bgColor = theme.brightness == Brightness.light
            ? const Color(0xFFD1FAE5)
            : const Color(0xFF065F46);
        txtColor = theme.brightness == Brightness.light
            ? const Color(0xFF059669)
            : const Color(0xFF34D399);
        break;
      case BadgeVariant.warning:
        bgColor = theme.brightness == Brightness.light
            ? const Color(0xFFFEF3C7)
            : const Color(0xFF78350F);
        txtColor = theme.brightness == Brightness.light
            ? const Color(0xFFD97706)
            : const Color(0xFFFBBF24);
        break;
      case BadgeVariant.error:
        bgColor = theme.brightness == Brightness.light
            ? const Color(0xFFFEE2E2)
            : const Color(0xFF7F1D1D);
        txtColor = theme.brightness == Brightness.light
            ? const Color(0xFFDC2626)
            : const Color(0xFFF87171);
        break;
      case BadgeVariant.info:
        bgColor = theme.brightness == Brightness.light
            ? const Color(0xFFE0F2FE)
            : const Color(0xFF0C4A6E);
        txtColor = theme.brightness == Brightness.light
            ? const Color(0xFF0284C7)
            : const Color(0xFF38BDF8);
        break;
      case BadgeVariant.default_:
        bgColor = theme.colorScheme.surfaceVariant;
        txtColor = theme.colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: textColor ?? txtColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor ?? txtColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum BadgeVariant {
  default_,
  primary,
  secondary,
  success,
  warning,
  error,
  info,
}
