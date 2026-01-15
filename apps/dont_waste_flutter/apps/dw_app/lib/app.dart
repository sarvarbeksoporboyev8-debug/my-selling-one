import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_ui/dw_ui.dart';

import 'routing/app_router.dart';

/// Main application widget
class DontWasteApp extends ConsumerWidget {
  const DontWasteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: "Don't Waste",
      debugShowCheckedModeBanner: false,
      theme: DwTheme.light,
      darkTheme: DwTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
