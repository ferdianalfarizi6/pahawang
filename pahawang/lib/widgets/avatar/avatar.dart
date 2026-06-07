import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Modern Avatar Component
/// Inspired by Linear, Stripe, and shadcn/ui
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitials(theme);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder(theme);
          },
        ),
      );
    }

    if (name != null && name!.isNotEmpty) {
      return _buildInitials(theme);
    }

    return _buildPlaceholder(theme);
  }

  Widget _buildInitials(ThemeData theme) {
    final initials = _getInitials();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? _getBackgroundColor(theme),
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleMedium?.copyWith(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (name == null || name!.isEmpty) {
      return theme.colorScheme.primary;
    }

    final colors = [
      const Color(0xFF0066FF),
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

    final index = name!.hashCode % colors.length;
    return colors[index.abs()];
  }
}
