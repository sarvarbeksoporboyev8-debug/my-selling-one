import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);
    final watchlistCount = ref.watch(watchlistCountProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: DwDarkTheme.background,
        body: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              backgroundColor: DwDarkTheme.background,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: DwDarkTheme.spacingMd,
                    right: DwDarkTheme.spacingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Watchlist',
                        style: DwDarkTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$watchlistCount saved items',
                        style: DwDarkTheme.bodyMedium.copyWith(
                          color: DwDarkTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (watchlistCount > 0)
                  IconButton(
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: DwDarkTheme.surfaceHighlight,
                        borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: DwDarkTheme.textSecondary,
                      ),
                    ),
                    onPressed: () => _showClearDialog(context, ref),
                  ),
                const SizedBox(width: DwDarkTheme.spacingSm),
              ],
            ),

            // Content
            watchlistAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyState(context),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: DwDarkTheme.spacingMd),
                          child: _WatchlistCard(
                            listing: item.listing,
                            onTap: () => context.push(AppRoutes.listingDetailPath(item.listing.id)),
                            onRemove: () => ref.read(watchlistProvider.notifier).removeFromWatchlist(item.listing.id),
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: DwDarkTheme.accent),
                ),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Error loading watchlist',
                    style: DwDarkTheme.bodyMedium.copyWith(color: DwDarkTheme.textTertiary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DwDarkTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DwDarkTheme.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_outline,
                size: 36,
                color: DwDarkTheme.accent.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: DwDarkTheme.spacingLg),
            Text(
              'No saved items',
              style: DwDarkTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DwDarkTheme.spacingSm),
            Text(
              'Save listings you\'re interested in to quickly access them later.',
              style: DwDarkTheme.bodyMedium.copyWith(
                color: DwDarkTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DwDarkTheme.spacingLg),
            GestureDetector(
              onTap: () => context.go(AppRoutes.discover),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DwDarkTheme.spacingLg,
                  vertical: DwDarkTheme.spacingMd,
                ),
                decoration: BoxDecoration(
                  gradient: DwDarkTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: DwDarkTheme.accent.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.explore_outlined, size: 18, color: Colors.white),
                    const SizedBox(width: DwDarkTheme.spacingSm),
                    Text(
                      'Browse Discover',
                      style: DwDarkTheme.titleSmall.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DwDarkTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
        ),
        title: Text('Clear Watchlist', style: DwDarkTheme.headlineSmall),
        content: Text(
          'Remove all items from your watchlist?',
          style: DwDarkTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: DwDarkTheme.labelLarge.copyWith(color: DwDarkTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              // Clear all items one by one
              final items = ref.read(watchlistProvider).valueOrNull ?? [];
              for (final item in items) {
                ref.read(watchlistProvider.notifier).removeFromWatchlist(item.listing.id);
              }
              Navigator.pop(context);
            },
            child: Text(
              'Clear All',
              style: DwDarkTheme.labelLarge.copyWith(color: DwDarkTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  final SurplusListing listing;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _WatchlistCard({
    required this.listing,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: DwDarkTheme.surfaceHighlight,
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
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
                      listing.safeTitle,
                      style: DwDarkTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.enterprise?.name ?? listing.seller?.name ?? 'Unknown seller',
                      style: DwDarkTheme.bodySmall.copyWith(
                        color: DwDarkTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: DwDarkTheme.spacingSm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DwDarkTheme.spacingSm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: DwDarkTheme.accentGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '\$${listing.currentPrice.toStringAsFixed(2)}',
                            style: DwDarkTheme.labelMedium.copyWith(
                              color: DwDarkTheme.accentGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: DwDarkTheme.spacingSm),
                        Text(
                          '${listing.quantity.toStringAsFixed(0)} ${listing.unit} left',
                          style: DwDarkTheme.labelSmall.copyWith(
                            color: DwDarkTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Remove button
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: DwDarkTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.bookmark_remove_outlined,
                    size: 18,
                    color: DwDarkTheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: DwDarkTheme.surfaceHighlight,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: DwDarkTheme.textMuted,
          size: 28,
        ),
      ),
    );
  }
}
