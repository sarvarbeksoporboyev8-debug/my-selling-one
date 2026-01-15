import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_domain/dw_domain.dart';

/// Selected location provider
/// For now using a default location - geolocator will be added later
final selectedLocationProvider = StateProvider<UserLocation?>((ref) {
  // Default to London for demo purposes
  return UserLocation(
    latitude: 51.5074,
    longitude: -0.1278,
    displayName: 'London, UK',
    city: 'London',
    country: 'United Kingdom',
    timestamp: DateTime.now(),
  );
});

/// Selected radius provider (in km)
final selectedRadiusProvider = StateProvider<double>((ref) => 50.0);

/// Location notifier for manual location updates
class LocationNotifier extends StateNotifier<UserLocation?> {
  LocationNotifier(super.state);

  void setLocation(double lat, double lng, {String? displayName, String? city, String? country}) {
    state = UserLocation(
      latitude: lat,
      longitude: lng,
      displayName: displayName,
      city: city,
      country: country,
      timestamp: DateTime.now(),
    );
  }

  void clearLocation() {
    state = null;
  }
}
