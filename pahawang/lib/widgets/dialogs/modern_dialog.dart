import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../buttons/primary_button.dart';
import '../buttons/ghost_button.dart';

/// Modern Dialog Component
/// Inspired by Linear, Stripe, and shadcn/ui
class ModernDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? content;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final bool isDestructive;
  final IconData? icon;

  const ModernDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    this.primaryActionText,
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.isDestructive = false,
    this.icon,
  });

  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    String? subtitle,
    String? primaryActionText,
    String? secondaryActionText,
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ModernDialog(
        title: title,
        subtitle: subtitle,
        primaryActionText: primaryActionText ?? 'Confirm',
        secondaryActionText: secondaryActionText ?? 'Cancel',
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.space8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppTheme.space12),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.space16),
          ],
          if (content != null) content!,
        ],
      ),
      actions: [
        if (secondaryActionText != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.space24,
              right: AppTheme.space8,
              bottom: AppTheme.space16,
            ),
            child: GhostButton(
              text: secondaryActionText!,
              onPressed: onSecondaryAction ??
                  () => Navigator.of(context).pop(false),
            ),
          ),
        if (primaryActionText != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.space8,
              right: AppTheme.space24,
              bottom: AppTheme.space16,
            ),
            child: PrimaryButton(
              text: primaryActionText!,
              onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(true),
              isFullWidth: false,
            ),
          ),
      ],
    );
  }
}
