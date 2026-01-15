import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_ui/dw_ui.dart';

/// Edit listing screen placeholder
class EditListingScreen extends ConsumerWidget {
  final int listingId;

  const EditListingScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
      ),
      body: const Center(
        child: DwEmptyState(
          icon: Icons.edit,
          title: 'Edit Listing',
          message: 'Edit listing form will be implemented here.',
        ),
      ),
    );
  }
}
