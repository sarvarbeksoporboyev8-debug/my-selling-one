import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _annotationManager;
  SurplusListing? _selectedListing;
  bool _isMapReady = false;
  double _currentZoom = 15.0;
  
  // Mapbox access token
  static const String _accessToken = 'pk.eyJ1Ijoic2FydnNvcCIsImEiOiJjbWtnaHkwdGQwOG1tM2ZxbWZuMWQ1Y3ZkIn0.xwHHPjkRV176BR1MElZBcQ';
  
  // San Francisco center
  static const double _defaultLat = 37.7749;
  static const double _defaultLng = -122.4194;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    
    // Set up 3D terrain and buildings
    await _setup3DBuildings();
    
    // Create annotation manager for markers
    _annotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    
    // Add listing markers
    _addListingMarkers();
    
    setState(() => _isMapReady = true);
  }

  Future<void> _setup3DBuildings() async {
    if (_mapboxMap == null) return;

    // Add 3D building extrusion layer
    await _mapboxMap!.style.addLayer(FillExtrusionLayer(
      id: '3d-buildings',
      sourceId: 'composite',
      sourceLayer: 'building',
      minZoom: 14,
      fillExtrusionColor: 0xFF2D2D44,
      fillExtrusionHeight: [
        Exp.interpolate,
        [Exp.linear],
        [Exp.zoom],
        14, 0,
        14.5, [Exp.get, 'height'],
      ],
      fillExtrusionBase: [Exp.get, 'min_height'],
      fillExtrusionOpacity: 0.8,
    ));
  }

  void _addListingMarkers() async {
    if (_annotationManager == null) return;
    
    final listings = ref.read(listingsProvider).valueOrNull?.listings ?? [];
    
    for (final listing in listings) {
      if (listing.latitude == null || listing.longitude == null) continue;
      
      await _annotationManager!.create(PointAnnotationOptions(
        geometry: Point(coordinates: Position(listing.longitude!, listing.latitude!)),
        iconSize: 1.2,
        textField: '\$${listing.currentPrice.toStringAsFixed(0)}',
        textSize: 12,
        textColor: 0xFFFFFFFF,
        textHaloColor: 0xFF1E3A5F,
        textHaloWidth: 2,
        textOffset: [0, -2.5],
      ));
    }
  }

  void _flyToLocation(double lat, double lng, {double? zoom, double? pitch, double? bearing}) {
    _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: zoom ?? _currentZoom,
        pitch: pitch ?? 60,
        bearing: bearing ?? 30,
      ),
      MapAnimationOptions(duration: 1500),
    );
  }

  void _zoomIn() {
    final newZoom = math.min(_currentZoom + 1, 20.0);
    setState(() => _currentZoom = newZoom);
    _mapboxMap?.flyTo(
      CameraOptions(zoom: newZoom),
      MapAnimationOptions(duration: 300),
    );
  }

  void _zoomOut() {
    final newZoom = math.max(_currentZoom - 1, 10.0);
    setState(() => _currentZoom = newZoom);
    _mapboxMap?.flyTo(
      CameraOptions(zoom: newZoom),
      MapAnimationOptions(duration: 300),
    );
  }

  void _centerOnUser() {
    _flyToLocation(_defaultLat, _defaultLng, zoom: 15, pitch: 60, bearing: 30);
  }

  void _onMapTap(MapContentGestureContext context) {
    setState(() => _selectedListing = null);
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
            // Mapbox Map
            MapWidget(
              key: const ValueKey('mapbox'),
              resourceOptions: ResourceOptions(accessToken: _accessToken),
              styleUri: MapboxStyles.DARK,
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(_defaultLng, _defaultLat)),
                zoom: _currentZoom,
                pitch: 60,
                bearing: 30,
              ),
              onMapCreated: _onMapCreated,
              onTapListener: _onMapTap,
            ),

            // Custom markers overlay (for better control)
            if (_isMapReady)
              listings.when(
                data: (state) => _buildMarkersOverlay(state.listings),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

            // Top search bar
            _buildSearchBar(),

            // Right side controls
            _buildRightControls(),

            // Bottom listing card
            if (_selectedListing != null) _buildSelectedListingCard(),

            // Loading overlay
            if (!_isMapReady)
              Container(
                color: const Color(0xFF1A1A2E),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF4A90D9)),
                      const SizedBox(height: 16),
                      Text('Loading map...', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkersOverlay(List<SurplusListing> listings) {
    // This creates floating markers that we can fully customize
    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: listings
            .where((l) => l.latitude != null && l.longitude != null)
            .map((listing) => _buildFloatingMarker(listing))
            .toList(),
      ),
    );
  }

  Widget _buildFloatingMarker(SurplusListing listing) {
    final isSelected = _selectedListing?.id == listing.id;
    final category = _getCategoryFromListing(listing);
    final color = _getCategoryColor(category);

    return Positioned(
      // Position will be calculated based on map projection
      // For now, using a simplified approach
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: const SizedBox.shrink(), // Markers handled by annotation manager
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
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D44).withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search_rounded, color: Color(0xFF4A90D9), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Search surplus inventory',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'San Francisco Bay Area',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white70, size: 18),
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
      bottom: _selectedListing != null ? 230 : 100,
      child: Column(
        children: [
          // 3D/2D toggle
          _buildControlButton(
            icon: Icons.view_in_ar_rounded,
            onTap: () {
              _mapboxMap?.flyTo(
                CameraOptions(pitch: 60, bearing: 30),
                MapAnimationOptions(duration: 500),
              );
            },
            isAccent: true,
          ),
          const SizedBox(height: 12),
          // Zoom controls
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D44).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12),
                  ],
                ),
                child: Column(
                  children: [
                    _buildZoomButton(Icons.add_rounded, _zoomIn),
                    Container(height: 1, width: 32, color: Colors.white.withOpacity(0.1)),
                    _buildZoomButton(Icons.remove_rounded, _zoomOut),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Compass / Location button
          _buildControlButton(
            icon: Icons.navigation_rounded,
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
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: isAccent
                  ? const LinearGradient(
                      colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isAccent ? null : const Color(0xFF2D2D44).withOpacity(0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: isAccent ? const Color(0xFF4A90D9).withOpacity(0.4) : Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
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
        width: 50,
        height: 46,
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
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D44).withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Image with gradient overlay
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: listing.primaryPhotoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: listing.primaryPhotoUrl!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 90,
                                height: 90,
                                color: const Color(0xFF3D3D54),
                                child: const Icon(Icons.image, color: Colors.white38),
                              ),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                          ),
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
                        Text(
                          listing.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.business_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                listing.enterprise.name,
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '\$${listing.currentPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF4A90D9),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '/${listing.unit}',
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, color: Colors.white60, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${listing.quantityAvailable.toStringAsFixed(0)} avail',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Arrow button
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90D9).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
