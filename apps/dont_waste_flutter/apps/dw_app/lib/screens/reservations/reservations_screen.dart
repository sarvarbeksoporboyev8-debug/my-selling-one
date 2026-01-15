import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

/// Reservations screen showing user's reservations
class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(reservationsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reservations'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: reservations.when(
          data: (items) {
            final active = items.where((r) => r.isActive).toList();
            final completed = items.where((r) => r.status == ReservationStatus.completed).toList();
            final cancelled = items.where((r) => r.status == ReservationStatus.cancelled).toList();

            return TabBarView(
              children: [
                _ReservationList(reservations: active, emptyMessage: 'No active reservations'),
                _ReservationList(reservations: completed, emptyMessage: 'No completed reservations'),
                _ReservationList(reservations: cancelled, emptyMessage: 'No cancelled reservations'),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => DwErrorWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(reservationsProvider),
          ),
        ),
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  final List<Reservation> reservations;
  final String emptyMessage;

  const _ReservationList({
    required this.reservations,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return DwEmptyState(
        icon: Icons.receipt_long_outlined,
        title: emptyMessage,
        message: 'Your reservations will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(DwSpacing.md),
      itemCount: reservations.length,
      separatorBuilder: (_, __) => const SizedBox(height: DwSpacing.md),
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return _ReservationCard(reservation: reservation);
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.reservationDetailPath(reservation.id),
        ),
        borderRadius: BorderRadius.circular(DwRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(DwSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reservation.listing.title,
                      style: DwTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: reservation.status),
                ],
              ),
              const SizedBox(height: DwSpacing.sm),

              // Seller info
              Text(
                reservation.listing.seller?.name ?? 'Unknown seller',
                style: DwTextStyles.bodySmall.copyWith(
                  color: DwColors.textSecondary,
                ),
              ),
              const SizedBox(height: DwSpacing.md),

              // Details row
              Row(
                children: [
                  // Quantity
                  _DetailChip(
                    icon: Icons.shopping_bag_outlined,
                    label: '${reservation.quantity} ${reservation.listing.unit}',
                  ),
                  const SizedBox(width: DwSpacing.sm),

                  // Price
                  _DetailChip(
                    icon: Icons.attach_money,
                    label: '\$${reservation.totalPrice.toStringAsFixed(2)}',
                  ),
                ],
              ),

              // Pickup time if confirmed
              if (reservation.confirmedPickupTime != null) ...[
                const SizedBox(height: DwSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: DwColors.textSecondary,
                    ),
                    const SizedBox(width: DwSpacing.xs),
                    Text(
                      'Pickup: ${_formatDateTime(reservation.confirmedPickupTime!)}',
                      style: DwTextStyles.bodySmall.copyWith(
                        color: DwColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = switch (status) {
      ReservationStatus.pending => (DwColors.warning, DwColors.warningLight),
      ReservationStatus.confirmed => (DwColors.info, DwColors.infoLight),
      ReservationStatus.completed => (DwColors.success, DwColors.successLight),
      ReservationStatus.cancelled => (DwColors.error, DwColors.errorLight),
      ReservationStatus.expired => (DwColors.textSecondary, DwColors.surface),
      _ => (DwColors.textSecondary, DwColors.surface),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DwSpacing.sm,
        vertical: DwSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(DwRadius.sm),
      ),
      child: Text(
        status.displayName,
        style: DwTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DwSpacing.sm,
        vertical: DwSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DwColors.surface,
        borderRadius: BorderRadius.circular(DwRadius.sm),
        border: Border.all(color: DwColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: DwColors.textSecondary),
          const SizedBox(width: DwSpacing.xs),
          Text(label, style: DwTextStyles.labelSmall),
        ],
      ),
    );
  }
}
