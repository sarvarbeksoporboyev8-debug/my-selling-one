import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final listings = ref.watch(listingsProvider);
    final reservations = ref.watch(reservationsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(listingsProvider);
                ref.invalidate(reservationsProvider);
              },
              color: const Color(0xFF1E3A5F),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(user)),
                  SliverToBoxAdapter(child: _buildStatsCards(listings, reservations)),
                  SliverToBoxAdapter(child: _buildQuickActions()),
                  SliverToBoxAdapter(child: _buildActiveClaimsSection(reservations)),
                  SliverToBoxAdapter(child: _buildRecentActivitySection(listings)),
                  SliverToBoxAdapter(child: _buildMarketInsights()),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User? user) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2E5077)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF1E3A5F).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Text(
                user?.name?.substring(0, 1).toUpperCase() ?? 'B',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(
                  user?.name ?? 'Business User',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                ),
              ],
            ),
          ),
          // Notifications
          Stack(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.notifications_outlined, color: Color(0xFF1E3A5F)),
              ),
              Positioned(
                top: 8, right: 10,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(AsyncValue<ListingsState> listings, AsyncValue<List<Reservation>> reservations) {
    final listingCount = listings.valueOrNull?.listings.length ?? 0;
    final activeReservations = reservations.valueOrNull?.where((r) => r.status == ReservationStatus.pending || r.status == ReservationStatus.confirmed).length ?? 0;
    final savedAmount = (listings.valueOrNull?.listings ?? []).fold<double>(0, (sum, l) => sum + (l.basePrice - l.currentPrice) * 10);

    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Available', '$listingCount', 'Listings', Icons.inventory_2_outlined, const Color(0xFF4CAF50))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Active', '$activeReservations', 'Claims', Icons.assignment_outlined, const Color(0xFF2196F3))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Potential', '\$${savedAmount.toStringAsFixed(0)}', 'Savings', Icons.savings_outlined, const Color(0xFFFF9800))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String sublabel, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          Text(sublabel, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.search_rounded, 'label': 'Browse', 'color': const Color(0xFF1E3A5F), 'route': '/discover'},
      {'icon': Icons.map_outlined, 'label': 'Map View', 'color': const Color(0xFF4CAF50), 'route': '/map'},
      {'icon': Icons.bookmark_outline, 'label': 'Saved', 'color': const Color(0xFFE91E63), 'route': '/watchlist'},
      {'icon': Icons.history_rounded, 'label': 'History', 'color': const Color(0xFF9C27B0), 'route': '/reservations'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((a) => _buildActionButton(
              a['icon'] as IconData,
              a['label'] as String,
              a['color'] as Color,
              () => context.go(a['route'] as String),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildActiveClaimsSection(AsyncValue<List<Reservation>> reservations) {
    final activeClaims = reservations.valueOrNull?.where((r) => r.status == ReservationStatus.pending || r.status == ReservationStatus.confirmed).toList() ?? [];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Claims', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
              if (activeClaims.isNotEmpty)
                TextButton(
                  onPressed: () => context.go('/reservations'),
                  child: const Text('View All', style: TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (activeClaims.isEmpty)
            _buildEmptyClaimsCard()
          else
            ...activeClaims.take(2).map((r) => _buildClaimCard(r)),
        ],
      ),
    );
  }

  Widget _buildEmptyClaimsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: const Color(0xFF1E3A5F).withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.inbox_outlined, color: Color(0xFF1E3A5F), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('No active claims', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
                const SizedBox(height: 4),
                Text('Browse surplus inventory to make your first claim', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF1E3A5F), borderRadius: BorderRadius.circular(10)),
            child: const Text('Browse', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimCard(Reservation reservation) {
    final statusColor = reservation.status == ReservationStatus.confirmed ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);
    final statusText = reservation.status == ReservationStatus.confirmed ? 'Confirmed' : 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: reservation.listing.primaryPhotoUrl != null
                ? CachedNetworkImage(imageUrl: reservation.listing.primaryPhotoUrl!, width: 60, height: 60, fit: BoxFit.cover)
                : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reservation.listing.displayName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${reservation.quantity.toStringAsFixed(0)} ${reservation.listing.unit} · \$${reservation.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(AsyncValue<ListingsState> listings) {
    final recentListings = listings.valueOrNull?.listings.take(4).toList() ?? [];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('New Arrivals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
              TextButton(
                onPressed: () => context.go('/discover'),
                child: const Text('See All', style: TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentListings.length,
              itemBuilder: (context, index) => _buildRecentListingCard(recentListings[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentListingCard(SurplusListing listing) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.listingDetailPath(listing.id)),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  listing.primaryPhotoUrl != null
                      ? CachedNetworkImage(imageUrl: listing.primaryPhotoUrl!, width: 160, height: 100, fit: BoxFit.cover)
                      : Container(width: 160, height: 100, color: Colors.grey[200]),
                  if (listing.hasDiscount)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFF5252), borderRadius: BorderRadius.circular(6)),
                        child: Text('-${listing.discountPercentage!.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('\$${listing.currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                      Text('/${listing.unit}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
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

  Widget _buildMarketInsights() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2E5077)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF1E3A5F).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.insights_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Market Insights', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    Text('This week\'s trends', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInsightItem('Office', '+24%', Icons.trending_up_rounded),
              const SizedBox(width: 16),
              _buildInsightItem('Retail', '+18%', Icons.trending_up_rounded),
              const SizedBox(width: 16),
              _buildInsightItem('Food', '+12%', Icons.trending_up_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Office furniture surplus increased 24% this week. Great time to stock up!', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String category, String change, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(category, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFF4CAF50), size: 16),
                const SizedBox(width: 4),
                Text(change, style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
