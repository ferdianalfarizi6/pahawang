import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  // Typography with curated hierarchy
  static TextStyle heading1 = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static TextStyle heading2 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.4,
    height: 1.3,
  );

  static TextStyle heading3 = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static TextStyle bodyText = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.5,
  );

  static TextStyle caption = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.4,
  );

  // Modern input field styling for form inputs
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.cardBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.danger, width: 1),
    ),
    labelStyle: const TextStyle(color: AppColors.textMedium, fontSize: 14),
    hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
  );

  // Reusable card decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(20),
    boxShadow: AppColors.premiumShadow,
  );

  static BoxDecoration gradientDecoration = const BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration sunsetGradientDecoration = const BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.sunsetGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}