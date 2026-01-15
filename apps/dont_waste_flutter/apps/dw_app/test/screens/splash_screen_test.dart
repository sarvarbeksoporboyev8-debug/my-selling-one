import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_app/screens/auth/splash_screen.dart';

import '../test_helpers.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('displays app logo', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const SplashScreen()),
      );

      expect(find.byIcon(Icons.eco), findsOneWidget);
    });

    testWidgets('displays app name', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const SplashScreen()),
      );

      expect(find.text("Don't Waste"), findsOneWidget);
    });

    testWidgets('displays tagline', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const SplashScreen()),
      );

      expect(find.text('Save food, save money'), findsOneWidget);
    });

    testWidgets('displays loading indicator', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const SplashScreen()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
