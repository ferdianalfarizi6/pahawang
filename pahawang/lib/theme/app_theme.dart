import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

/// Centralized Theme System for Pahawang App
/// Inspired by Linear, Stripe, Notion, Vercel, and shadcn/ui
class AppTheme {
  AppTheme._();

  // ============================================
  // COLOR PALETTE - Modern Premium Design
  // ============================================
  
  /// Light Theme Colors
  static const Color _lightPrimary = Color(0xFF0066FF); // Vibrant Blue
  static const Color _lightPrimaryContainer = Color(0xFFE5F0FF);
  static const Color _lightSecondary = Color(0xFF6366F1); // Indigo
  static const Color _lightSecondaryContainer = Color(0xFFEEF2FF);
  static const Color _lightTertiary = Color(0xFF10B981); // Emerald
  static const Color _lightTertiaryContainer = Color(0xFFECFDF5);
  
  // Backgrounds
  static const Color _lightBackground = Color(0xFFFAFAFA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceVariant = Color(0xFFF5F5F5);
  
  // Typography
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightOnBackground = Color(0xFF0A0A0A);
  static const Color _lightOnSurface = Color(0xFF171717);
  static const Color _lightOnSurfaceVariant = Color(0xFF737373);
  
  // Semantic
  static const Color _lightError = Color(0xFFDC2626);
  static const Color _lightErrorContainer = Color(0xFFFEE2E2);
  static const Color _lightSuccess = Color(0xFF059669);
  static const Color _lightSuccessContainer = Color(0xFFD1FAE5);
  static const Color _lightWarning = Color(0xFFD97706);
  static const Color _lightWarningContainer = Color(0xFFFEF3C7);
  static const Color _lightInfo = Color(0xFF0284C7);
  static const Color _lightInfoContainer = Color(0xFFE0F2FE);
  
  // Borders & Dividers
  static const Color _lightOutline = Color(0xFFE5E5E5);
  static const Color _lightOutlineVariant = Color(0xFFF0F0F0);
  static const Color _lightDivider = Color(0xFFE5E5E5);
  
  /// Dark Theme Colors
  static const Color _darkPrimary = Color(0xFF3B82F6); // Lighter Blue for dark mode
  static const Color _darkPrimaryContainer = Color(0xFF1E3A5F);
  static const Color _darkSecondary = Color(0xFF818CF8);
  static const Color _darkSecondaryContainer = Color(0xFF1E1B4B);
  static const Color _darkTertiary = Color(0xFF34D399);
  static const Color _darkTertiaryContainer = Color(0xFF064E3B);
  
  // Backgrounds
  static const Color _darkBackground = Color(0xFF0A0A0A);
  static const Color _darkSurface = Color(0xFF171717);
  static const Color _darkSurfaceVariant = Color(0xFF262626);
  
  // Typography
  static const Color _darkOnPrimary = Color(0xFFFFFFFF);
  static const Color _darkOnSecondary = Color(0xFFFFFFFF);
  static const Color _darkOnBackground = Color(0xFFFAFAFA);
  static const Color _darkOnSurface = Color(0xFFE5E5E5);
  static const Color _darkOnSurfaceVariant = Color(0xFFA3A3A3);
  
  // Semantic
  static const Color _darkError = Color(0xFFF87171);
  static const Color _darkErrorContainer = Color(0xFF7F1D1D);
  static const Color _darkSuccess = Color(0xFF34D399);
  static const Color _darkSuccessContainer = Color(0xFF065F46);
  static const Color _darkWarning = Color(0xFFFBBF24);
  static const Color _darkWarningContainer = Color(0xFF78350F);
  static const Color _darkInfo = Color(0xFF38BDF8);
  static const Color _darkInfoContainer = Color(0xFF0C4A6E);
  
  // Borders & Dividers
  static const Color _darkOutline = Color(0xFF404040);
  static const Color _darkOutlineVariant = Color(0xFF262626);
  static const Color _darkDivider = Color(0xFF262626);
  
  // ============================================
  // TYPOGRAPHY SCALE
  // ============================================
  
  static TextTheme _buildTextTheme(Color onBackground, Color onSurfaceVariant) {
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: onBackground,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: onBackground,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: onBackground,
        height: 1.2,
      ),
      
      // Headline
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: onBackground,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: onBackground,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: onBackground,
        height: 1.35,
      ),
      
