import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dw_ui/dw_ui.dart';

/// Wraps a widget with necessary providers for testing
Widget createTestWidget(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      theme: DwTheme.light,
      home: Scaffold(body: child),
    ),
  );
}

/// Wraps a widget with MaterialApp for basic widget tests
Widget createMaterialTestWidget(Widget child) {
  return MaterialApp(
    theme: DwTheme.light,
    home: Scaffold(body: child),
  );
}

/// Pumps widget and waits for animations to settle
Future<void> pumpAndSettle(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}
