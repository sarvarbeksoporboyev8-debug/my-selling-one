import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Extensions on BuildContext for responsive design
extension ContextExtensions on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if mobile layout
  bool get isMobile => screenWidth < AppSpacing.mobileBreakpoint;

  /// Check if tablet layout
  bool get isTablet =>
      screenWidth >= AppSpacing.mobileBreakpoint &&
      screenWidth < AppSpacing.tabletBreakpoint;

  /// Check if desktop layout
  bool get isDesktop => screenWidth >= AppSpacing.tabletBreakpoint;

  /// Check if wide layout (tablet or desktop)
  bool get isWide => screenWidth >= AppSpacing.mobileBreakpoint;

  /// Get responsive value based on screen size
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(message, isError: true);
  }
}
