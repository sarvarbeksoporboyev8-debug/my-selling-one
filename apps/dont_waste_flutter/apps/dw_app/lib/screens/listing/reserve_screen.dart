import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

/// Reserve screen for creating a reservation
class ReserveScreen extends ConsumerStatefulWidget {
  final int listingId;

  const ReserveScreen({super.key, required this.listingId});

  @override
  ConsumerState<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends ConsumerState<ReserveScreen> {
  double _quantity = 1;
  DateTime? _preferredPickupTime;
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleReserve() async {
    setState(() => _isLoading = true);

    try {
      final reservation = await ref.read(reservationsProvider.notifier).createReservation(
            listingId: widget.listingId,
            quantity: _quantity,
            notes: _messageController.text.isNotEmpty ? _messageController.text : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation created!')),
        );
        context.go(AppRoutes.reservationDetailPath(reservation.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: DwColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserve'),
      ),
      body: listingAsync.when(
        data: (listing) {
          final totalPrice = listing.price * _quantity;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(DwSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing summary
                DwListingListTile(
                  listing: listing,
                  onTap: () => context.pop(),
                ),
                const SizedBox(height: DwSpacing.xl),

                // Quantity selector
                Text('Quantity', style: DwTextStyles.titleMedium),
                const SizedBox(height: DwSpacing.sm),
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Expanded(
                      child: Slider(
                        value: _quantity,
                        min: 1,
                        max: listing.quantity.toDouble(),
                        divisions: listing.quantity.toInt() - 1,
                        label: _quantity.toStringAsFixed(0),
                        onChanged: (value) {
                          setState(() => _quantity = value);
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _quantity < listing.quantity
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    '${_quantity.toStringAsFixed(0)} ${listing.unit}',
                    style: DwTextStyles.titleLarge,
                  ),
                ),
                const SizedBox(height: DwSpacing.lg),

                // Preferred pickup time
                Text('Preferred Pickup Time', style: DwTextStyles.titleMedium),
                const SizedBox(height: DwSpacing.sm),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: listing.expiresAt ?? DateTime.now().add(const Duration(days: 7)),
                    );
                    if (date != null && mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _preferredPickupTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DwSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: DwColors.border),
                      borderRadius: BorderRadius.circular(DwRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: DwColors.textSecondary),
                        const SizedBox(width: DwSpacing.sm),
                        Text(
                          _preferredPickupTime != null
                              ? _formatDateTime(_preferredPickupTime!)
                              : 'Select preferred time (optional)',
                          style: DwTextStyles.bodyMedium.copyWith(
                            color: _preferredPickupTime != null
                                ? DwColors.textPrimary
                                : DwColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DwSpacing.lg),

                // Message
                Text('Message to Seller', style: DwTextStyles.titleMedium),
                const SizedBox(height: DwSpacing.sm),
                DwTextField(
                  controller: _messageController,
                  hint: 'Add a message (optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: DwSpacing.xl),

                // Price summary
                Container(
                  padding: const EdgeInsets.all(DwSpacing.md),
                  decoration: BoxDecoration(
                    color: DwColors.surface,
                    borderRadius: BorderRadius.circular(DwRadius.md),
                    border: Border.all(color: DwColors.border),
                  ),
                  child: Column(
                    children: [
                      _PriceRow(
                        label: 'Price per ${listing.unit}',
                        value: '\$${listing.price.toStringAsFixed(2)}',
                      ),
                      _PriceRow(
                        label: 'Quantity',
                        value: '${_quantity.toStringAsFixed(0)} ${listing.unit}',
                      ),
                      const Divider(),
                      _PriceRow(
                        label: 'Total',
                        value: '\$${totalPrice.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DwSpacing.lg),

                // Reserve button
                DwButton(
                  onPressed: _isLoading ? null : _handleReserve,
                  isLoading: _isLoading,
                  child: const Text('Confirm Reservation'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DwErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(listingDetailProvider(widget.listingId)),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DwSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? DwTextStyles.titleSmall : DwTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: isBold
                ? DwTextStyles.titleSmall.copyWith(color: DwColors.primary)
                : DwTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
