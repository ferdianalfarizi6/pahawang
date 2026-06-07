import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Modern Text Field Component
/// Inspired by Linear, Stripe, and shadcn/ui
class ModernTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool isRequired;

  const ModernTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.textInputAction,
    this.inputFormatters,
    this.focusNode,
    this.isRequired = false,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _isFocused
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTheme.space8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          focusNode: _focusNode,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: _isFocused
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      widget.suffixIcon,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: widget.onSuffixIconPressed,
                  )
                : null,
            counterText: '',
            filled: true,
            fillColor: widget.enabled
                ? theme.colorScheme.surfaceVariant
                : theme.colorScheme.surfaceVariant.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space16,
              vertical: AppTheme.space12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
            ),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
