import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategory;

  Future<void> _openScanner(BuildContext context) async {
    final result = await context.push<String>(AppRoutes.scanner);
    if (result != null && context.mounted) {
      // Show scanned result - could search for product or show info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanned: $result'),
          action: SnackBarAction(
            label: 'Search',
            onPressed: () {
              // Could navigate to search with the barcode
              context.push(AppRoutes.search);
            },
          ),
        ),
      );
    }
  }

  final _categories = [
    CategoryChipData(id: 'all', label: 'All', icon: Icons.grid_view_rounded),
    CategoryChipData(id: 'food', label: 'Food', icon: Icons.restaurant_rounded, color: const Color(0xFFF97316)),
    CategoryChipData(id: 'retail', label: 'Retail', icon: Icons.store_rounded, color: const Color(0xFF8B5CF6)),
    CategoryChipData(id: 'office', label: 'Office', icon: Icons.business_rounded, color: const Color(0xFF3B82F6)),
    CategoryChipData(id: 'build', label: 'Build', icon: Icons.construction_rounded, color: const Color(0xFF22C55E)),
    CategoryChipData(id: 'hotel', label: 'Hotel', icon: Icons.hotel_rounded, color: const Color(0xFFEC4899)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;
    final user = ref.watch(currentUserProvider);
    final listingsAsync = ref.watch(listingsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.background,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(listingsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: theme.accent,
          backgroundColor: theme.surface,
          child: CustomScrollView(
            slivers: [
              // Top safe area
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.top + PremiumTheme.space8),
              ),

              // Top pill bar
              SliverToBoxAdapter(
                child: TopPillBar(
                  title: user?.name ?? 'Welcome',
                  subtitle: 'Find surplus deals nearby',
                  leadingIcon: Icons.location_on_rounded,
                  trailingInfo: '24°C',
                  trailingInfoIcon: Icons.wb_sunny_outlined,
                  onLeadingTap: () => context.push(AppRoutes.search),
                  onScannerTap: () => _openScanner(context),
                  onNotificationTap: () => context.push(AppRoutes.notifications),
                  notificationCount: 3,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: PremiumTheme.space20)),

              // Categories
              SliverToBoxAdapter(
                child: CategoryChipsRow(
                  categories: _categories,
                  selectedId: _selectedCategory,
                  onSelected: (id) => setState(() {
                    _selectedCategory = id == 'all' ? null : id;
                  }),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: PremiumTheme.space24)),

              // Featured section header
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Featured Deals',
                  actionLabel: 'See all',
                  onAction: () => context.go(AppRoutes.discover),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: PremiumTheme.space12)),

              // Featured carousel
              listingsAsync.when(
                data: (state) => SliverToBoxAdapter(
                  child: _buildFeaturedCarousel(state.listings),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: _FeaturedLoadingState(),
                ),
                error: (_, __) => const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: PremiumTheme.space28)),

              // Nearby section header
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Nearby',
                  actionLabel: 'View map',
                  onAction: () => context.go(AppRoutes.map),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: PremiumTheme.space12)),

              // Nearby listings
              listingsAsync.when(
                data: (state) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.space16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final nearby = state.listings.where((l) => l.distanceKm != null).take(5).toList();
                        if (index >= nearby.length) return null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: PremiumTheme.space12),
                          child: _NearbyCard(
                            listing: nearby[index],
                            onTap: () => context.push(AppRoutes.listingDetailPath(nearby[index].id)),
                          ),
                        );
                      },
                      childCount: 5,
                    ),
                  ),
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
                child: SizedBox(height: PremiumTheme.space32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(List<SurplusListing> listings) {
    final featured = listings.take(5).toList();
    final items = featured.map((l) => FeatureCardData(
      id: l.id.toString(),
      imageUrl: l.imageUrls.isNotEmpty ? l.imageUrls.first : l.photoUrls?.firstOrNull,
      badge: l.hasDiscount ? '-${l.discountPercentage!.toStringAsFixed(0)}% OFF' : null,
      badgeColor: const Color(0xFF22C55E),
      title: l.safeTitle,
      subtitle: l.enterprise.name,
    )).toList();

    return FeatureCardCarousel(
      items: items,
      height: 300,
      onItemTap: (item) {
        final listing = featured.firstWhere((l) => l.id.toString() == item.id);
        context.push(AppRoutes.listingDetailPath(listing.id));
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.space16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.headlineMedium),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: theme.labelLarge.copyWith(color: theme.accent),
              ),
            ),
        ],
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
    final theme = context.premium;
    final imageUrl = listing.imageUrls.isNotEmpty 
        ? listing.imageUrls.first 
        : listing.photoUrls?.firstOrNull;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumTheme.space12),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
          boxShadow: theme.shadowSm,
          border: Border.all(color: theme.borderSubtle, width: 1),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.surfaceSecondary,
                borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildPlaceholder(theme),
                        errorWidget: (_, __, ___) => _buildPlaceholder(theme),
                      )
                    : _buildPlaceholder(theme),
              ),
            ),
            const SizedBox(width: PremiumTheme.space12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.safeTitle,
                    style: theme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PremiumTheme.space2),
                  Text(
                    listing.enterprise.name,
                    style: theme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PremiumTheme.space6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PremiumTheme.space8,
                          vertical: PremiumTheme.space4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.successLight,
                          borderRadius: BorderRadius.circular(PremiumTheme.radiusSm),
                        ),
                        child: Text(
                          '\$${listing.currentPrice.toStringAsFixed(2)}',
                          style: theme.labelSmall.copyWith(
                            color: theme.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (listing.distanceKm != null) ...[
                        const SizedBox(width: PremiumTheme.space8),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: theme.textTertiary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${listing.distanceKm!.toStringAsFixed(1)} km',
                          style: theme.caption,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(PremiumTheme theme) {
    return Container(
      color: theme.surfaceSecondary,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: theme.textMuted,
          size: 28,
        ),
      ),
    );
  }
}

class _FeaturedLoadingState extends StatelessWidget {
  const _FeaturedLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: PremiumTheme.space16),
      decoration: BoxDecoration(
        color: theme.surfaceSecondary,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusXl),
      ),
    );
  }
}

class _NearbyLoadingState extends StatelessWidget {
  const _NearbyLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.space16),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: PremiumTheme.space12),
            child: Container(
              height: 96,
              decoration: BoxDecoration(
                color: theme.surfaceSecondary,
                borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
