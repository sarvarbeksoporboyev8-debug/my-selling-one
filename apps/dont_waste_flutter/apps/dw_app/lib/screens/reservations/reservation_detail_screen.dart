import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_ui/dw_ui.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';
import 'widgets/widgets.dart';

class ReservationDetailScreen extends ConsumerWidget {
  final int reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationAsync = ref.watch(reservationDetailProvider(reservationId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: DwDarkTheme.background,
        appBar: AppBar(
          backgroundColor: DwDarkTheme.background,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DwDarkTheme.surfaceHighlight,
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: DwDarkTheme.textSecondary,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Reservation Details',
            style: DwDarkTheme.headlineSmall,
          ),
          actions: [
            IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DwDarkTheme.surfaceHighlight,
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: DwDarkTheme.textSecondary,
                ),
              ),
              onPressed: () => _showOptionsMenu(context, ref),
            ),
            const SizedBox(width: DwDarkTheme.spacingSm),
          ],
        ),
        body: reservationAsync.when(
          data: (reservation) => _ReservationDetailContent(reservation: reservation),
          loading: () => const Center(
            child: CircularProgressIndicator(color: DwDarkTheme.accent),
          ),
          error: (error, _) => ReservationsErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(reservationDetailProvider(reservationId)),
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DwDarkTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DwDarkTheme.radiusLg),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DwDarkTheme.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),
            _OptionTile(
              icon: Icons.help_outline,
              title: 'Get Help',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Help center coming soon'),
                    backgroundColor: DwDarkTheme.surfaceElevated,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                    ),
                  ),
                );
              },
            ),
            _OptionTile(
              icon: Icons.share_outlined,
              title: 'Share Details',
              onTap: () {
                Navigator.pop(context);
                // TODO: Share functionality
              },
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DwDarkTheme.spacingMd,
            vertical: DwDarkTheme.spacingMd,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: DwDarkTheme.textSecondary),
              const SizedBox(width: DwDarkTheme.spacingMd),
              Text(title, style: DwDarkTheme.bodyLarge),
            ],
          ),
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
    final listing = reservation.listing;
    final imageUrl = listing.imageUrls?.isNotEmpty == true
        ? listing.imageUrls!.first
        : listing.photoUrls?.isNotEmpty == true
            ? listing.photoUrls!.first
            : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _StatusCard(reservation: reservation),
          const SizedBox(height: DwDarkTheme.spacingMd),

          // Listing info card
          _buildListingCard(context, imageUrl),
          const SizedBox(height: DwDarkTheme.spacingMd),

          // Order details card
          _buildOrderDetailsCard(),
          const SizedBox(height: DwDarkTheme.spacingMd),

          // Pickup info card
          if (reservation.isActive || reservation.confirmedPickupTime != null)
            _buildPickupCard(),

          // Message card
          if (reservation.message != null && reservation.message!.isNotEmpty) ...[
            const SizedBox(height: DwDarkTheme.spacingMd),
            _buildMessageCard(),
          ],

          // Actions
          if (reservation.isActive) ...[
            const SizedBox(height: DwDarkTheme.spacingLg),
            _buildActions(context, ref),
          ],

          const SizedBox(height: DwDarkTheme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, String? imageUrl) {
    return Container(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      decoration: BoxDecoration(
        color: DwDarkTheme.cardBackground,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item',
            style: DwDarkTheme.titleSmall.copyWith(
              color: DwDarkTheme.textSecondary,
            ),
          ),
          const SizedBox(height: DwDarkTheme.spacingSm),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(
                AppRoutes.listingDetailPath(reservation.listing.id),
              ),
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: DwDarkTheme.spacingSm),
                child: Row(
                  children: [
                    // Image
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: DwDarkTheme.surfaceHighlight,
                        borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                        border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm - 1),
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _buildPlaceholder(),
                                errorWidget: (_, __, ___) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                    const SizedBox(width: DwDarkTheme.spacingMd),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservation.listing.safeTitle,
                            style: DwDarkTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reservation.listing.seller?.name ??
                                reservation.listing.enterprise?.name ??
                                'Unknown seller',
                            style: DwDarkTheme.bodySmall.copyWith(
                              color: DwDarkTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chevron
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: DwDarkTheme.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: DwDarkTheme.surfaceHighlight,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 24,
          color: DwDarkTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      decoration: BoxDecoration(
        color: DwDarkTheme.cardBackground,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: DwDarkTheme.titleSmall.copyWith(
              color: DwDarkTheme.textSecondary,
            ),
          ),
          const SizedBox(height: DwDarkTheme.spacingMd),

          _DetailRow(
            label: 'Quantity',
            value: '${reservation.quantity.toStringAsFixed(0)} ${reservation.listing.unit}',
          ),
          const SizedBox(height: DwDarkTheme.spacingSm),
          _DetailRow(
            label: 'Price per unit',
            value: '\$${reservation.listing.price.toStringAsFixed(2)}',
          ),
          const SizedBox(height: DwDarkTheme.spacingSm),
          Container(
            height: 1,
            color: DwDarkTheme.cardBorder,
          ),
          const SizedBox(height: DwDarkTheme.spacingSm),
          _DetailRow(
            label: 'Total',
            value: '\$${reservation.totalPrice.toStringAsFixed(2)}',
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard() {
    return Container(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      decoration: BoxDecoration(
        color: DwDarkTheme.cardBackground,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup Information',
            style: DwDarkTheme.titleSmall.copyWith(
              color: DwDarkTheme.textSecondary,
            ),
          ),
          const SizedBox(height: DwDarkTheme.spacingMd),

          // Time
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DwDarkTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.schedule,
                  size: 18,
                  color: DwDarkTheme.accent,
                ),
              ),
              const SizedBox(width: DwDarkTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Time',
                      style: DwDarkTheme.labelMedium.copyWith(
                        color: DwDarkTheme.textTertiary,
                      ),
                    ),
                    Text(
                      reservation.confirmedPickupTime != null
                          ? _formatDateTime(reservation.confirmedPickupTime!)
                          : _formatTimeRange(
                              reservation.listing.pickupStartAt!,
                              reservation.listing.pickupEndAt!,
                            ),
                      style: DwDarkTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Address
          if (reservation.listing.pickupAddress != null) ...[
            const SizedBox(height: DwDarkTheme.spacingMd),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: DwDarkTheme.accentGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: DwDarkTheme.accentGreen,
                  ),
                ),
                const SizedBox(width: DwDarkTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address',
                        style: DwDarkTheme.labelMedium.copyWith(
                          color: DwDarkTheme.textTertiary,
                        ),
                      ),
                      Text(
                        reservation.listing.pickupAddress!,
                        style: DwDarkTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Time remaining
          if (reservation.isActive && reservation.expiresAt != null) ...[
            const SizedBox(height: DwDarkTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(DwDarkTheme.spacingSm + 2),
              decoration: BoxDecoration(
                color: _getTimeRemainingColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                border: Border.all(
                  color: _getTimeRemainingColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: _getTimeRemainingColor(),
                  ),
                  const SizedBox(width: DwDarkTheme.spacingSm),
                  Text(
                    'Time remaining: ${reservation.timeRemainingDisplay}',
                    style: DwDarkTheme.labelMedium.copyWith(
                      color: _getTimeRemainingColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      decoration: BoxDecoration(
        color: DwDarkTheme.cardBackground,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Message',
            style: DwDarkTheme.titleSmall.copyWith(
              color: DwDarkTheme.textSecondary,
            ),
          ),
          const SizedBox(height: DwDarkTheme.spacingSm),
          Text(
            reservation.message!,
            style: DwDarkTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Primary action
        if (reservation.status == ReservationStatus.confirmed)
          _ActionButton(
            label: 'Confirm Pickup',
            icon: Icons.check_circle_outline,
            isPrimary: true,
            onTap: () => _confirmPickup(context, ref),
          ),

        // Directions button
        if (reservation.listing.latitude != null) ...[
          const SizedBox(height: DwDarkTheme.spacingSm),
          _ActionButton(
            label: 'Get Directions',
            icon: Icons.directions_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Opening directions...'),
                  backgroundColor: DwDarkTheme.surfaceElevated,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                  ),
                ),
              );
            },
          ),
        ],

        // Cancel button
        const SizedBox(height: DwDarkTheme.spacingSm),
        _ActionButton(
          label: 'Cancel Reservation',
          icon: Icons.cancel_outlined,
          isDestructive: true,
          onTap: () => _cancelReservation(context, ref),
        ),
      ],
    );
  }

  Future<void> _confirmPickup(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pickup confirmation coming soon'),
        backgroundColor: DwDarkTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
        ),
      ),
    );
  }

  Future<void> _cancelReservation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DwDarkTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
        ),
        title: Text(
          'Cancel Reservation',
          style: DwDarkTheme.headlineSmall,
        ),
        content: Text(
          'Are you sure you want to cancel this reservation? This action cannot be undone.',
          style: DwDarkTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Keep Reservation',
              style: DwDarkTheme.labelLarge.copyWith(
                color: DwDarkTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cancel',
              style: DwDarkTheme.labelLarge.copyWith(
                color: const Color(0xFFF85149),
              ),
            ),
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

  String _formatTimeRange(DateTime start, DateTime end) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[start.month - 1]} ${start.day}, ${start.hour}:${start.minute.toString().padLeft(2, '0')} - ${end.hour}:${end.minute.toString().padLeft(2, '0')}';
  }

  Color _getTimeRemainingColor() {
    if (reservation.expiresAt == null) return DwDarkTheme.textMuted;
    final diff = reservation.expiresAt!.difference(DateTime.now());
    if (diff.inHours < 2) return const Color(0xFFF85149);
    if (diff.inHours < 6) return const Color(0xFFD29922);
    return DwDarkTheme.accentGreen;
  }
}

