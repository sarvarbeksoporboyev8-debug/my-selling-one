import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String? _selectedCategory;
  final _scrollController = ScrollController();

  final _categories = [
    ('All', Icons.grid_view, null),
    ('Food', Icons.restaurant, 'food'),
    ('Retail', Icons.store, 'retail'),
    ('Office', Icons.business, 'office'),
    ('Build', Icons.construction, 'construction'),
    ('Hotel', Icons.hotel, 'hospitality'),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: DwDarkTheme.background,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // App bar with search
            SliverAppBar(
              backgroundColor: DwDarkTheme.background,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              floating: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: DwDarkTheme.spacingMd,
                    right: DwDarkTheme.spacingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discover', style: DwDarkTheme.headlineMedium),
                      const SizedBox(height: DwDarkTheme.spacingSm),
                      _buildSearchBar(),
                    ],
                  ),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: _buildCategoryFilter(),
            ),
          ],
          body: listingsAsync.when(
            data: (state) => _buildListingsGrid(state.listings),
            loading: () => _buildLoadingGrid(),
            error: (error, _) => _buildErrorState(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.search),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DwDarkTheme.spacingMd,
          vertical: DwDarkTheme.spacingSm + 4,
        ),
        decoration: BoxDecoration(
          color: DwDarkTheme.surfaceHighlight,
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
          border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: DwDarkTheme.textTertiary, size: 22),
            const SizedBox(width: DwDarkTheme.spacingSm),
            Expanded(
              child: Text(
                'Search surplus inventory...',
                style: DwDarkTheme.bodyMedium.copyWith(color: DwDarkTheme.textMuted),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: DwDarkTheme.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.tune, color: DwDarkTheme.accent, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: DwDarkTheme.spacingSm),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DwDarkTheme.spacingMd),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: DwDarkTheme.spacingSm),
        itemBuilder: (context, index) {
          final (label, icon, value) = _categories[index];
          final isSelected = _selectedCategory == value;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: DwDarkTheme.spacingMd,
                vertical: DwDarkTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? DwDarkTheme.accent.withOpacity(0.15)
                    : DwDarkTheme.surfaceHighlight,
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                border: Border.all(
                  color: isSelected
                      ? DwDarkTheme.accent.withOpacity(0.5)
                      : DwDarkTheme.cardBorder,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? DwDarkTheme.accent : DwDarkTheme.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: DwDarkTheme.labelMedium.copyWith(
                      color: isSelected ? DwDarkTheme.accent : DwDarkTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListingsGrid(List<SurplusListing> listings) {
    // Filter by category if selected
    final filteredListings = _selectedCategory == null
        ? listings
        : listings.where((l) {
            // Check taxons for category match
            final taxonNames = l.taxons.map((t) => t.name.toLowerCase()).join(' ');
            final title = l.safeTitle.toLowerCase();
            return taxonNames.contains(_selectedCategory!) || title.contains(_selectedCategory!);
          }).toList();

    if (filteredListings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(listingsProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: DwDarkTheme.accent,
      backgroundColor: DwDarkTheme.surface,
      child: GridView.builder(
        padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: DwDarkTheme.spacingMd,
          crossAxisSpacing: DwDarkTheme.spacingMd,
          childAspectRatio: 0.72,
        ),
        itemCount: filteredListings.length,
        itemBuilder: (context, index) {
          return _ListingCard(
            listing: filteredListings[index],
            onTap: () => context.push(
              AppRoutes.listingDetailPath(filteredListings[index].id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: DwDarkTheme.spacingMd,
        crossAxisSpacing: DwDarkTheme.spacingMd,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }

  Widget _buildEmptyState() {
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
                color: DwDarkTheme.textMuted.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 36,
                color: DwDarkTheme.textMuted.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: DwDarkTheme.spacingLg),
            Text(
              'No listings found',
              style: DwDarkTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DwDarkTheme.spacingSm),
            Text(
              'Try adjusting your filters or check back later.',
              style: DwDarkTheme.bodyMedium.copyWith(color: DwDarkTheme.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
                color: DwDarkTheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 36,
                color: DwDarkTheme.error.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: DwDarkTheme.spacingLg),
            Text('Something went wrong', style: DwDarkTheme.headlineSmall),
            const SizedBox(height: DwDarkTheme.spacingSm),
            Text(
              error,
              style: DwDarkTheme.bodyMedium.copyWith(color: DwDarkTheme.textTertiary),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: DwDarkTheme.spacingLg),
            GestureDetector(
              onTap: () => ref.invalidate(listingsProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DwDarkTheme.spacingLg,
                  vertical: DwDarkTheme.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: DwDarkTheme.surfaceHighlight,
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
                  border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, size: 18, color: DwDarkTheme.textSecondary),
                    const SizedBox(width: DwDarkTheme.spacingSm),
                    Text(
                      'Try Again',
                      style: DwDarkTheme.titleSmall.copyWith(color: DwDarkTheme.textSecondary),
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
}

class _ListingCard extends StatelessWidget {
  final SurplusListing listing;
  final VoidCallback onTap;

  const _ListingCard({required this.listing, required this.onTap});

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
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(DwDarkTheme.radiusMd - 1),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
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
                  // Discount badge
                  if (listing.hasDiscount)
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
                          '-${listing.discountPercentage!.toStringAsFixed(0)}%',
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(DwDarkTheme.spacingSm + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.safeTitle,
                      style: DwDarkTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '\$${listing.currentPrice.toStringAsFixed(2)}',
                          style: DwDarkTheme.titleSmall.copyWith(
                            color: DwDarkTheme.accentGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (listing.originalPrice != null &&
                            listing.originalPrice! > listing.currentPrice) ...[
                          const SizedBox(width: 4),
                          Text(
                            '\$${listing.originalPrice!.toStringAsFixed(0)}',
                            style: DwDarkTheme.labelSmall.copyWith(
                              color: DwDarkTheme.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${listing.quantity.toStringAsFixed(0)} ${listing.unit} left',
                      style: DwDarkTheme.labelSmall.copyWith(
                        color: DwDarkTheme.textMuted,
                      ),
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

  Widget _buildPlaceholder() {
    return Container(
      color: DwDarkTheme.surfaceHighlight,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: DwDarkTheme.textMuted,
          size: 32,
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DwDarkTheme.cardBackground,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: DwDarkTheme.surfaceHighlight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DwDarkTheme.radiusMd - 1),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(DwDarkTheme.spacingSm + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: DwDarkTheme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: DwDarkTheme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 16,
                    width: 60,
                    decoration: BoxDecoration(
                      color: DwDarkTheme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
