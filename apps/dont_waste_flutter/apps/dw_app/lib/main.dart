import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dw_ui/dw_ui.dart';

import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    const ProviderScope(
      child: DontWasteApp(),
    ),
  );
}

class DontWasteApp extends ConsumerWidget {
  const DontWasteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: "Don't Waste",
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }

  ThemeData _buildLightTheme() {
    const light = PremiumTheme.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: light.accent,
        secondary: light.purple,
        surface: light.surface,
        error: light.error,
      ),
      scaffoldBackgroundColor: light.background,
      appBarTheme: AppBarTheme(
        backgroundColor: light.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: light.textPrimary),
        titleTextStyle: light.headlineSmall,
      ),
      cardTheme: CardTheme(
        color: light.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
          side: BorderSide(color: light.border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: light.border,
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: light.displayLarge,
        displayMedium: light.displayMedium,
        headlineLarge: light.headlineLarge,
        headlineMedium: light.headlineMedium,
        headlineSmall: light.headlineSmall,
        titleLarge: light.titleLarge,
        titleMedium: light.titleMedium,
        titleSmall: light.titleSmall,
        bodyLarge: light.bodyLarge,
        bodyMedium: light.bodyMedium,
        bodySmall: light.bodySmall,
        labelLarge: light.labelLarge,
        labelMedium: light.labelMedium,
        labelSmall: light.labelSmall,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const dark = PremiumTheme.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: dark.accent,
        secondary: dark.purple,
        surface: dark.surface,
        error: dark.error,
      ),
      scaffoldBackgroundColor: dark.background,
      appBarTheme: AppBarTheme(
        backgroundColor: dark.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: dark.textPrimary),
        titleTextStyle: dark.headlineSmall,
      ),
      cardTheme: CardTheme(
        color: dark.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
          side: BorderSide(color: dark.border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dark.border,
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: dark.displayLarge,
        displayMedium: dark.displayMedium,
        headlineLarge: dark.headlineLarge,
        headlineMedium: dark.headlineMedium,
        headlineSmall: dark.headlineSmall,
        titleLarge: dark.titleLarge,
        titleMedium: dark.titleMedium,
        titleSmall: dark.titleSmall,
        bodyLarge: dark.bodyLarge,
        bodyMedium: dark.bodyMedium,
        bodySmall: dark.bodySmall,
        labelLarge: dark.labelLarge,
        labelMedium: dark.labelMedium,
        labelSmall: dark.labelSmall,
      ),
    );
  }
}