class _StatusCard extends StatelessWidget {
  final Reservation reservation;

  const _StatusCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final (icon, color, message) = _getStatusContent(reservation.status);

    return Container(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: DwDarkTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.status.displayName,
                  style: DwDarkTheme.titleMedium.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: DwDarkTheme.bodySmall.copyWith(
                    color: DwDarkTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _getStatusContent(ReservationStatus status) {
    return switch (status) {
      ReservationStatus.pending => (
          Icons.hourglass_empty,
          const Color(0xFFD29922),
          'Waiting for seller confirmation',
        ),
      ReservationStatus.confirmed => (
          Icons.check_circle,
          DwDarkTheme.accentGreen,
          'Ready for pickup',
        ),
      ReservationStatus.completed => (
          Icons.done_all,
          DwDarkTheme.accentGreen,
          'Order completed successfully',
        ),
      ReservationStatus.cancelled => (
          Icons.cancel,
          const Color(0xFFF85149),
          'Reservation was cancelled',
        ),
      ReservationStatus.expired => (
          Icons.timer_off,
          DwDarkTheme.textMuted,
          'Reservation has expired',
        ),
    };
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isHighlighted
              ? DwDarkTheme.titleSmall
              : DwDarkTheme.bodyMedium.copyWith(
                  color: DwDarkTheme.textSecondary,
                ),
        ),
        Text(
          value,
          style: isHighlighted
              ? DwDarkTheme.titleSmall.copyWith(
                  color: DwDarkTheme.accentGreen,
                )
              : DwDarkTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFF85149)
        : isPrimary
            ? DwDarkTheme.accent
            : DwDarkTheme.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: DwDarkTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: isPrimary
                ? DwDarkTheme.accent.withOpacity(0.15)
                : isDestructive
                    ? const Color(0xFFF85149).withOpacity(0.1)
                    : DwDarkTheme.surfaceHighlight,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(
              color: isPrimary
                  ? DwDarkTheme.accent.withOpacity(0.3)
                  : isDestructive
                      ? const Color(0xFFF85149).withOpacity(0.3)
                      : DwDarkTheme.cardBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: DwDarkTheme.spacingSm),
              Text(
                label,
                style: DwDarkTheme.titleSmall.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
