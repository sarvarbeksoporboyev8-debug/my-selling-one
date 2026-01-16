import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';
import '../../utils/map_utils.dart';

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
    _scrollController.addListener(() => setState(() => _scrollOffset = _scrollController.offset));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getCategoryFromListing(SurplusListing listing) {
    final name = listing.displayName.toLowerCase();
    if (name.contains('chair') || name.contains('desk') || name.contains('office')) return 'Office & Corporate';
    if (name.contains('tile') || name.contains('paint') || name.contains('wood')) return 'Construction';
    if (name.contains('clothing') || name.contains('electronic') || name.contains('accessor')) return 'Retail Overstock';
    if (name.contains('linen') || name.contains('tableware') || name.contains('hotel')) return 'Hospitality';
    if (name.contains('pallet') || name.contains('box') || name.contains('packaging')) return 'Packaging';
    return 'Food & Beverage';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Office & Corporate': return const Color(0xFF2196F3);
      case 'Construction': return const Color(0xFFFF9800);
      case 'Retail Overstock': return const Color(0xFFE91E63);
      case 'Hospitality': return const Color(0xFF9C27B0);
      case 'Packaging': return const Color(0xFF795548);
      default: return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));
    final isInWatchlist = ref.watch(isInWatchlistProvider(widget.listingId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: listingAsync.when(
        data: (listing) => _buildContent(listing, isInWatchlist),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A5F))),
        error: (e, _) => _buildError(e.toString()),
      ),
    );
  }

  Widget _buildContent(SurplusListing listing, bool isInWatchlist) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.4;
    final category = _getCategoryFromListing(listing);
    final catColor = _getCategoryColor(category);

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: imageHeight)),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFFF5F6FA), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                child: Column(
                  children: [
                    _buildMainInfo(listing, category, catColor),
                    _buildConditionCard(listing),
                    _buildSupplierCard(listing),
                    _buildStatsRow(listing),
                    _buildDescription(listing),
                    _buildPickupInfo(listing),
                    _buildBulkPricing(listing),
                    _buildSustainabilityBanner(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(top: 0, left: 0, right: 0, height: imageHeight - (_scrollOffset * 0.5).clamp(0, imageHeight * 0.3),
          child: _buildImageHeader(listing, isInWatchlist, catColor)),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar(listing)),
      ],
    );
  }

  Widget _buildImageHeader(SurplusListing listing, bool isInWatchlist, Color catColor) {
    return Stack(
      fit: StackFit.expand,
      children: [
        listing.primaryPhotoUrl != null
            ? CachedNetworkImage(imageUrl: listing.primaryPhotoUrl!, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFFE0E0E0)),
                errorWidget: (_, __, ___) => Container(color: const Color(0xFFE0E0E0), child: const Icon(Icons.image, size: 64, color: Colors.grey)))
            : Container(color: catColor.withOpacity(0.3)),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.4)], stops: const [0.0, 0.4, 1.0]))),
        Positioned(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildCircleButton(Icons.arrow_back_rounded, () => context.pop()),
            Row(children: [
              _buildCircleButton(isInWatchlist ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, () {
                if (isInWatchlist) {
                  ref.read(watchlistProvider.notifier).removeFromWatchlist(widget.listingId);
                } else {
                  final l = ref.read(listingDetailProvider(widget.listingId)).valueOrNull;
                  if (l != null) ref.read(watchlistProvider.notifier).addToWatchlist(l);
                }
              }, isActive: isInWatchlist),
              const SizedBox(width: 12),
              _buildCircleButton(Icons.share_rounded, () {}),
            ]),
          ])),
        if (listing.hasDiscount)
          Positioned(top: MediaQuery.of(context).padding.top + 70, left: 16,
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFFF5252), borderRadius: BorderRadius.circular(12)),
              child: Text('SAVE ${listing.discountPercentage!.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)))),
        Positioned(bottom: 40, left: 16, right: 16,
          child: Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
              child: Row(children: [
                Icon(Icons.schedule_rounded, size: 16, color: listing.isUrgent ? Colors.red : Colors.orange[700]),
                const SizedBox(width: 6),
                Text(listing.timeLeftDisplay, style: TextStyle(fontWeight: FontWeight.w600, color: listing.isUrgent ? Colors.red : Colors.orange[700])),
              ])),
            const SizedBox(width: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
              child: Row(children: [
                const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF1E3A5F)),
                const SizedBox(width: 6),
                Text('${listing.quantityAvailable.toStringAsFixed(0)} ${listing.unit}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
              ])),
          ])),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 44, height: 44,
        decoration: BoxDecoration(color: isActive ? const Color(0xFF1E3A5F) : Colors.white.withOpacity(0.95), shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)]),
        child: Icon(icon, color: isActive ? Colors.white : const Color(0xFF1E3A5F), size: 22)),
    );
  }

  Widget _buildMainInfo(SurplusListing listing, String category, Color catColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: catColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(category, style: TextStyle(color: catColor, fontWeight: FontWeight.w600, fontSize: 13))),
        const SizedBox(height: 12),
        Text(listing.displayName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F), height: 1.2)),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('\$${listing.currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('per ${listing.unit}', style: TextStyle(fontSize: 16, color: Colors.grey[600]))),
          if (listing.hasDiscount) ...[
            const SizedBox(width: 12),
            Padding(padding: const EdgeInsets.only(bottom: 4),
              child: Text('\$${listing.basePrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, color: Colors.grey[400], decoration: TextDecoration.lineThrough))),
          ],
        ]),
      ]),
    );
  }

  Widget _buildConditionCard(SurplusListing listing) {
    final condition = listing.qualityNotes ?? 'Condition: New / Unused';
    final isNew = condition.toLowerCase().contains('new');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isNew ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: isNew ? const Color(0xFF4CAF50).withOpacity(0.2) : const Color(0xFFFF9800).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Icon(isNew ? Icons.verified_rounded : Icons.info_outline_rounded, color: isNew ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isNew ? 'New / Unused' : 'Pre-owned', style: TextStyle(fontWeight: FontWeight.w600, color: isNew ? const Color(0xFF2E7D32) : const Color(0xFFE65100), fontSize: 15)),
          const SizedBox(height: 2),
          Text(condition.replaceAll('Condition: ', ''), style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ])),
      ]),
    );
  }

  Widget _buildSupplierCard(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(children: [
        Container(width: 56, height: 56,
          decoration: BoxDecoration(color: const Color(0xFF1E3A5F).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.business_rounded, color: Color(0xFF1E3A5F), size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(listing.enterprise.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)), overflow: TextOverflow.ellipsis)),
            if (listing.enterprise.isVerified) ...[const SizedBox(width: 6), const Icon(Icons.verified_rounded, color: Color(0xFF1E3A5F), size: 18)],
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.star_rounded, size: 16, color: Colors.amber[600]),
            const SizedBox(width: 4),
            Text('4.8', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
            Text(' · 47 transactions', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ]),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF1E3A5F).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Text('Contact', style: TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.w600, fontSize: 13))),
      ]),
    );
  }

  Widget _buildStatsRow(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(children: [
        _buildStatItem(Icons.inventory_2_outlined, '${listing.quantityAvailable.toStringAsFixed(0)}', listing.unit),
        const SizedBox(width: 12),
        _buildStatItem(Icons.location_on_outlined, listing.distanceKm != null ? '${listing.distanceKm!.toStringAsFixed(1)}' : 'N/A', 'km away'),
        const SizedBox(width: 12),
        _buildStatItem(Icons.local_shipping_outlined, 'Pickup', 'Only'),
      ]),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF1E3A5F), size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ])),
    );
  }

  Widget _buildDescription(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.description_outlined, color: Color(0xFF1E3A5F), size: 22),
          SizedBox(width: 10),
          Text('Product Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
        ]),
        const SizedBox(height: 14),
        Text(listing.description ?? 'Quality surplus inventory available for immediate pickup. Contact supplier for more details.',
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5)),
      ]),
    );
  }

  Widget _buildPickupInfo(SurplusListing listing) {
    final hasLocation = listing.pickupLocation?.latitude != null && listing.pickupLocation?.longitude != null;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.place_outlined, color: Color(0xFF1E3A5F), size: 22),
          SizedBox(width: 10),
          Text('Pickup Location', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
        ]),
        const SizedBox(height: 16),
        _buildPickupRow(Icons.schedule_rounded, 'Available', listing.pickupWindowDisplay),
        const SizedBox(height: 14),
        _buildPickupRow(Icons.location_on_rounded, 'Address', listing.pickupLocation?.shortDisplay ?? 'Revealed after claim'),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: hasLocation ? () => _openDirections(listing) : null,
          child: Container(
            width: double.infinity, 
            height: 100,
            decoration: BoxDecoration(
              color: hasLocation ? const Color(0xFF1E3A5F).withOpacity(0.08) : const Color(0xFFF5F5F5), 
              borderRadius: BorderRadius.circular(12),
              border: hasLocation ? Border.all(color: const Color(0xFF1E3A5F).withOpacity(0.2)) : null,
            ),
            child: hasLocation 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.directions_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get Directions',
                      style: TextStyle(
                        color: Color(0xFF1E3A5F),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              : const Center(child: Icon(Icons.map_rounded, size: 40, color: Color(0xFFBDBDBD))),
          ),
        ),
      ]),
    );
  }

  void _openDirections(SurplusListing listing) {
    if (listing.pickupLocation?.latitude == null || listing.pickupLocation?.longitude == null) return;
    
    MapUtils.openDirections(
      context: context,
      destinationLatitude: listing.pickupLocation!.latitude!,
      destinationLongitude: listing.pickupLocation!.longitude!,
      destinationTitle: listing.enterprise.name,
    );
  }

  Widget _buildPickupRow(IconData icon, String label, String value) {
    return Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: const Color(0xFF1E3A5F).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF1E3A5F), size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E3A5F))),
      ])),
    ]);
  }

  Widget _buildBulkPricing(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.local_offer_outlined, color: Color(0xFF1E3A5F), size: 22),
          SizedBox(width: 10),
          Text('Bulk Pricing', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
        ]),
        const SizedBox(height: 16),
        _buildPriceTier('1-10 ${listing.unit}', '\$${listing.currentPrice.toStringAsFixed(2)}', false),
        _buildPriceTier('11-50 ${listing.unit}', '\$${(listing.currentPrice * 0.9).toStringAsFixed(2)}', false),
        _buildPriceTier('50+ ${listing.unit}', '\$${(listing.currentPrice * 0.8).toStringAsFixed(2)}', true),
      ]),
    );
  }

  Widget _buildPriceTier(String qty, String price, bool isBest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isBest ? const Color(0xFF1E3A5F).withOpacity(0.08) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: isBest ? Border.all(color: const Color(0xFF1E3A5F), width: 1.5) : null),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Text(qty, style: TextStyle(fontWeight: FontWeight.w500, color: isBest ? const Color(0xFF1E3A5F) : Colors.grey[700])),
          if (isBest) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFF1E3A5F), borderRadius: BorderRadius.circular(4)),
            child: const Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))],
        ]),
        Text('$price/unit', style: TextStyle(fontWeight: FontWeight.w600, color: isBest ? const Color(0xFF1E3A5F) : Colors.grey[700])),
      ]),
    );
  }

  Widget _buildSustainabilityBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: const Color(0xFF1E3A5F).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.eco_rounded, color: Color(0xFF1E3A5F))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Reduce Waste, Save Money', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
          const SizedBox(height: 2),
          Text('This purchase helps divert surplus from landfills', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ])),
      ]),
    );
  }

  Widget _buildBottomBar(SurplusListing listing) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))]),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Starting at', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${listing.currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
            Padding(padding: const EdgeInsets.only(bottom: 2, left: 4), child: Text('/${listing.unit}', style: TextStyle(fontSize: 14, color: Colors.grey[500]))),
          ]),
        ])),
        const SizedBox(width: 16),
        Expanded(child: SizedBox(height: 56,
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.reservePath(widget.listingId)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: const Text('Claim Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))))),
      ]),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800])),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => ref.invalidate(listingDetailProvider(widget.listingId)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)),
            child: const Text('Try Again')),
        ])),
    );
  }
}
