import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../routing/app_routes.dart';

/// My listings screen for sellers
class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement my listings provider
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.createListing),
          ),
        ],
      ),
      body: DwEmptyState(
        icon: Icons.store_outlined,
        title: 'No listings yet',
        message: 'Start selling your surplus food to reduce waste and earn money.',
        action: DwButton(
          onPressed: () => context.push(AppRoutes.createListing),
          child: const Text('Create Listing'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createListing),
        icon: const Icon(Icons.add),
        label: const Text('New Listing'),
      ),
    );
  }
}
