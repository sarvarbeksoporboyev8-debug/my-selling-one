import 'package:flutter/material.dart';

import 'colors.dart';

/// App theme configuration
abstract class DwTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: DwColors.primary,
          secondary: DwColors.secondary,
          surface: DwColors.surface,
          error: DwColors.error,
        ),
        scaffoldBackgroundColor: DwColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: DwColors.surface,
          foregroundColor: DwColors.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: DwColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: DwColors.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: DwColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DwColors.border),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DwColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: DwColors.primary,
            side: const BorderSide(color: DwColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: DwColors.primary,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: DwColors.surface,
          indicatorColor: DwColors.primaryLight,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
        dividerTheme: const DividerThemeData(
          color: DwColors.border,
          thickness: 1,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: DwColors.primary,
          secondary: DwColors.secondary,
          surface: const Color(0xFF1E1E1E),
          error: DwColors.error,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF333333)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DwColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          indicatorColor: Color(0xFF1B5E20),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      );
}
