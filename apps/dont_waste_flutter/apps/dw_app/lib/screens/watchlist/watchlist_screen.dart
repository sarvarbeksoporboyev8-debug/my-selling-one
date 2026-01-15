import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

/// Watchlist screen showing saved listings
class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
      ),
      body: watchlist.when(
        data: (items) {
          if (items.isEmpty) {
            return DwEmptyState(
              icon: Icons.favorite_outline,
              title: 'No saved items',
              message: 'Items you save will appear here so you can easily find them later.',
              action: DwButton(
                onPressed: () => context.go(AppRoutes.discover),
                child: const Text('Browse Listings'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(watchlistProvider.notifier).loadWatchlist(),
            child: ListView.separated(
              padding: const EdgeInsets.all(DwSpacing.md),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: DwSpacing.md),
              itemBuilder: (context, index) {
                final item = items[index];
                return DwListingListTile(
                  listing: item.listing,
                  onTap: () => context.push(
                    AppRoutes.listingDetailPath(item.listing.id),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: DwColors.error),
                    onPressed: () {
                      ref.read(watchlistProvider.notifier).removeFromWatchlist(
                            item.listing.id,
                          );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(DwSpacing.md),
          itemCount: 5,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(bottom: DwSpacing.md),
            child: DwListingListTileSkeleton(),
          ),
        ),
        error: (error, _) => DwErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(watchlistProvider),
        ),
      ),
    );
  }
}
