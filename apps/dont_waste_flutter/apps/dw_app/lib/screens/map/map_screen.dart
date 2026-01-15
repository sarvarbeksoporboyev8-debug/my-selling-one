import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

/// Map screen with flutter_map and marker clustering
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();
  SurplusListing? _selectedListing;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnUserLocation() {
    final location = ref.read(selectedLocationProvider);
    if (location != null) {
      _mapController.move(
        LatLng(location.latitude, location.longitude),
        14.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(listingsProvider);
    final userLocation = ref.watch(selectedLocationProvider);

    // Default center (will be overridden by user location)
    final defaultCenter = userLocation != null
        ? LatLng(userLocation.latitude, userLocation.longitude)
        : const LatLng(51.5074, -0.1278); // London as fallback

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: defaultCenter,
              initialZoom: 13.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              onTap: (_, __) {
                _popupController.hideAllPopups();
                setState(() => _selectedListing = null);
              },
            ),
            children: [
              // Tile layer (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.dontwaste.app',
              ),

              // User location marker
              if (userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(userLocation.latitude, userLocation.longitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: DwColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: DwColors.primary, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: DwColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              // Listing markers with clustering
              listings.when(
                data: (state) => MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 80,
                    size: const Size(40, 40),
                    markers: state.listings
                        .where((l) => l.latitude != null && l.longitude != null)
                        .map((listing) => _buildListingMarker(listing))
                        .toList(),
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          color: DwColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${markers.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                    popupOptions: PopupOptions(
                      popupController: _popupController,
                      popupBuilder: (context, marker) {
                        // Find the listing for this marker
                        final listing = state.listings.firstWhere(
                          (l) =>
                              l.latitude == marker.point.latitude &&
                              l.longitude == marker.point.longitude,
                        );
                        return _ListingPopup(
                          listing: listing,
                          onTap: () => context.push(
                            AppRoutes.listingDetailPath(listing.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),

          // Top controls
          Positioned(
            top: MediaQuery.of(context).padding.top + DwSpacing.sm,
            left: DwSpacing.md,
            right: DwSpacing.md,
            child: Row(
              children: [
                // Back button
                _MapButton(
                  icon: Icons.arrow_back,
                  onPressed: () => context.pop(),
                ),
                const Spacer(),
                // Filter button
                _MapButton(
                  icon: Icons.tune,
                  onPressed: () => context.push(AppRoutes.filters),
                ),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: DwSpacing.xl,
            right: DwSpacing.md,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.my_location,
                  onPressed: _centerOnUserLocation,
                ),
                const SizedBox(height: DwSpacing.sm),
                _MapButton(
                  icon: Icons.add,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
                const SizedBox(height: DwSpacing.xs),
                _MapButton(
                  icon: Icons.remove,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
              ],
            ),
          ),

          // Selected listing card
          if (_selectedListing != null)
            Positioned(
              bottom: DwSpacing.xl,
              left: DwSpacing.md,
              right: 80,
              child: _SelectedListingCard(
                listing: _selectedListing!,
                onTap: () => context.push(
                  AppRoutes.listingDetailPath(_selectedListing!.id),
                ),
                onClose: () => setState(() => _selectedListing = null),
              ),
            ),

          // Loading indicator
          if (listings.isLoading)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Marker _buildListingMarker(SurplusListing listing) {
    final isSelected = _selectedListing?.id == listing.id;

    return Marker(
      point: LatLng(listing.latitude!, listing.longitude!),
      width: isSelected ? 50 : 40,
      height: isSelected ? 50 : 40,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedListing = listing);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? DwColors.secondary : DwColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: isSelected
                ? Border.all(color: Colors.white, width: 3)
                : null,
          ),
          child: Center(
            child: Text(
              '\$${listing.price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DwRadius.sm),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DwRadius.sm),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: DwColors.textPrimary),
        ),
      ),
    );
  }
}

class _ListingPopup extends StatelessWidget {
  final SurplusListing listing;
  final VoidCallback onTap;

  const _ListingPopup({
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(DwSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DwRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.safeTitle,
              style: DwTextStyles.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: DwSpacing.xs),
            Text(
              listing.seller?.name ?? 'Unknown',
              style: DwTextStyles.bodySmall,
            ),
            const SizedBox(height: DwSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${listing.price.toStringAsFixed(2)}',
                  style: DwTextStyles.titleSmall.copyWith(
                    color: DwColors.primary,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: DwColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedListingCard extends StatelessWidget {
  final SurplusListing listing;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _SelectedListingCard({
    required this.listing,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DwRadius.md),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DwRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(DwSpacing.md),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(DwRadius.sm),
                child: Container(
                  width: 60,
                  height: 60,
                  color: DwColors.surface,
                  child: listing.imageUrls.isNotEmpty
                      ? Image.network(
                          listing.imageUrls.first,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, color: DwColors.textSecondary),
                ),
              ),
              const SizedBox(width: DwSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      listing.safeTitle,
                      style: DwTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DwSpacing.xs),
                    Text(
                      listing.seller?.name ?? 'Unknown',
                      style: DwTextStyles.bodySmall,
                    ),
                    const SizedBox(height: DwSpacing.xs),
                    Text(
                      '\$${listing.price.toStringAsFixed(2)} / ${listing.unit}',
                      style: DwTextStyles.titleSmall.copyWith(
                        color: DwColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Close button
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
