import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final listingsAsync = ref.watch(listingsProvider);
    final watchlistCount = ref.watch(watchlistCountProvider);
    final reservations = ref.watch(reservationsProvider);

    final reservationsCount = reservations.maybeWhen(
      data: (items) => items.where((r) => r.isActive).length,
      orElse: () => 0,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: DwDarkTheme.background,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(listingsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: DwDarkTheme.accent,
          backgroundColor: DwDarkTheme.surface,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(context, user),
              ),

              // Quick stats
              SliverToBoxAdapter(
                child: _buildQuickStats(context, watchlistCount, reservationsCount),
              ),

              // Featured section
              SliverToBoxAdapter(
                child: _buildSectionHeader('Featured Deals', () => context.go(AppRoutes.discover)),
              ),

              // Featured listings
              listingsAsync.when(
                data: (state) => SliverToBoxAdapter(
                  child: _buildFeaturedListings(context, state.listings),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: _FeaturedLoadingState(),
                ),
                error: (_, __) => const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                ),
              ),

              // Categories section
              SliverToBoxAdapter(
                child: _buildSectionHeader('Browse Categories', null),
              ),

              SliverToBoxAdapter(
                child: _buildCategories(context),
              ),

              // Nearby section
              SliverToBoxAdapter(
                child: _buildSectionHeader('Nearby', () => context.go(AppRoutes.map)),
              ),

              listingsAsync.when(
                data: (state) => SliverToBoxAdapter(
                  child: _buildNearbyListings(context, state.listings),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: _NearbyLoadingState(),
                ),
                error: (_, __) => const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: DwDarkTheme.spacingXl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    final greeting = _getGreeting();
    final name = user?.name.split(' ').first ?? 'there';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + DwDarkTheme.spacingMd,
        left: DwDarkTheme.spacingMd,
        right: DwDarkTheme.spacingMd,
        bottom: DwDarkTheme.spacingMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: DwDarkTheme.bodyMedium.copyWith(
                    color: DwDarkTheme.textTertiary,
                  ),
                ),
                Text(
                  name,
                  style: DwDarkTheme.headlineMedium,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.notifications),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DwDarkTheme.surfaceHighlight,
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: DwDarkTheme.textSecondary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildQuickStats(BuildContext context, int watchlistCount, int reservationsCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DwDarkTheme.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.bookmark_outline,
              label: 'Watchlist',
              value: watchlistCount.toString(),
              color: DwDarkTheme.accent,
              onTap: () => context.go(AppRoutes.watchlist),
            ),
          ),
          const SizedBox(width: DwDarkTheme.spacingSm),
          Expanded(
            child: _StatCard(
              icon: Icons.shopping_bag_outlined,
              label: 'Active Orders',
              value: reservationsCount.toString(),
              color: DwDarkTheme.accentGreen,
              onTap: () => context.go(AppRoutes.reservations),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DwDarkTheme.spacingMd,
        DwDarkTheme.spacingLg,
        DwDarkTheme.spacingMd,
        DwDarkTheme.spacingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: DwDarkTheme.titleMedium),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See all',
                style: DwDarkTheme.labelMedium.copyWith(
                  color: DwDarkTheme.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedListings(BuildContext context, List<SurplusListing> listings) {
    final featured = listings.take(5).toList();

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DwDarkTheme.spacingMd),
        itemCount: featured.length,
        separatorBuilder: (_, __) => const SizedBox(width: DwDarkTheme.spacingSm),
        itemBuilder: (context, index) {
          return _FeaturedCard(
            listing: featured[index],
            onTap: () => context.push(AppRoutes.listingDetailPath(featured[index].id)),
          );
        },
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      ('Food & Beverage', Icons.restaurant, DwDarkTheme.accentOrange),
      ('Retail Overstock', Icons.store, DwDarkTheme.accentPurple),
      ('Office Supplies', Icons.business, DwDarkTheme.accent),
      ('Construction', Icons.construction, DwDarkTheme.accentGreen),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DwDarkTheme.spacingMd),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: DwDarkTheme.spacingSm),
        itemBuilder: (context, index) {
          final (label, icon, color) = categories[index];
          return _CategoryCard(
            label: label,
            icon: icon,
            color: color,
            onTap: () => context.go(AppRoutes.discover),
          );
        },
      ),
    );
  }

  Widget _buildNearbyListings(BuildContext context, List<SurplusListing> listings) {
    final nearby = listings.where((l) => l.distanceKm != null).take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DwDarkTheme.spacingMd),
      child: Column(
        children: nearby.map((listing) {
          return Padding(
            padding: const EdgeInsets.only(bottom: DwDarkTheme.spacingSm),
            child: _NearbyCard(
              listing: listing,
              onTap: () => context.push(AppRoutes.listingDetailPath(listing.id)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
        decoration: BoxDecoration(
          color: DwDarkTheme.cardBackground,
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
          border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: DwDarkTheme.spacingSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: DwDarkTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: DwDarkTheme.labelSmall.copyWith(
                    color: DwDarkTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final SurplusListing listing;
  final VoidCallback onTap;

  const _FeaturedCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.imageUrls?.isNotEmpty == true
        ? listing.imageUrls!.first
        : listing.photoUrls?.isNotEmpty == true
            ? listing.photoUrls!.first
            : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: DwDarkTheme.cardBackground,
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
          border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(DwDarkTheme.radiusMd - 1),
                    ),
                    child: SizedBox(
                      width: double.infinity,
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
                  if (listing.discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: DwDarkTheme.accentGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${listing.discountPercent.toStringAsFixed(0)}%',
                          style: DwDarkTheme.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(DwDarkTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.safeTitle,
                    style: DwDarkTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${listing.currentPrice.toStringAsFixed(2)}',
                    style: DwDarkTheme.titleSmall.copyWith(
                      color: DwDarkTheme.accentGreen,
                      fontWeight: FontWeight.w700,
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

  Widget _buildPlaceholder() {
    return Container(
      color: DwDarkTheme.surfaceHighlight,
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, color: DwDarkTheme.textMuted, size: 32),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(DwDarkTheme.spacingSm),
        decoration: BoxDecoration(
          color: DwDarkTheme.cardBackground,
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
          border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: DwDarkTheme.spacingSm),
            Text(
              label,
              style: DwDarkTheme.labelSmall.copyWith(color: DwDarkTheme.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final SurplusListing listing;
  final VoidCallback onTap;

  const _NearbyCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.imageUrls?.isNotEmpty == true
        ? listing.imageUrls!.first
        : listing.photoUrls?.isNotEmpty == true
            ? listing.photoUrls!.first
            : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DwDarkTheme.spacingSm),
        decoration: BoxDecoration(
          color: DwDarkTheme.cardBackground,
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
          border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
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
            const SizedBox(width: DwDarkTheme.spacingSm),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.safeTitle,
                    style: DwDarkTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    listing.enterprise?.name ?? 'Unknown',
                    style: DwDarkTheme.labelSmall.copyWith(color: DwDarkTheme.textMuted),
                  ),
                ],
              ),
            ),

            // Distance & price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${listing.currentPrice.toStringAsFixed(2)}',
                  style: DwDarkTheme.titleSmall.copyWith(
                    color: DwDarkTheme.accentGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (listing.distanceKm != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: DwDarkTheme.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${listing.distanceKm!.toStringAsFixed(1)} km',
                        style: DwDarkTheme.labelSmall.copyWith(
                          color: DwDarkTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: DwDarkTheme.surfaceHighlight,
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, color: DwDarkTheme.textMuted, size: 24),
      ),
    );
  }
}

class _FeaturedLoadingState extends StatelessWidget {
  const _FeaturedLoadingState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DwDarkTheme.spacingMd),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: DwDarkTheme.spacingSm),
        itemBuilder: (_, __) => Container(
          width: 160,
          decoration: BoxDecoration(
            color: DwDarkTheme.cardBackground,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
          ),
        ),
      ),
    );
  }
}

class _NearbyLoadingState extends StatelessWidget {
  const _NearbyLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DwDarkTheme.spacingMd),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: DwDarkTheme.spacingSm),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: DwDarkTheme.cardBackground,
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
                border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
