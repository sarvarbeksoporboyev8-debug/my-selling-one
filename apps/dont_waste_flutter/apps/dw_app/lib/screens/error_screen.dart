import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../routing/app_routes.dart';

/// Error screen for routing errors
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DwEmptyState(
          icon: Icons.error_outline,
          title: 'Page Not Found',
          message: error?.toString() ?? 'The page you are looking for does not exist.',
          action: DwButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go Home'),
          ),
        ),
      ),
    );
  }
}
