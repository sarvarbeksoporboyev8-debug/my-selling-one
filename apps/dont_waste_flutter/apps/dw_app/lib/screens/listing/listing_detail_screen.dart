import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final int listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));
    final isInWatchlist = ref.watch(isInWatchlistProvider(widget.listingId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: listingAsync.when(
        data: (listing) => _buildContent(listing, isInWatchlist),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2D6A4F))),
        error: (e, _) => _buildError(e.toString()),
      ),
    );
  }

  Widget _buildContent(SurplusListing listing, bool isInWatchlist) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.45;

    return Stack(
      children: [
        // Scrollable Content
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Image Space
            SliverToBoxAdapter(child: SizedBox(height: imageHeight)),
            // Content Card
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    _buildMainInfo(listing),
                    _buildStoreCard(listing),
                    _buildStatsRow(listing),
                    _buildDescription(listing),
                    _buildPickupInfo(listing),
                    _buildSafetyTips(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Fixed Image Header
        Positioned(
          top: 0, left: 0, right: 0,
          height: imageHeight - (_scrollOffset * 0.5).clamp(0, imageHeight * 0.3),
          child: _buildImageHeader(listing, isInWatchlist),
        ),

        // Bottom Action Bar
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _buildBottomBar(listing),
        ),
      ],
    );
  }

  Widget _buildImageHeader(SurplusListing listing, bool isInWatchlist) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        listing.primaryPhotoUrl != null
            ? CachedNetworkImage(
                imageUrl: listing.primaryPhotoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFFE0E0E0)),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFFE0E0E0),
                  child: const Icon(Icons.image, size: 64, color: Colors.grey),
                ),
              )
            : Container(color: const Color(0xFF2D6A4F)),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Top Bar
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16, right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircleButton(Icons.arrow_back_rounded, () => context.pop()),
              Row(
                children: [
                  _buildCircleButton(
                    isInWatchlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    () {
                      if (isInWatchlist) {
                        ref.read(watchlistProvider.notifier).removeFromWatchlist(widget.listingId);
                      } else {
                        final l = ref.read(listingDetailProvider(widget.listingId)).valueOrNull;
                        if (l != null) ref.read(watchlistProvider.notifier).addToWatchlist(l);
                      }
                    },
                    isActive: isInWatchlist,
                  ),
                  const SizedBox(width: 12),
                  _buildCircleButton(Icons.share_rounded, () {}),
                ],
              ),
            ],
          ),
        ),

        // Discount Badge
        if (listing.hasDiscount)
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '-${listing.discountPercentage!.toStringAsFixed(0)}% OFF',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),

        // Time Badge
        Positioned(
          bottom: 40,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 16, color: listing.isUrgent ? Colors.red : Colors.orange[700]),
                const SizedBox(width: 6),
                Text(
                  listing.timeLeftDisplay,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: listing.isUrgent ? Colors.red : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF5252) : Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
        ),
        child: Icon(icon, color: isActive ? Colors.white : const Color(0xFF1B4332), size: 22),
      ),
    );
  }

  Widget _buildMainInfo(SurplusListing listing) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            listing.displayName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${listing.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D6A4F),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'per ${listing.unit}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              if (listing.hasDiscount) ...[
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '\$${listing.basePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.store_rounded, color: Color(0xFF2D6A4F), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        listing.enterprise.name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1B4332)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (listing.enterprise.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: Color(0xFF2D6A4F), size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text('4.8', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    Text(' (124 reviews)', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF1B4332)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatItem(Icons.inventory_2_outlined, '${listing.quantityAvailable.toStringAsFixed(0)} ${listing.unit}', 'Available'),
          _buildStatDivider(),
          _buildStatItem(Icons.location_on_outlined, listing.distanceKm != null ? '${listing.distanceKm!.toStringAsFixed(1)} km' : 'N/A', 'Distance'),
          _buildStatDivider(),
          _buildStatItem(Icons.access_time_rounded, listing.timeLeftDisplay, 'Expires'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2D6A4F), size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() => const SizedBox(width: 12);

  Widget _buildDescription(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: Color(0xFF2D6A4F), size: 22),
              const SizedBox(width: 10),
              const Text('About this item', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1B4332))),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            listing.description ?? 'Fresh quality product available for pickup. Reserve now before it expires!',
            style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
          ),
          if (listing.qualityNotes != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      listing.qualityNotes!,
                      style: TextStyle(fontSize: 13, color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPickupInfo(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_outlined, color: Color(0xFF2D6A4F), size: 22),
              const SizedBox(width: 10),
              const Text('Pickup Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1B4332))),
            ],
          ),
          const SizedBox(height: 16),
          _buildPickupRow(Icons.schedule_rounded, 'Pickup Window', listing.pickupWindowDisplay),
          const SizedBox(height: 14),
          _buildPickupRow(Icons.location_on_rounded, 'Location', listing.pickupLocation?.shortDisplay ?? 'Address available after reservation'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.map_rounded, size: 40, color: Color(0xFFBDBDBD)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2D6A4F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2D6A4F), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1B4332))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTips() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco_rounded, color: Color(0xFF2D6A4F)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Save Food, Save Money', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B4332))),
                const SizedBox(height: 2),
                Text('By reserving this item, you help reduce food waste', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(SurplusListing listing) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          // Price Summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Starting at', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${listing.currentPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2, left: 4),
                      child: Text('/${listing.unit}', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Reserve Button
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.reservePath(widget.listingId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Reserve Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800])),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.invalidate(listingDetailProvider(widget.listingId)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D6A4F)),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
