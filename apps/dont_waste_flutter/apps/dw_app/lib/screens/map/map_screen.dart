import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  SurplusListing? _selectedListing;
  bool _isMapReady = false;
  double _currentZoom = 14.0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // San Francisco center (where demo data is located)
  static const _defaultCenter = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _animateToLocation(LatLng target, {double? zoom}) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: target.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: target.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom ?? camera.zoom);

    final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.forward().then((_) => controller.dispose());
  }

  void _zoomIn() {
    final newZoom = (_currentZoom + 1).clamp(5.0, 18.0);
    _animateToLocation(_mapController.camera.center, zoom: newZoom);
    setState(() => _currentZoom = newZoom);
  }

  void _zoomOut() {
    final newZoom = (_currentZoom - 1).clamp(5.0, 18.0);
    _animateToLocation(_mapController.camera.center, zoom: newZoom);
    setState(() => _currentZoom = newZoom);
  }

  void _centerOnUser() {
    _animateToLocation(_defaultCenter, zoom: 14.0);
    setState(() => _currentZoom = 14.0);
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(listingsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: _currentZoom,
                minZoom: 5.0,
                maxZoom: 18.0,
                backgroundColor: const Color(0xFF1A1A2E),
                onMapReady: () => setState(() => _isMapReady = true),
                onPositionChanged: (pos, _) {
                  if (pos.zoom != null) setState(() => _currentZoom = pos.zoom!);
                },
                onTap: (_, __) => setState(() => _selectedListing = null),
              ),
              children: [
                // Dark tile layer (CartoDB Dark Matter)
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.surplushub.app',
                  retinaMode: true,
                ),

                // Listing markers
                listings.when(
                  data: (state) => MarkerLayer(
                    markers: [
                      // User location marker
                      Marker(
                        point: _defaultCenter,
                        width: 80,
                        height: 80,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) => Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF4A90D9).withOpacity(0.15),
                              ),
                              child: Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF4A90D9),
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [BoxShadow(color: const Color(0xFF4A90D9).withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Listing markers
                      ...state.listings
                          .where((l) => l.latitude != null && l.longitude != null)
                          .map((listing) => _buildListingMarker(listing)),
                    ],
                  ),
                  loading: () => const MarkerLayer(markers: []),
                  error: (_, __) => const MarkerLayer(markers: []),
                ),
              ],
            ),

            // Top search bar
            _buildSearchBar(),

            // Right side controls
            _buildRightControls(),

            // Bottom listing card
            if (_selectedListing != null) _buildSelectedListingCard(),

            // Loading overlay
            if (!_isMapReady || listings.isLoading)
              Container(
                color: const Color(0xFF1A1A2E),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4A90D9)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Marker _buildListingMarker(SurplusListing listing) {
    final isSelected = _selectedListing?.id == listing.id;
    final category = _getCategoryFromListing(listing);
    final color = _getCategoryColor(category);

    return Marker(
      point: LatLng(listing.latitude!, listing.longitude!),
      width: isSelected ? 70 : 56,
      height: isSelected ? 80 : 66,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedListing = listing);
          _animateToLocation(LatLng(listing.latitude!, listing.longitude!), zoom: 15.0);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color : const Color(0xFF2D2D44),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? Colors.white : color, width: isSelected ? 2 : 1),
                  boxShadow: [
                    BoxShadow(color: (isSelected ? color : Colors.black).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Text(
                  '\$${listing.currentPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSelected ? 14 : 12,
                  ),
                ),
              ),
              // Triangle pointer
              CustomPaint(
                size: const Size(12, 8),
                painter: _TrianglePainter(color: isSelected ? color : const Color(0xFF2D2D44)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D44).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.white54, size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Search surplus near you...', style: TextStyle(color: Colors.white54, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Color(0xFF4A90D9), size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightControls() {
    return Positioned(
      right: 16,
      bottom: _selectedListing != null ? 220 : 100,
      child: Column(
        children: [
          // Navigation mode button
          _buildControlButton(
            icon: Icons.navigation_rounded,
            onTap: () {},
            isAccent: true,
          ),
          const SizedBox(height: 12),
          // Zoom controls
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D44).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildZoomButton(Icons.add_rounded, _zoomIn),
                    Container(height: 1, width: 30, color: Colors.white.withOpacity(0.1)),
                    _buildZoomButton(Icons.remove_rounded, _zoomOut),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Location button
          _buildControlButton(
            icon: Icons.my_location_rounded,
            onTap: _centerOnUser,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap, bool isAccent = false}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isAccent ? const Color(0xFF4A90D9) : const Color(0xFF2D2D44).withOpacity(0.9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: isAccent ? [BoxShadow(color: const Color(0xFF4A90D9).withOpacity(0.4), blurRadius: 12)] : null,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 44,
        color: Colors.transparent,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildSelectedListingCard() {
    final listing = _selectedListing!;
    final category = _getCategoryFromListing(listing);
    final color = _getCategoryColor(category);

    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.listingDetailPath(listing.id)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D44).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: listing.primaryPhotoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: listing.primaryPhotoUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(width: 80, height: 80, color: const Color(0xFF3D3D54)),
                            errorWidget: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: const Color(0xFF3D3D54),
                              child: const Icon(Icons.image, color: Colors.white38),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFF3D3D54),
                            child: const Icon(Icons.image, color: Colors.white38),
                          ),
                  ),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                          child: Text(category, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 6),
                        // Title
                        Text(
                          listing.displayName,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Supplier
                        Text(
                          listing.enterprise.name,
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Price and quantity
                        Row(
                          children: [
                            Text(
                              '\$${listing.currentPrice.toStringAsFixed(2)}',
                              style: const TextStyle(color: Color(0xFF4A90D9), fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text('/${listing.unit}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, color: Colors.white54, size: 14),
                                  const SizedBox(width: 4),
                                  Text('${listing.quantityAvailable.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Arrow
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFF4A90D9), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
      case 'Office': return const Color(0xFF4A90D9);
      case 'Construction': return const Color(0xFFFF9800);
      case 'Retail': return const Color(0xFFE91E63);
      case 'Hospitality': return const Color(0xFF9C27B0);
      case 'Packaging': return const Color(0xFF795548);
      default: return const Color(0xFF4CAF50);
    }
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
