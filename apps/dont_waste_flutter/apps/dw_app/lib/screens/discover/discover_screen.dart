import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _scrollController = ScrollController();
  String _selectedCategory = 'all';

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(listingsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(listingsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: listings.when(
            data: (state) => _buildContent(state),
            loading: () => _buildLoading(),
            error: (error, _) => _buildError(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ListingsState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(listingsProvider.notifier).refresh(),
      color: const Color(0xFF1E3A5F),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildCategories()),
          if (state.listings.isNotEmpty)
            SliverToBoxAdapter(child: _buildFeaturedSection(state.listings.take(3).toList())),
          SliverToBoxAdapter(child: _buildSectionTitle('Available Near You', '${state.listings.length} listings')),
          state.listings.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => index >= state.listings.length
                          ? _buildCardSkeleton()
                          : _buildListingCard(state.listings[index]),
                      childCount: state.listings.length + (state.isLoadingMore ? 2 : 0),
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = ref.watch(currentUserProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(), style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(user?.name ?? 'Business User',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: IconButton(icon: const Icon(Icons.notifications_outlined), color: const Color(0xFF1E3A5F), onPressed: () {}),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.search),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[400], size: 22),
              const SizedBox(width: 12),
              Text('Search surplus inventory...', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF1E3A5F).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.tune, color: Color(0xFF1E3A5F), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'id': 'all', 'icon': Icons.grid_view_rounded, 'label': 'All', 'color': const Color(0xFF1E3A5F)},
      {'id': 'food', 'icon': Icons.restaurant_rounded, 'label': 'Food', 'color': const Color(0xFF4CAF50)},
      {'id': 'retail', 'icon': Icons.shopping_bag_rounded, 'label': 'Retail', 'color': const Color(0xFFE91E63)},
      {'id': 'construction', 'icon': Icons.construction_rounded, 'label': 'Build', 'color': const Color(0xFFFF9800)},
      {'id': 'office', 'icon': Icons.business_rounded, 'label': 'Office', 'color': const Color(0xFF2196F3)},
      {'id': 'hospitality', 'icon': Icons.hotel_rounded, 'label': 'Hotel', 'color': const Color(0xFF9C27B0)},
      {'id': 'packaging', 'icon': Icons.inventory_2_rounded, 'label': 'Pack', 'color': const Color(0xFF795548)},
      {'id': 'more', 'icon': Icons.more_horiz_rounded, 'label': 'More', 'color': const Color(0xFF607D8B)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = _selectedCategory == cat['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['id'] as String),
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: isSelected ? cat['color'] as Color : (cat['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected ? [BoxShadow(color: (cat['color'] as Color).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : null,
                      ),
                      child: Icon(cat['icon'] as IconData, color: isSelected ? Colors.white : cat['color'] as Color, size: 26),
                    ),
                    const SizedBox(height: 8),
                    Text(cat['label'] as String,
                      style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey[600])),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(List<SurplusListing> featured) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hot Deals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                  Text('Expiring soon - act fast', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text('See all', style: TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: featured.length,
            itemBuilder: (context, index) => _buildFeaturedCard(featured[index]),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeaturedCard(SurplusListing listing) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.listingDetailPath(listing.id)),
      child: Container(
        width: 300, margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              listing.primaryPhotoUrl != null
                  ? CachedNetworkImage(imageUrl: listing.primaryPhotoUrl!, fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[200]),
                      errorWidget: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 40)))
                  : Container(color: Colors.grey[200]),
              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.75)]))),
              // Badges
              Positioned(top: 12, left: 12, child: _buildCategoryBadge(listing)),
              if (listing.hasDiscount)
                Positioned(top: 12, right: 12, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFFF5252), borderRadius: BorderRadius.circular(8)),
                  child: Text('-${listing.discountPercentage!.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                )),
              // Content
              Positioned(bottom: 14, left: 14, right: 14, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.displayName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(listing.enterprise.name, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Text('\$${listing.currentPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(' /${listing.unit}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          Icon(Icons.schedule, size: 14, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Text(listing.timeLeftDisplay, style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w600, fontSize: 12)),
                        ]),
                      ),
                    ],
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(SurplusListing listing) {
    final catName = _getCategoryFromListing(listing);
    final catColor = _getCategoryColor(catName);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(8)),
      child: Text(catName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }

  String _getCategoryFromListing(SurplusListing listing) {
    final name = listing.displayName.toLowerCase();
    if (name.contains('chair') || name.contains('desk') || name.contains('office')) return 'Office';
    if (name.contains('tile') || name.contains('paint') || name.contains('wood')) return 'Construction';
    if (name.contains('clothing') || name.contains('electronic') || name.contains('accessor')) return 'Retail';
    if (name.contains('linen') || name.contains('tableware') || name.contains('hotel')) return 'Hospitality';
    if (name.contains('pallet') || name.contains('box') || name.contains('packaging')) return 'Packaging';
    return 'Food';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Office': return const Color(0xFF2196F3);
      case 'Construction': return const Color(0xFFFF9800);
      case 'Retail': return const Color(0xFFE91E63);
      case 'Hospitality': return const Color(0xFF9C27B0);
      case 'Packaging': return const Color(0xFF795548);
      default: return const Color(0xFF4CAF50);
    }
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
            Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ]),
          TextButton(onPressed: () {}, child: const Text('Filter', style: TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildListingCard(SurplusListing listing) {
    final catName = _getCategoryFromListing(listing);
    final catColor = _getCategoryColor(catName);
    
    return GestureDetector(
      onTap: () => context.push(AppRoutes.listingDetailPath(listing.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: listing.primaryPhotoUrl != null
                        ? CachedNetworkImage(imageUrl: listing.primaryPhotoUrl!, fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: const Color(0xFFF5F5F5)),
                            errorWidget: (_, __, ___) => Container(color: const Color(0xFFF5F5F5), child: const Icon(Icons.image_outlined, color: Color(0xFFBDBDBD), size: 32)))
                        : Container(color: const Color(0xFFF5F5F5), child: const Icon(Icons.image_outlined, color: Color(0xFFBDBDBD), size: 32)),
                  ),
                  // Category Badge
                  Positioned(top: 8, left: 8, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(6)),
                    child: Text(catName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10)),
                  )),
                  // Discount Badge
                  if (listing.hasDiscount)
                    Positioned(top: 8, right: 8, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFFF5252), borderRadius: BorderRadius.circular(6)),
                      child: Text('-${listing.discountPercentage!.toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
                    )),
                  // Quantity Badge
                  Positioned(bottom: 8, right: 8, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(6)),
                    child: Text('${listing.quantityAvailable.toStringAsFixed(0)} ${listing.unit}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 10)),
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F), height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(listing.enterprise.name, style: const TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('\$${listing.currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E3A5F))),
                      if (listing.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text('\$${listing.basePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E), decoration: TextDecoration.lineThrough)),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(4)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.schedule_rounded, size: 11, color: Color(0xFFE65100)),
                          const SizedBox(width: 3),
                          Text(listing.timeLeftDisplay, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFE65100))),
                        ]),
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

  Widget _buildLoading() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverToBoxAdapter(child: _buildCategories()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.68),
            delegate: SliverChildBuilderDelegate((_, __) => _buildCardSkeleton(), childCount: 6),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 1.1, child: Container(
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 6),
              Container(height: 12, width: 80, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 10),
              Row(children: [
                Container(height: 16, width: 50, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                const Spacer(),
                Container(height: 18, width: 55, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No surplus available', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          const SizedBox(height: 8),
          Text('Check back later or adjust your filters.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
        ]),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text('Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.invalidate(listingsProvider),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Try Again'),
          ),
        ]),
      ),
    );
  }
}
