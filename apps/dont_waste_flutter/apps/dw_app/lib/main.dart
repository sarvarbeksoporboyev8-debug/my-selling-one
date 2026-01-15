import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dw_ui/dw_ui.dart';

import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

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
      theme: DwTheme.light,
      darkTheme: DwTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
