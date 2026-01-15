import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

/// Reservation detail screen
class ReservationDetailScreen extends ConsumerWidget {
  final int reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationAsync = ref.watch(reservationDetailProvider(reservationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
      ),
      body: reservationAsync.when(
        data: (reservation) => _ReservationDetailContent(reservation: reservation),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DwErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(reservationDetailProvider(reservationId)),
        ),
      ),
    );
  }
}

class _ReservationDetailContent extends ConsumerWidget {
  final Reservation reservation;

  const _ReservationDetailContent({required this.reservation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _StatusCard(reservation: reservation),
          const SizedBox(height: DwSpacing.lg),

          // Listing info
          Text('Item', style: DwTextStyles.titleMedium),
          const SizedBox(height: DwSpacing.sm),
          DwListingListTile(
            listing: reservation.listing,
            onTap: () => context.push(
              AppRoutes.listingDetailPath(reservation.listing.id),
            ),
          ),
          const SizedBox(height: DwSpacing.lg),

          // Order details
          Text('Order Details', style: DwTextStyles.titleMedium),
          const SizedBox(height: DwSpacing.sm),
          _DetailRow(
            label: 'Quantity',
            value: '${reservation.quantity} ${reservation.listing.unit}',
          ),
          _DetailRow(
            label: 'Price per unit',
            value: '\$${reservation.listing.price.toStringAsFixed(2)}',
          ),
          const Divider(),
          _DetailRow(
            label: 'Total',
            value: '\$${reservation.totalPrice.toStringAsFixed(2)}',
            isBold: true,
          ),
          const SizedBox(height: DwSpacing.lg),

          // Pickup info
          if (reservation.confirmedPickupTime != null) ...[
            Text('Pickup Information', style: DwTextStyles.titleMedium),
            const SizedBox(height: DwSpacing.sm),
            _DetailRow(
              label: 'Time',
              value: _formatDateTime(reservation.confirmedPickupTime!),
            ),
            if (reservation.listing.pickupAddress != null)
              _DetailRow(
                label: 'Address',
                value: reservation.listing.pickupAddress!,
              ),
            const SizedBox(height: DwSpacing.lg),
          ],

          // Message
          if (reservation.message != null) ...[
            Text('Your Message', style: DwTextStyles.titleMedium),
            const SizedBox(height: DwSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DwSpacing.md),
              decoration: BoxDecoration(
                color: DwColors.surface,
                borderRadius: BorderRadius.circular(DwRadius.md),
                border: Border.all(color: DwColors.border),
              ),
              child: Text(
                reservation.message!,
                style: DwTextStyles.bodyMedium,
              ),
            ),
            const SizedBox(height: DwSpacing.lg),
          ],

          // Actions
          if (reservation.isActive) ...[
            const SizedBox(height: DwSpacing.md),
            if (reservation.status == ReservationStatus.confirmed)
              DwButton(
                onPressed: () => _confirmPickup(context, ref),
                child: const Text('Confirm Pickup'),
              ),
            const SizedBox(height: DwSpacing.sm),
            DwOutlinedButton(
              onPressed: () => _cancelReservation(context, ref),
              child: Text(
                'Cancel Reservation',
                style: TextStyle(color: DwColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmPickup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Pickup'),
        content: const Text('Have you picked up this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(reservationsProvider.notifier).confirmPickup(reservation.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pickup confirmed!')),
        );
      }
    }
  }

  Future<void> _cancelReservation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: const Text('Are you sure you want to cancel this reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes', style: TextStyle(color: DwColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(reservationsProvider.notifier).cancelReservation(reservation.id);
      if (context.mounted) {
        context.pop();
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusCard extends StatelessWidget {
  final Reservation reservation;

  const _StatusCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final (icon, color, message) = switch (reservation.status) {
      ReservationStatus.pending => (
          Icons.hourglass_empty,
          DwColors.warning,
          'Waiting for seller confirmation',
        ),
      ReservationStatus.confirmed => (
          Icons.check_circle,
          DwColors.success,
          'Ready for pickup',
        ),
      ReservationStatus.completed => (
          Icons.done_all,
          DwColors.success,
          'Order completed',
        ),
      ReservationStatus.cancelled => (
          Icons.cancel,
          DwColors.error,
          'Reservation cancelled',
        ),
      ReservationStatus.expired => (
          Icons.timer_off,
          DwColors.textSecondary,
          'Reservation expired',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DwSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DwRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: DwSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.status.displayName,
                  style: DwTextStyles.titleMedium.copyWith(color: color),
                ),
                Text(
                  message,
                  style: DwTextStyles.bodySmall.copyWith(
                    color: DwColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({
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
