import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

/// Utility for launching external map applications.
class MapUtils {
  MapUtils._();

  /// Opens a location in the user's preferred map app.
  /// Shows a bottom sheet to select from available map apps.
  static Future<void> openLocation({
    required BuildContext context,
    required double latitude,
    required double longitude,
    required String title,
    String? description,
  }) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No map apps installed')),
        );
      }
      return;
    }

    // If only one map app, open directly
    if (availableMaps.length == 1) {
      await availableMaps.first.showMarker(
        coords: Coords(latitude, longitude),
        title: title,
        description: description,
      );
      return;
    }

    // Show bottom sheet to select map app
    if (context.mounted) {
      await showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Open with',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...availableMaps.map(
                (map) => ListTile(
                  leading: SizedBox(
                    width: 32,
                    height: 32,
                    child: Image.asset(
                      map.icon,
                      package: 'map_launcher',
                    ),
                  ),
                  title: Text(map.mapName),
                  onTap: () {
                    Navigator.pop(context);
                    map.showMarker(
                      coords: Coords(latitude, longitude),
                      title: title,
                      description: description,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }
  }

  /// Opens directions to a location in the user's preferred map app.
  static Future<void> openDirections({
    required BuildContext context,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationTitle,
    double? originLatitude,
    double? originLongitude,
    DirectionsMode mode = DirectionsMode.driving,
  }) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No map apps installed')),
        );
      }
      return;
    }

    // If only one map app, open directly
    if (availableMaps.length == 1) {
      await availableMaps.first.showDirections(
        destination: Coords(destinationLatitude, destinationLongitude),
        destinationTitle: destinationTitle,
        origin: originLatitude != null && originLongitude != null
            ? Coords(originLatitude, originLongitude)
            : null,
        directionsMode: mode,
      );
      return;
    }

    // Show bottom sheet to select map app
    if (context.mounted) {
      await showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Get directions with',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...availableMaps.map(
                (map) => ListTile(
                  leading: SizedBox(
                    width: 32,
                    height: 32,
                    child: Image.asset(
                      map.icon,
                      package: 'map_launcher',
                    ),
                  ),
                  title: Text(map.mapName),
                  onTap: () {
                    Navigator.pop(context);
                    map.showDirections(
                      destination: Coords(destinationLatitude, destinationLongitude),
                      destinationTitle: destinationTitle,
                      origin: originLatitude != null && originLongitude != null
                          ? Coords(originLatitude, originLongitude)
                          : null,
                      directionsMode: mode,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }
  }
}
