import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

/// Home screen with featured listings and quick actions
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final listings = ref.watch(listingsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.name ?? 'Guest'}',
                  style: DwTextStyles.titleMedium,
                ),
                Text(
                  'Find surplus food near you',
                  style: DwTextStyles.bodySmall.copyWith(
                    color: DwColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.push(AppRoutes.search),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push(AppRoutes.notifications),
              ),
            ],
          ),

          // Location selector
          SliverToBoxAdapter(
            child: _LocationSelector(),
          ),

          // Quick categories
          SliverToBoxAdapter(
            child: _QuickCategories(),
          ),

          // Featured listings header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DwSpacing.md,
                DwSpacing.lg,
                DwSpacing.md,
                DwSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Near You',
                    style: DwTextStyles.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.discover),
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          // Listings grid
          listings.when(
            data: (state) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: DwSpacing.md),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: DwSpacing.md,
                  crossAxisSpacing: DwSpacing.md,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= state.listings.length) return null;
                    final listing = state.listings[index];
                    return DwListingCard(
                      listing: listing,
                      onTap: () => context.push(
                        AppRoutes.listingDetailPath(listing.id),
                      ),
                    );
                  },
                  childCount: state.listings.length.clamp(0, 6),
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(DwSpacing.xl),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: DwErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(listingsProvider),
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: DwSpacing.xxl),
          ),
        ],
      ),
    );
  }
}

class _LocationSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(selectedLocationProvider);
    final radius = ref.watch(selectedRadiusProvider);

    return Container(
      margin: const EdgeInsets.all(DwSpacing.md),
      padding: const EdgeInsets.all(DwSpacing.md),
      decoration: BoxDecoration(
        color: DwColors.surface,
        borderRadius: BorderRadius.circular(DwRadius.md),
        border: Border.all(color: DwColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: DwColors.primary),
          const SizedBox(width: DwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location?.name ?? 'Set your location',
                  style: DwTextStyles.titleSmall,
                ),
                Text(
                  'Within ${radius.toInt()} km',
                  style: DwTextStyles.bodySmall.copyWith(
                    color: DwColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_location_alt_outlined),
            onPressed: () {
              // TODO: Open location picker
            },
          ),
        ],
      ),
    );
  }
}

class _QuickCategories extends StatelessWidget {
  final _categories = const [
    ('Bakery', Icons.bakery_dining),
    ('Produce', Icons.eco),
    ('Dairy', Icons.egg),
    ('Meals', Icons.restaurant),
    ('Drinks', Icons.local_cafe),
    ('More', Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DwSpacing.md),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: DwSpacing.md),
        itemBuilder: (context, index) {
          final (name, icon) = _categories[index];
          return _CategoryChip(name: name, icon: icon);
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;
  final IconData icon;

  const _CategoryChip({required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Filter by category
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: DwColors.primaryLight,
              borderRadius: BorderRadius.circular(DwRadius.md),
            ),
            child: Icon(icon, color: DwColors.primary),
          ),
          const SizedBox(height: DwSpacing.xs),
          Text(
            name,
            style: DwTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}
