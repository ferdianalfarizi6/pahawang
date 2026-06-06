import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Tropical Luxury Theme)
  static const Color primary = Color(0xFF0A84FF); // Vibrant Ocean Blue
  static const Color primaryDark = Color(0xFF0040DD); // Deep Marine Blue
  static const Color primaryLight = Color(0xFF5AC8FA); // Lagoon Teal
  static const Color accent = Color(0xFFFF9500); // Golden Sunset Orange
  static const Color accentLight = Color(0xFFFFCC00); // Bright Sunshine Yellow
  
  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF6F8FA); // Premium Clean Off-white
  static const Color cardBg = Color(0xFFFFFFFF); // Pure White Surface
  static const Color inputBg = Color(0xFFF1F3F5); // Soft Grey Form Field Background
  
  // Typography
  static const Color textDark = Color(0xFF1C1C1E); // Slate Black for high readability
  static const Color textMedium = Color(0xFF636366); // Mid tone grey for secondary text
  static const Color textLight = Color(0xFF8E8E93); // Light grey for captions/hints
  
  // Semantic Feedback
  static const Color success = Color(0xFF34C759); // iOS Emerald Green
  static const Color warning = Color(0xFFFF9500); // iOS Amber Orange
  static const Color danger = Color(0xFFFF3B30); // iOS Coral Red
  static const Color info = Color(0xFF007AFF); // iOS System Blue for info hints
  
  // Gradients
  static const Color gradientStart = Color(0xFF0A84FF);
  static const Color gradientEnd = Color(0xFF0040DD);
  static const List<Color> primaryGradient = [gradientStart, Color(0xFF0077B6), Color(0xFF00B4D8)];
  static const List<Color> sunsetGradient = [Color(0xFFFF9500), Color(0xFFFF6B35)];
  static const List<Color> glassGradient = [Colors.white24, Colors.white10];

  // Shadows
  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> intenseShadow = [
    BoxShadow(
      color: const Color(0xFF0A84FF).withOpacity(0.24),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
}