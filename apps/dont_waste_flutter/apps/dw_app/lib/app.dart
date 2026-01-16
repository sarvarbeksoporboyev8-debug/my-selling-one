import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_ui/dw_ui.dart';

import 'providers/providers.dart';
import 'routing/app_router.dart';

/// Main application widget
class DontWasteApp extends ConsumerWidget {
  const DontWasteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: "Don't Waste",
      debugShowCheckedModeBanner: false,
      theme: DwTheme.light,
      darkTheme: DwTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
