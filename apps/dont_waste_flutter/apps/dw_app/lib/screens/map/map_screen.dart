import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:dw_domain/dw_domain.dart';
import 'package:dw_ui/dw_ui.dart';

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

  // San Francisco center
  static const _defaultCenter = Point(coordinates: Position(-122.4194, 37.7749));
  
  // Mapbox public access token
  static const _mapboxToken = 'pk.eyJ1Ijoic2FydnNvcCIsImEiOiJjbWtnaHkwdGQwOG1tM2ZxbWZuMWQ1Y3ZkIn0.xwHHPjkRV176BR1MElZBcQ';

  // Camera settings for cinematic 3D view
  static const _defaultZoom = 16.0;
  static const _defaultPitch = 60.0;
  static const _defaultBearing = 20.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    
    // Set the access token
    await MapboxOptions.setAccessToken(_mapboxToken);
    
    // Enable 3D terrain and buildings
    await _setup3DBuildings();
    
    // Create annotation manager for markers
    _annotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    
    setState(() => _isMapReady = true);
    
    // Add listing markers
    _addListingMarkers();
  }

  Future<void> _setup3DBuildings() async {
    if (_mapboxMap == null) return;

    // The dark-v11 style already includes 3D buildings
    // We just need to ensure the building layer is visible and properly configured
    
    try {
      // Get the style and configure 3D buildings
      final style = _mapboxMap!.style;
      
      // Check if building-extrusion layer exists and configure it
      // The Mapbox dark style includes this by default
      
      // Enable atmosphere for more cinematic look
      await style.setStyleAtmosphere(Atmosphere(
        color: const Color(0xFF0D1117).value,
        highColor: const Color(0xFF1a1f29).value,
        horizonBlend: 0.1,
        spaceColor: const Color(0xFF0D1117).value,
        starIntensity: 0.0,
      ));
      
    } catch (e) {
      debugPrint('Error setting up 3D buildings: $e');
    }
  }

  void _addListingMarkers() async {
    if (_annotationManager == null) return;
    
    final listingsState = ref.read(listingsProvider);
    listingsState.whenData((state) async {
      // Clear existing annotations
      await _annotationManager!.deleteAll();
      
      // Add markers for each listing
      for (final listing in state.listings) {
        if (listing.latitude != null && listing.longitude != null) {
          final options = PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(listing.longitude!, listing.latitude!),
            ),
            iconSize: 1.0,
            textField: '\$${listing.currentPrice.toStringAsFixed(0)}',
            textSize: 12.0,
            textColor: Colors.white.value,
            textHaloColor: const Color(0xFF0D1117).value,
            textHaloWidth: 1.5,
            textOffset: [0, -2.5],
          );
          
          await _annotationManager!.create(options);
        }
      }
    });
  }

  void _animateToLocation(Point target, {double? zoom, double? pitch, double? bearing}) async {
    if (_mapboxMap == null) return;
    
    await _mapboxMap!.flyTo(
      CameraOptions(
        center: target,
        zoom: zoom ?? _defaultZoom,
        pitch: pitch ?? _defaultPitch,
        bearing: bearing ?? _defaultBearing,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  void _zoomIn() async {
    if (_mapboxMap == null) return;
    final camera = await _mapboxMap!.getCameraState();
    _mapboxMap!.flyTo(
      CameraOptions(zoom: (camera.zoom + 1).clamp(5.0, 20.0)),
      MapAnimationOptions(duration: 300),
    );
  }

  void _zoomOut() async {
    if (_mapboxMap == null) return;
    final camera = await _mapboxMap!.getCameraState();
    _mapboxMap!.flyTo(
      CameraOptions(zoom: (camera.zoom - 1).clamp(5.0, 20.0)),
      MapAnimationOptions(duration: 300),
    );
  }

  void _centerOnUser() {
    _animateToLocation(
      _defaultCenter,
      zoom: _defaultZoom,
      pitch: _defaultPitch,
      bearing: _defaultBearing,
    );
  }

  void _resetNorth() async {
    if (_mapboxMap == null) return;
    final camera = await _mapboxMap!.getCameraState();
    _mapboxMap!.flyTo(
      CameraOptions(
        bearing: 0,
        pitch: camera.pitch,
      ),
      MapAnimationOptions(duration: 500),
    );
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
            // Mapbox Map
            MapWidget(
              key: const ValueKey('mapWidget'),
              cameraOptions: CameraOptions(
                center: _defaultCenter,
                zoom: _defaultZoom,
                pitch: _defaultPitch,
                bearing: _defaultBearing,
              ),
              styleUri: MapboxStyles.DARK,
              onMapCreated: _onMapCreated,
              onTapListener: (context) {
                setState(() => _selectedListing = null);
              },
            ),

            // Top search bar overlay
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: _buildSearchBar(),
            ),

            // Right side controls
            Positioned(
              right: 16,
              top: MediaQuery.of(context).padding.top + 80,
              child: _buildRightControls(),
            ),

            // Bottom left - compass/north button
            Positioned(
              left: 16,
              bottom: _selectedListing != null ? 220 : 100,
              child: _buildCompassButton(),
            ),

            // Bottom right - location button
            Positioned(
              right: 16,
              bottom: _selectedListing != null ? 220 : 100,
              child: _buildLocationButton(),
            ),

            // Selected listing card
            if (_selectedListing != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: _buildSelectedListingCard(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DwDarkTheme.spacingMd,
            vertical: DwDarkTheme.spacingSm + 4,
          ),
          decoration: BoxDecoration(
            color: DwDarkTheme.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(
              color: DwDarkTheme.cardBorder.withOpacity(0.5),
              width: 1,
            ),
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
              const Icon(
                Icons.search,
                color: DwDarkTheme.textTertiary,
                size: 22,
              ),
              const SizedBox(width: DwDarkTheme.spacingSm),
              Expanded(
                child: Text(
                  'Search surplus inventory...',
                  style: DwDarkTheme.bodyMedium.copyWith(
                    color: DwDarkTheme.textMuted,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: DwDarkTheme.cardBorder,
              ),
              const SizedBox(width: DwDarkTheme.spacingSm),
              GestureDetector(
                onTap: () => context.push(AppRoutes.filters),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: DwDarkTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: DwDarkTheme.accent,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightControls() {
    return Column(
      children: [
        // Zoom in
        _buildControlButton(
          icon: Icons.add,
          onTap: _zoomIn,
        ),
        const SizedBox(height: 2),
        // Zoom out
        _buildControlButton(
          icon: Icons.remove,
          onTap: _zoomOut,
        ),
        const SizedBox(height: DwDarkTheme.spacingMd),
        // 3D/2D toggle
        _buildControlButton(
          icon: Icons.view_in_ar,
          onTap: () async {
            if (_mapboxMap == null) return;
            final camera = await _mapboxMap!.getCameraState();
            final newPitch = camera.pitch > 30 ? 0.0 : 60.0;
            _mapboxMap!.flyTo(
              CameraOptions(pitch: newPitch),
              MapAnimationOptions(duration: 500),
            );
          },
          isAccent: true,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isAccent = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isAccent
              ? DwDarkTheme.accent.withOpacity(0.2)
              : DwDarkTheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
          border: Border.all(
            color: isAccent
                ? DwDarkTheme.accent.withOpacity(0.4)
                : DwDarkTheme.cardBorder.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isAccent ? DwDarkTheme.accent : DwDarkTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCompassButton() {
    return GestureDetector(
      onTap: _resetNorth,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: DwDarkTheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
          border: Border.all(
            color: DwDarkTheme.cardBorder.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.explore_outlined,
          color: DwDarkTheme.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return GestureDetector(
      onTap: _centerOnUser,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: DwDarkTheme.primaryGradient,
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: DwDarkTheme.accent.withOpacity(0.4),
                  blurRadius: 16 * _pulseAnimation.value,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 24,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedListingCard() {
    final listing = _selectedListing!;
    final imageUrl = listing.imageUrls?.isNotEmpty == true
        ? listing.imageUrls!.first
        : listing.photoUrls?.isNotEmpty == true
            ? listing.photoUrls!.first
            : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
          decoration: BoxDecoration(
            color: DwDarkTheme.surface.withOpacity(0.92),
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
            border: Border.all(
              color: DwDarkTheme.cardBorder.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    width: 80,
                    height: 80,
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
                              placeholder: (_, __) => _buildImagePlaceholder(),
                              errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  const SizedBox(width: DwDarkTheme.spacingMd),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.safeTitle,
                          style: DwDarkTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listing.enterprise?.name ?? 'Unknown seller',
                          style: DwDarkTheme.bodySmall.copyWith(
                            color: DwDarkTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(height: DwDarkTheme.spacingSm),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: DwDarkTheme.accentGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '\$${listing.currentPrice.toStringAsFixed(2)}',
                                style: DwDarkTheme.labelMedium.copyWith(
                                  color: DwDarkTheme.accentGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (listing.distanceKm != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
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

                  // Close button
                  GestureDetector(
                    onTap: () => setState(() => _selectedListing = null),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: DwDarkTheme.surfaceHighlight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: DwDarkTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DwDarkTheme.spacingMd),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.listingDetailPath(listing.id)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: DwDarkTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                        ),
                        child: Center(
                          child: Text(
                            'View Details',
                            style: DwDarkTheme.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DwDarkTheme.spacingSm),
                  GestureDetector(
                    onTap: () {
                      // Open directions
                    },
                    child: Container(
                      width: 48,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DwDarkTheme.surfaceHighlight,
                        borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                        border: Border.all(
                          color: DwDarkTheme.cardBorder,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.directions,
                        color: DwDarkTheme.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: DwDarkTheme.surfaceHighlight,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: DwDarkTheme.textMuted,
          size: 28,
        ),
      ),
    );
  }
}
