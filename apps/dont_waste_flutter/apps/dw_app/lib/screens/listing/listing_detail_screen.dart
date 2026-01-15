import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

/// Listing detail screen
class ListingDetailScreen extends ConsumerWidget {
  final int listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));
    final isInWatchlist = ref.watch(isInWatchlistProvider(listingId));

    return Scaffold(
      body: listingAsync.when(
        data: (listing) => CustomScrollView(
          slivers: [
            // Image header
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: listing.imageUrls.isNotEmpty
                    ? Image.network(
                        listing.imageUrls.first,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: DwColors.surface,
                        child: const Icon(
                          Icons.image,
                          size: 64,
                          color: DwColors.textSecondary,
                        ),
                      ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isInWatchlist ? Icons.favorite : Icons.favorite_outline,
                    color: isInWatchlist ? DwColors.error : null,
                  ),
                  onPressed: () {
                    if (isInWatchlist) {
                      ref.read(watchlistProvider.notifier).removeFromWatchlist(listingId);
                    } else {
                      final listing = ref.read(listingDetailProvider(listingId)).valueOrNull;
                      if (listing != null) {
                        ref.read(watchlistProvider.notifier).addToWatchlist(listing);
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: Share listing
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(DwSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing.safeTitle,
                            style: DwTextStyles.headlineSmall,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${listing.price.toStringAsFixed(2)}',
                              style: DwTextStyles.headlineSmall.copyWith(
                                color: DwColors.primary,
                              ),
                            ),
                            Text(
                              'per ${listing.unit}',
                              style: DwTextStyles.bodySmall.copyWith(
                                color: DwColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: DwSpacing.sm),

                    // Original price if discounted
                    if (listing.originalPrice != null)
                      Row(
                        children: [
                          Text(
                            '\$${listing.originalPrice!.toStringAsFixed(2)}',
                            style: DwTextStyles.bodyMedium.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: DwColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: DwSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DwSpacing.sm,
                              vertical: DwSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: DwColors.successLight,
                              borderRadius: BorderRadius.circular(DwRadius.sm),
                            ),
                            child: Text(
                              '${listing.discountPercentage?.toInt()}% OFF',
                              style: DwTextStyles.labelSmall.copyWith(
                                color: DwColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: DwSpacing.md),

                    // Seller info
                    _SellerCard(seller: listing.seller),
                    const SizedBox(height: DwSpacing.lg),

                    // Quick info chips
                    Wrap(
                      spacing: DwSpacing.sm,
                      runSpacing: DwSpacing.sm,
                      children: [
                        _InfoChip(
                          icon: Icons.inventory_2_outlined,
                          label: '${listing.quantity} ${listing.unit} available',
                        ),
                        if (listing.expiresAt != null)
                          _InfoChip(
                            icon: Icons.schedule,
                            label: 'Expires ${_formatExpiry(listing.expiresAt!)}',
                            color: listing.isExpiringSoon ? DwColors.warning : null,
                          ),
                        if (listing.distance != null)
                          _InfoChip(
                            icon: Icons.location_on_outlined,
                            label: '${listing.distance!.toStringAsFixed(1)} km away',
                          ),
                      ],
                    ),
                    const SizedBox(height: DwSpacing.lg),

                    // Description
                    Text('Description', style: DwTextStyles.titleMedium),
                    const SizedBox(height: DwSpacing.sm),
                    Text(
                      listing.description ?? 'No description available',
                      style: DwTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: DwSpacing.lg),

                    // Pickup info
                    Text('Pickup Information', style: DwTextStyles.titleMedium),
                    const SizedBox(height: DwSpacing.sm),
                    if (listing.pickupAddress != null)
                      _DetailRow(
                        icon: Icons.location_on,
                        label: listing.pickupAddress!,
                      ),
                    if (listing.pickupStart != null && listing.pickupEnd != null)
                      _DetailRow(
                        icon: Icons.access_time,
                        label: 'Pickup: ${_formatTimeRange(listing.pickupStart!, listing.pickupEnd!)}',
                      ),
                    const SizedBox(height: DwSpacing.lg),

                    // Categories
                    if (listing.taxons.isNotEmpty) ...[
                      Text('Categories', style: DwTextStyles.titleMedium),
                      const SizedBox(height: DwSpacing.sm),
                      Wrap(
                        spacing: DwSpacing.sm,
                        children: listing.taxons.map((taxon) {
                          return Chip(
                            label: Text(taxon.name),
                            backgroundColor: DwColors.surface,
                          );
                        }).toList(),
                      ),
                    ],

                    // Bottom padding for FAB
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DwErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(listingDetailProvider(listingId)),
        ),
      ),
      bottomNavigationBar: listingAsync.maybeWhen(
        data: (listing) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DwSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: DwOutlinedButton(
                    onPressed: () => context.push(AppRoutes.makeOfferPath(listingId)),
                    child: const Text('Make Offer'),
                  ),
                ),
                const SizedBox(width: DwSpacing.md),
                Expanded(
                  flex: 2,
                  child: DwButton(
                    onPressed: () => context.push(AppRoutes.reservePath(listingId)),
                    child: const Text('Reserve Now'),
                  ),
                ),
              ],
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }

  String _formatExpiry(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.inHours < 24) {
      return 'in ${diff.inHours}h';
    }
    return 'in ${diff.inDays}d';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${start.hour}:${start.minute.toString().padLeft(2, '0')} - ${end.hour}:${end.minute.toString().padLeft(2, '0')}';
  }
}

class _SellerCard extends StatelessWidget {
  final Seller? seller;

  const _SellerCard({this.seller});

  @override
  Widget build(BuildContext context) {
    if (seller == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DwSpacing.md),
      decoration: BoxDecoration(
        color: DwColors.surface,
        borderRadius: BorderRadius.circular(DwRadius.md),
        border: Border.all(color: DwColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: DwColors.primaryLight,
            backgroundImage: seller!.avatarUrl != null
                ? NetworkImage(seller!.avatarUrl!)
                : null,
            child: seller!.avatarUrl == null
                ? Text(
                    seller!.name.substring(0, 1).toUpperCase(),
                    style: DwTextStyles.titleMedium.copyWith(
                      color: DwColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: DwSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(seller!.name, style: DwTextStyles.titleSmall),
                    if (seller!.isVerified) ...[
                      const SizedBox(width: DwSpacing.xs),
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: DwColors.primary,
                      ),
                    ],
                  ],
                ),
                if (seller!.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: DwColors.warning),
                      const SizedBox(width: 2),
                      Text(
                        '${seller!.rating!.toStringAsFixed(1)} (${seller!.reviewCount ?? 0} reviews)',
                        style: DwTextStyles.bodySmall.copyWith(
                          color: DwColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () {
              // TODO: Open chat
            },
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DwSpacing.sm,
        vertical: DwSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: (color ?? DwColors.textSecondary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(DwRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? DwColors.textSecondary),
          const SizedBox(width: DwSpacing.xs),
          Text(
            label,
            style: DwTextStyles.labelSmall.copyWith(
              color: color ?? DwColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DwSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: DwColors.textSecondary),
          const SizedBox(width: DwSpacing.sm),
          Expanded(
            child: Text(label, style: DwTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}
