import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Modern Card Component
/// Inspired by Linear, Stripe, and shadcn/ui
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool isBordered;
  final BoxBorder? border;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.isBordered = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: padding ?? const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.colorScheme.surface,
              borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
              border: border ?? (isBordered
                  ? Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    )
                  : null),
              boxShadow: elevation != null && elevation! > 0
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: elevation! * 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : AppTheme.shadowMd,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Modern Card with Header
class ModernCardWithHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const ModernCardWithHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernCard(
      margin: margin,
      onTap: onTap,
      backgroundColor: backgroundColor,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.space16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppTheme.space4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.space16),
            child: child,
          ),
        ],
      ),
    );
  }
}
