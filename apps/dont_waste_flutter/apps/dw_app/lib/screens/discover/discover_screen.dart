import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

/// Discover screen with search and filtered listings
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(listingsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(listingsProvider);
    final hasFilters = ref.watch(hasActiveFiltersProvider);
    final filterCount = ref.watch(activeFilterCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DwSpacing.md,
              vertical: DwSpacing.sm,
            ),
            child: Row(
              children: [
                // Filter button
                DwFilterChip(
                  label: 'Filters',
                  icon: Icons.tune,
                  isSelected: hasFilters,
                  badge: filterCount > 0 ? filterCount : null,
                  onTap: () => context.push(AppRoutes.filters),
                ),
                const SizedBox(width: DwSpacing.sm),

                // Sort dropdown
                _SortDropdown(),

                const Spacer(),

                // Clear filters
                if (hasFilters)
                  TextButton(
                    onPressed: () {
                      ref.read(filtersProvider.notifier).clearFilters();
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),

          // Listings
          Expanded(
            child: listings.when(
              data: (state) {
                if (state.listings.isEmpty) {
                  return DwEmptyState(
                    icon: Icons.search_off,
                    title: 'No listings found',
                    message: 'Try adjusting your filters or search in a different area.',
                    action: DwButton(
                      onPressed: () {
                        ref.read(filtersProvider.notifier).resetAll();
                      },
                      child: const Text('Reset Filters'),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(listingsProvider.notifier).refresh(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(DwSpacing.md),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: DwSpacing.md,
                      crossAxisSpacing: DwSpacing.md,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: state.listings.length + (state.isLoadingMore ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.listings.length) {
                        return const DwListingCardSkeleton();
                      }

                      final listing = state.listings[index];
                      return DwListingCard(
                        listing: listing,
                        onTap: () => context.push(
                          AppRoutes.listingDetailPath(listing.id),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => GridView.builder(
                padding: const EdgeInsets.all(DwSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: DwSpacing.md,
                  crossAxisSpacing: DwSpacing.md,
                  childAspectRatio: 0.75,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const DwListingCardSkeleton(),
              ),
              error: (error, _) => DwErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(listingsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(sortOptionProvider);

    return PopupMenuButton<SortOption>(
      initialValue: sortOption,
      onSelected: (option) {
        ref.read(filtersProvider.notifier).updateSort(option);
      },
      child: DwFilterChip(
        label: sortOption.displayName,
        icon: Icons.sort,
        onTap: null,
      ),
      itemBuilder: (context) => SortOption.values.map((option) {
        return PopupMenuItem(
          value: option,
          child: Text(option.displayName),
        );
      }).toList(),
    );
  }
}
