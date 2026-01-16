import 'package:flutter/material.dart';

/// Premium Design System - Modern 2025 UI tokens
/// Supports both light and dark modes with consistent premium styling

class PremiumTheme {
  final bool isDark;
  
  const PremiumTheme._({required this.isDark});
  
  static const light = PremiumTheme._(isDark: false);
  static const dark = PremiumTheme._(isDark: true);

  // ============ COLORS ============
  
  // Background colors
  Color get background => isDark ? const Color(0xFF0A0A0B) : const Color(0xFFF8F9FA);
  Color get surface => isDark ? const Color(0xFF141416) : Colors.white;
  Color get surfaceSecondary => isDark ? const Color(0xFF1C1C1F) : const Color(0xFFF1F3F5);
  Color get surfaceTertiary => isDark ? const Color(0xFF242428) : const Color(0xFFE9ECEF);
  
  // Card colors with subtle elevation feel
  Color get cardBackground => isDark ? const Color(0xFF18181B) : Colors.white;
  Color get cardBackgroundElevated => isDark ? const Color(0xFF1F1F23) : Colors.white;
  
  // Border colors
  Color get border => isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
  Color get borderSubtle => isDark ? const Color(0xFF1F1F23) : const Color(0xFFF3F4F6);
  
  // Text colors
  Color get textPrimary => isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B);
  Color get textSecondary => isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
  Color get textTertiary => isDark ? const Color(0xFF71717A) : const Color(0xFFA1A1AA);
  Color get textMuted => isDark ? const Color(0xFF52525B) : const Color(0xFFD4D4D8);
  
  // Accent colors
  Color get accent => const Color(0xFF3B82F6); // Blue
  Color get accentLight => isDark ? const Color(0xFF1D4ED8) : const Color(0xFFDBEAFE);
  Color get success => const Color(0xFF22C55E);
  Color get successLight => isDark ? const Color(0xFF166534) : const Color(0xFFDCFCE7);
  Color get warning => const Color(0xFFF59E0B);
  Color get warningLight => isDark ? const Color(0xFF92400E) : const Color(0xFFFEF3C7);
  Color get error => const Color(0xFFEF4444);
  Color get errorLight => isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2);
  
  // Special colors
  Color get orange => const Color(0xFFF97316);
  Color get purple => const Color(0xFF8B5CF6);
  Color get pink => const Color(0xFFEC4899);
  Color get teal => const Color(0xFF14B8A6);
  
  // Overlay colors
  Color get overlay => isDark 
      ? Colors.black.withOpacity(0.6) 
      : Colors.black.withOpacity(0.4);
  Color get overlayLight => isDark 
      ? Colors.black.withOpacity(0.3) 
      : Colors.black.withOpacity(0.2);

  // ============ SHADOWS ============
  
  List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  
  List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.6 : 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // ============ SPACING ============
  
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space14 = 14;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space28 = 28;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space56 = 56;
  static const double space64 = 64;

  // ============ RADII ============
  
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusFull = 999;

  // ============ TYPOGRAPHY ============
  
  // Display - for hero text
  TextStyle get displayLarge => TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -1.0,
    height: 1.1,
  );
  
  TextStyle get displayMedium => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  // Headlines
  TextStyle get headlineLarge => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );
  
  TextStyle get headlineMedium => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  TextStyle get headlineSmall => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.35,
  );
  
  // Titles
  TextStyle get titleLarge => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  TextStyle get titleMedium => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  TextStyle get titleSmall => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  // Body
  TextStyle get bodyLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );
  
  TextStyle get bodyMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );
  
  TextStyle get bodySmall => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );
  
  // Labels
  TextStyle get labelLarge => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );
  
  TextStyle get labelMedium => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );
  
  TextStyle get labelSmall => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    letterSpacing: 0.3,
    height: 1.4,
  );
  
  // Caption
  TextStyle get caption => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.4,
  );

  // ============ GRADIENTS ============
  
  LinearGradient get primaryGradient => LinearGradient(
    colors: [accent, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  LinearGradient get warmGradient => LinearGradient(
    colors: [orange, pink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  LinearGradient get coolGradient => LinearGradient(
    colors: [teal, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  LinearGradient get surfaceGradient => LinearGradient(
    colors: isDark 
        ? [const Color(0xFF1C1C1F), const Color(0xFF141416)]
        : [Colors.white, const Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Extension to easily access theme in widgets
extension PremiumThemeContext on BuildContext {
  PremiumTheme get premium {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? PremiumTheme.dark : PremiumTheme.light;
  }
}
