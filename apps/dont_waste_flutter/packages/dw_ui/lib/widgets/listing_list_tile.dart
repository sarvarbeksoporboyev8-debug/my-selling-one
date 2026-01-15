import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';

import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Listing list tile widget for horizontal display
class DwListingListTile extends StatelessWidget {
  final SurplusListing listing;
  final VoidCallback? onTap;
  final Widget? trailing;

  const DwListingListTile({
    super.key,
    required this.listing,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DwRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(DwSpacing.sm),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(DwRadius.sm),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: listing.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: listing.imageUrls.first,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: DwColors.surface,
                            child: const Icon(
                              Icons.image,
                              color: DwColors.textSecondary,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: DwColors.surface,
                            child: const Icon(
                              Icons.broken_image,
                              color: DwColors.textSecondary,
                            ),
                          ),
                        )
                      : Container(
                          color: DwColors.surface,
                          child: const Icon(
                            Icons.image,
                            color: DwColors.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: DwSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: DwTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DwSpacing.xs),
                    Text(
                      listing.seller?.name ?? 'Unknown seller',
                      style: DwTextStyles.bodySmall.copyWith(
                        color: DwColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DwSpacing.xs),
                    Row(
                      children: [
                        Text(
                          '\$${listing.price.toStringAsFixed(2)}',
                          style: DwTextStyles.titleSmall.copyWith(
                            color: DwColors.primary,
                          ),
                        ),
                        Text(
                          ' / ${listing.unit}',
                          style: DwTextStyles.bodySmall.copyWith(
                            color: DwColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (listing.distance != null)
                          Text(
                            '${listing.distance!.toStringAsFixed(1)} km',
                            style: DwTextStyles.bodySmall.copyWith(
                              color: DwColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader for listing list tile
class DwListingListTileSkeleton extends StatelessWidget {
  const DwListingListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(DwSpacing.sm),
        child: Row(
          children: [
            // Image skeleton
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DwColors.surface,
                borderRadius: BorderRadius.circular(DwRadius.sm),
              ),
            ),
            const SizedBox(width: DwSpacing.md),

            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: DwColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: DwSpacing.sm),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: DwColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: DwSpacing.sm),
                  Container(
                    height: 14,
                    width: 60,
                    decoration: BoxDecoration(
                      color: DwColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
