import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'countdown_badge.dart';
import 'distance_chip.dart';
import 'price_display.dart';

/// Alias for ListingCard with Dw prefix
typedef DwListingCard = ListingCard;

/// Card widget for displaying a surplus listing
class ListingCard extends StatelessWidget {
  final SurplusListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onReserve;
  final bool isCompact;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onReserve,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard(context);
    }
    return _buildFullCard(context);
  }

  Widget _buildFullCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusLg,
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            _buildImageSection(),
            // Content section
            Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.displayName,
                              style: AppTypography.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSpacing.vGapXs,
                            _buildSellerRow(),
                          ],
                        ),
                      ),
                      CountdownBadge(
                        expiresAt: listing.expiresAt,
                        isUrgent: listing.isUrgent,
                      ),
                    ],
                  ),
                  AppSpacing.vGapMd,
                  // Details row
                  _buildDetailsRow(),
                  AppSpacing.vGapMd,
                  // Price and action row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriceDisplay(
                        currentPrice: listing.currentPrice,
                        basePrice: listing.basePrice,
                        currency: listing.currency,
                        unit: listing.unit,
                      ),
                      if (onReserve != null)
                        ElevatedButton(
                          onPressed: onReserve,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                          ),
                          child: const Text('Reserve'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusLg,
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(height: 120),
            Padding(
              padding: AppSpacing.cardPaddingSmall,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.displayName,
                    style: AppTypography.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGapXs,
                  Text(
                    listing.enterprise.name,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGapSm,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${listing.currency} ${listing.currentPrice.toStringAsFixed(2)}',
                        style: AppTypography.priceMain.copyWith(fontSize: 16),
                      ),
                      CountdownBadge(
                        expiresAt: listing.expiresAt,
                        isUrgent: listing.isUrgent,
                        isCompact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection({double height = 180}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
          child: listing.primaryPhotoUrl != null
              ? CachedNetworkImage(
                  imageUrl: listing.primaryPhotoUrl!,
                  height: height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildImagePlaceholder(height),
                  errorWidget: (context, url, error) =>
                      _buildImagePlaceholder(height),
                )
              : _buildImagePlaceholder(height),
        ),
        // Discount badge
        if (listing.hasDiscount)
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Text(
                '-${listing.discountPercentage!.toStringAsFixed(0)}%',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Distance chip
        if (listing.distanceKm != null)
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: DistanceChip(distanceKm: listing.distanceKm!),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildSellerRow() {
    return Row(
      children: [
        Icon(
          listing.enterprise.isVerified
              ? Icons.verified
              : Icons.store_outlined,
          size: 14,
          color: listing.enterprise.isVerified
              ? AppColors.primary
              : AppColors.textTertiary,
        ),
        AppSpacing.hGapXs,
        Expanded(
          child: Text(
            listing.enterprise.name,
            style: AppTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsRow() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _buildDetailChip(
          Icons.inventory_2_outlined,
          '${listing.quantityAvailable.toStringAsFixed(0)} ${listing.unit}',
        ),
        _buildDetailChip(
          Icons.access_time,
          listing.pickupWindowDisplay,
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          AppSpacing.hGapXs,
          Text(
            text,
            style: AppTypography.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for listing card
class DwListingCardSkeleton extends StatelessWidget {
  const DwListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DwColors.surface,
        borderRadius: BorderRadius.circular(DwRadius.md),
        border: Border.all(color: DwColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: DwColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(DwRadius.md),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DwSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: DwColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: DwSpacing.sm),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: DwColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: DwSpacing.sm),
                Container(
                  height: 14,
                  width: 60,
                  decoration: BoxDecoration(
                    color: DwColors.border,
                    borderRadius: BorderRadius.circular(4),
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