      // Title
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: onBackground,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: onBackground,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onBackground,
        height: 1.45,
      ),
      
      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: onBackground,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: onBackground,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: onSurfaceVariant,
        height: 1.5,
      ),
      
      // Label
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onBackground,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: onBackground,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: onSurfaceVariant,
        height: 1.4,
      ),
    );
  }
  
  // ============================================
  // SPACING SYSTEM
  // ============================================
  
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;
  
  // ============================================
  // BORDER RADIUS
  // ============================================
  
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radiusFull = 9999.0;
  
  // ============================================
  // SHADOWS
  // ============================================
  
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  static List<BoxShadow> get shadowGlow => [
    BoxShadow(
      color: _lightPrimary.withOpacity(0.3),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];
  
  // ============================================
  // LIGHT THEME
  // ============================================
  
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      primaryContainer: _lightPrimaryContainer,
      secondary: _lightSecondary,
      onSecondary: _lightOnSecondary,
      secondaryContainer: _lightSecondaryContainer,
      tertiary: _lightTertiary,
      tertiaryContainer: _lightTertiaryContainer,
      error: _lightError,
      errorContainer: _lightErrorContainer,
      background: _lightBackground,
      onBackground: _lightOnBackground,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      surfaceVariant: _lightSurfaceVariant,
      onSurfaceVariant: _lightOnSurfaceVariant,
      outline: _lightOutline,
      outlineVariant: _lightOutlineVariant,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(_lightOnBackground, _lightOnSurfaceVariant),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _lightOnSurface,
        ),
        iconTheme: IconThemeData(color: _lightOnSurface),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          side: BorderSide(color: _lightOutline, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: _lightOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: _lightOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: _lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: _lightError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: _lightError, width: 2),
        ),
        labelStyle: TextStyle(color: _lightOnSurfaceVariant, fontSize: 14),
        hintStyle: TextStyle(color: _lightOnSurfaceVariant, fontSize: 14),
        floatingLabelStyle: TextStyle(color: _lightPrimary, fontSize: 14),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: _lightDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: _lightOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: _lightOnSurface,
        size: 24,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: _lightBackground,
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        elevation: 0,
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        elevation: 0,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _lightSurfaceVariant,
        selectedColor: _lightPrimaryContainer,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightPrimary;
          }
          return _lightSurfaceVariant;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightPrimary;
          }
          return _lightOnSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightPrimary.withOpacity(0.4);
          }
          return _lightOutline;
        }),
      ),
    );
  }
  
  // ============================================
  // DARK THEME
  // ============================================
  
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: _darkPrimaryContainer,
      secondary: _darkSecondary,
      onSecondary: _darkOnSecondary,
      secondaryContainer: _darkSecondaryContainer,
      tertiary: _darkTertiary,
      tertiaryContainer: _darkTertiaryContainer,
      error: _darkError,
      errorContainer: _darkErrorContainer,
      background: _darkBackground,
      onBackground: _darkOnBackground,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      surfaceVariant: _darkSurfaceVariant,
      onSurfaceVariant: _darkOnSurfaceVariant,
      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(_darkOnBackground, _darkOnSurfaceVariant),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _darkOnSurface,
        ),
        iconTheme: IconThemeData(color: _darkOnSurface),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: BorderSide(color: _darkOutline, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: _darkOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: _darkOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: _darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: _darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: _darkError, width: 2),
        ),
        labelStyle: TextStyle(color: _darkOnSurfaceVariant, fontSize: 14),
        hintStyle: TextStyle(color: _darkOnSurfaceVariant, fontSize: 14),
        floatingLabelStyle: TextStyle(color: _darkPrimary, fontSize: 14),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: _darkDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: _darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: _darkOnSurface,
        size: 24,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: _darkBackground,
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        elevation: 0,
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        elevation: 0,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurfaceVariant,
        selectedColor: _darkPrimaryContainer,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkPrimary;
          }
          return _darkSurfaceVariant;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkPrimary;
          }
          return _darkOnSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkPrimary.withOpacity(0.4);
          }
          return _darkOutline;
        }),
      ),
    );
  }
  
  // ============================================
  // GRADIENTS
  // ============================================
  
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [_lightPrimary, _lightSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get sunsetGradient => const LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get oceanGradient => const LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get glassGradient => LinearGradient(
    colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
