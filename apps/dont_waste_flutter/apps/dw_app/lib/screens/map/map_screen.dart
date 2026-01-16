import 'dart:ui' as ui;
import 'dart:math' as math;
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

  // San Francisco center
  static const _defaultCenter = LatLng(37.7749, -122.4194);
  
  // Mapbox dark style with your token
  static const _mapboxToken = 'pk.eyJ1Ijoic2FydnNvcCIsImEiOiJjbWtnaHkwdGQwOG1tM2ZxbWZuMWQ1Y3ZkIn0.xwHHPjkRV176BR1MElZBcQ';
  static const _mapStyle = 'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}@2x?access_token=$_mapboxToken';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
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

    final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
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
        backgroundColor: const Color(0xFF0D1117),
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
                backgroundColor: const Color(0xFF0D1117),
                onMapReady: () => setState(() => _isMapReady = true),
                onPositionChanged: (pos, _) {
                  if (pos.zoom != null) setState(() => _currentZoom = pos.zoom!);
                },
                onTap: (_, __) => setState(() => _selectedListing = null),
              ),
              children: [
                // Mapbox Dark tiles
                TileLayer(
                  urlTemplate: _mapStyle,
                  userAgentPackageName: 'com.surplushub.app',
                  retinaMode: true,
                  tileProvider: NetworkTileProvider(),
                ),

                // Markers
                listings.when(
                  data: (state) => MarkerLayer(
                    markers: [
                      // User location
                      Marker(
                        point: _defaultCenter,
                        width: 100,
                        height: 100,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) => Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer pulse
                              Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF4A90D9).withOpacity(0.15),
                                  ),
                                ),
                              ),
                              // Inner pulse
                              Transform.scale(
                                scale: 1 + (_pulseAnimation.value - 1) * 0.5,
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF4A90D9).withOpacity(0.25),
                                  ),
                                ),
                              ),
                              // Center dot
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF5BA3F5), Color(0xFF4A90D9)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xFF4A90D9).withOpacity(0.6), blurRadius: 12, spreadRadius: 2),
                                  ],
                                ),
                              ),
                            ],
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

            // Search bar
            _buildSearchBar(),

            // Right controls
            _buildRightControls(),

            // Selected listing card
            if (_selectedListing != null) _buildSelectedListingCard(),

            // Loading
            if (!_isMapReady || listings.isLoading)
              Container(
                color: const Color(0xFF0D1117),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          color: const Color(0xFF4A90D9),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Loading map...', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                    ],
                  ),
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
      width: isSelected ? 90 : 75,
      height: isSelected ? 50 : 42,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedListing = listing);
          _animateToLocation(LatLng(listing.latitude!, listing.longitude!), zoom: 15.5);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: isSelected ? 14 : 10, vertical: isSelected ? 8 : 6),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: [color, color.withOpacity(0.8)])
                      : null,
                  color: isSelected ? null : const Color(0xFF1C2128),
                  borderRadius: BorderRadius.circular(isSelected ? 14 : 10),
                  border: Border.all(
                    color: isSelected ? Colors.white.withOpacity(0.3) : color.withOpacity(0.6),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? color.withOpacity(0.5) : Colors.black.withOpacity(0.4),
                      blurRadius: isSelected ? 16 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(Icons.local_offer_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      '\$${listing.currentPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSelected ? 15 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Triangle
              CustomPaint(
                size: Size(isSelected ? 14 : 10, isSelected ? 8 : 6),
                painter: _TrianglePainter(
                  color: isSelected ? color : const Color(0xFF1C2128),
                  borderColor: isSelected ? Colors.white.withOpacity(0.3) : color.withOpacity(0.6),
                ),
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
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2128).withOpacity(0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF4A90D9).withOpacity(0.2), const Color(0xFF4A90D9).withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.search_rounded, color: Color(0xFF4A90D9), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Search surplus inventory', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('San Francisco Bay Area', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white60, size: 18),
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
      bottom: _selectedListing != null ? 240 : 100,
      child: Column(
        children: [
          _buildControlButton(Icons.layers_rounded, () {}, isAccent: true),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2128).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    _buildZoomButton(Icons.add_rounded, _zoomIn),
                    Container(height: 1, width: 34, color: Colors.white.withOpacity(0.08)),
                    _buildZoomButton(Icons.remove_rounded, _zoomOut),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildControlButton(Icons.navigation_rounded, _centerOnUser),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap, {bool isAccent = false}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: isAccent ? const LinearGradient(colors: [Color(0xFF4A90D9), Color(0xFF3A7BC8)]) : null,
              color: isAccent ? null : const Color(0xFF1C2128).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: isAccent ? [BoxShadow(color: const Color(0xFF4A90D9).withOpacity(0.4), blurRadius: 16)] : null,
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
      child: Container(width: 52, height: 48, color: Colors.transparent, child: Icon(icon, color: Colors.white, size: 22)),
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
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2128).withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 10))],
              ),
              child: Row(
                children: [
                  // Image
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: listing.primaryPhotoUrl != null
                            ? CachedNetworkImage(imageUrl: listing.primaryPhotoUrl!, width: 90, height: 90, fit: BoxFit.cover)
                            : Container(width: 90, height: 90, color: const Color(0xFF2D333B), child: const Icon(Icons.image, color: Colors.white24)),
                      ),
                      Positioned(
                        bottom: 6, left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                          child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(listing.displayName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.business_rounded, size: 13, color: Colors.white.withOpacity(0.4)),
                            const SizedBox(width: 4),
                            Expanded(child: Text(listing.enterprise.name, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text('\$${listing.currentPrice.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF4A90D9), fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('/${listing.unit}', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, color: Colors.white54, size: 13),
                                  const SizedBox(width: 4),
                                  Text('${listing.quantityAvailable.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Arrow
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4A90D9), Color(0xFF3A7BC8)]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: const Color(0xFF4A90D9).withOpacity(0.4), blurRadius: 12)],
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
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
    if (name.contains('tile') || name.contains('paint') || name.contains('wood')) return 'Build';
    if (name.contains('clothing') || name.contains('electronic') || name.contains('accessor')) return 'Retail';
    if (name.contains('linen') || name.contains('tableware') || name.contains('hotel')) return 'Hotel';
    if (name.contains('pallet') || name.contains('box') || name.contains('packaging')) return 'Pack';
    return 'Food';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Office': return const Color(0xFF4A90D9);
      case 'Build': return const Color(0xFFFF9800);
      case 'Retail': return const Color(0xFFE91E63);
      case 'Hotel': return const Color(0xFF9C27B0);
      case 'Pack': return const Color(0xFF795548);
      default: return const Color(0xFF4CAF50);
    }
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  _TrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
