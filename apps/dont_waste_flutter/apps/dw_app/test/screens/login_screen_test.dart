import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_app/screens/auth/login_screen.dart';
import 'package:dw_ui/dw_ui.dart';

import '../test_helpers.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('displays email field', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const LoginScreen()),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('displays password field', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const LoginScreen()),
      );

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('displays sign in button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const LoginScreen()),
      );

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('displays forgot password link', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const LoginScreen()),
      );

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('displays sign up link', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const LoginScreen()),
      );

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('validates empty email', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const LoginScreen()),
      );

      // Find and tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('validates empty password', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const LoginScreen()),
      );

      // Enter email but not password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email'),
        'test@example.com',
      );

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const LoginScreen()),
      );

      // Initially password should be obscured
      final passwordField = find.widgetWithText(TextFormField, 'Enter your password');
      expect(passwordField, findsOneWidget);

      // Find and tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      // Icon should change to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
