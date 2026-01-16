import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';
import 'package:dw_ui/dw_ui.dart';

import 'reservation_status_pill.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;
  final VoidCallback? onDirections;
  final VoidCallback? onReorder;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
    this.onDirections,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final listing = reservation.listing;
    final imageUrl = listing.imageUrls?.isNotEmpty == true
        ? listing.imageUrls!.first
        : listing.photoUrls?.isNotEmpty == true
            ? listing.photoUrls!.first
            : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
          decoration: BoxDecoration(
            color: DwDarkTheme.cardBackground,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Image + Info + Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  _buildThumbnail(imageUrl),
                  const SizedBox(width: DwDarkTheme.spacingMd),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          listing.safeTitle,
                          style: DwDarkTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Seller
                        Text(
                          listing.seller?.name ?? listing.enterprise?.name ?? 'Unknown seller',
                          style: DwDarkTheme.bodySmall.copyWith(
                            color: DwDarkTheme.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: DwDarkTheme.spacingSm),

                        // Quantity and price row
                        Row(
                          children: [
                            _buildInfoChip(
                              Icons.inventory_2_outlined,
                              '${reservation.quantity.toStringAsFixed(0)} ${listing.unit}',
                            ),
                            const SizedBox(width: DwDarkTheme.spacingSm),
                            _buildInfoChip(
                              Icons.attach_money,
                              '\$${reservation.totalPrice.toStringAsFixed(2)}',
                              highlight: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status pill
                  ReservationStatusPill(status: reservation.status),
                ],
              ),

              // Pickup time / location row
              if (reservation.isActive || reservation.confirmedPickupTime != null) ...[
                const SizedBox(height: DwDarkTheme.spacingMd),
                Container(
                  padding: const EdgeInsets.all(DwDarkTheme.spacingSm + 2),
                  decoration: BoxDecoration(
                    color: DwDarkTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: DwDarkTheme.textTertiary,
                      ),
                      const SizedBox(width: DwDarkTheme.spacingSm),
                      Expanded(
                        child: Text(
                          _getPickupTimeText(),
                          style: DwDarkTheme.bodySmall.copyWith(
                            color: DwDarkTheme.textSecondary,
                          ),
                        ),
                      ),
                      if (reservation.isActive && reservation.expiresAt != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DwDarkTheme.spacingSm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTimeRemainingColor().withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            reservation.timeRemainingDisplay,
                            style: DwDarkTheme.labelSmall.copyWith(
                              color: _getTimeRemainingColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Action buttons
              const SizedBox(height: DwDarkTheme.spacingMd),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String? imageUrl) {
    return Container(
      width: 72,
      height: 72,
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
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: DwDarkTheme.surfaceHighlight,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 28,
          color: DwDarkTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DwDarkTheme.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? DwDarkTheme.accentGreen.withOpacity(0.12)
            : DwDarkTheme.surfaceHighlight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: highlight ? DwDarkTheme.accentGreen : DwDarkTheme.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: DwDarkTheme.labelSmall.copyWith(
              color: highlight ? DwDarkTheme.accentGreen : DwDarkTheme.textSecondary,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Primary action
        Expanded(
          child: _ActionButton(
            label: 'View Details',
            icon: Icons.visibility_outlined,
            onTap: onTap,
            isPrimary: true,
          ),
        ),

        // Secondary action based on status
        if (reservation.isActive && onDirections != null) ...[
          const SizedBox(width: DwDarkTheme.spacingSm),
          _ActionButton(
            label: 'Directions',
            icon: Icons.directions_outlined,
            onTap: onDirections!,
          ),
        ],

        if (reservation.status == ReservationStatus.completed && onReorder != null) ...[
          const SizedBox(width: DwDarkTheme.spacingSm),
          _ActionButton(
            label: 'Reorder',
            icon: Icons.replay_outlined,
            onTap: onReorder!,
          ),
        ],

        if (reservation.status == ReservationStatus.cancelled && onReorder != null) ...[
          const SizedBox(width: DwDarkTheme.spacingSm),
          _ActionButton(
            label: 'Book Again',
            icon: Icons.add_shopping_cart_outlined,
            onTap: onReorder!,
          ),
        ],
      ],
    );
  }

  String _getPickupTimeText() {
    if (reservation.confirmedPickupTime != null) {
      return 'Pickup: ${_formatDateTime(reservation.confirmedPickupTime!)}';
    }
    if (reservation.listing.pickupStartAt != null) {
      return 'Pickup window: ${_formatTimeRange(reservation.listing.pickupStartAt!, reservation.listing.pickupEndAt!)}';
    }
    return 'Pickup time to be confirmed';
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DwDarkTheme.spacingSm,
            vertical: DwDarkTheme.spacingSm + 2,
          ),
          decoration: BoxDecoration(
            color: isPrimary
                ? DwDarkTheme.accent.withOpacity(0.15)
                : DwDarkTheme.surfaceHighlight,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
            border: Border.all(
              color: isPrimary
                  ? DwDarkTheme.accent.withOpacity(0.3)
                  : DwDarkTheme.cardBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isPrimary ? DwDarkTheme.accent : DwDarkTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: DwDarkTheme.labelMedium.copyWith(
                  color: isPrimary ? DwDarkTheme.accent : DwDarkTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
