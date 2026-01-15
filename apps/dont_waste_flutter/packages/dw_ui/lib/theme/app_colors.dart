import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  AppColors._();

  // Primary - Green (sustainability theme)
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primarySurface = Color(0xFFE8F5E9);

  // Secondary - Orange (urgency/action)
  static const Color secondary = Color(0xFFFF6D00);
  static const Color secondaryLight = Color(0xFFFF9E40);
  static const Color secondaryDark = Color(0xFFE65100);
  static const Color secondarySurface = Color(0xFFFFF3E0);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Urgency colors
  static const Color urgent = Color(0xFFE53935);
  static const Color expiringSoon = Color(0xFFFF9800);
  static const Color available = Color(0xFF4CAF50);

  // Neutral palette
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Status colors
  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusExpired = Color(0xFF9E9E9E);
  static const Color statusCancelled = Color(0xFFE53935);
  static const Color statusAccepted = Color(0xFF2196F3);
  static const Color statusRejected = Color(0xFFE53935);

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient urgentGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
