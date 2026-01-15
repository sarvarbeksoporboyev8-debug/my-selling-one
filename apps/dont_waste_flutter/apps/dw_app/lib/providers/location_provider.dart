import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dw_domain/dw_domain.dart';

/// Location permission state provider
final locationPermissionProvider = StateNotifierProvider<LocationPermissionNotifier, LocationPermissionState>((ref) {
  return LocationPermissionNotifier();
});

class LocationPermissionNotifier extends StateNotifier<LocationPermissionState> {
  LocationPermissionNotifier() : super(const LocationPermissionState.unknown()) {
    checkPermission();
  }

  Future<void> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = const LocationPermissionState.disabled();
      return;
    }

    final permission = await Geolocator.checkPermission();
    state = _mapPermission(permission);
  }

  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    state = _mapPermission(permission);
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  LocationPermissionState _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return const LocationPermissionState.granted();
      case LocationPermission.denied:
        return const LocationPermissionState.denied();
      case LocationPermission.deniedForever:
        return const LocationPermissionState.deniedForever();
      case LocationPermission.unableToDetermine:
        return const LocationPermissionState.unknown();
    }
  }
}

/// Current location provider
final currentLocationProvider = StateNotifierProvider<CurrentLocationNotifier, AsyncValue<UserLocation?>>((ref) {
  final permissionState = ref.watch(locationPermissionProvider);
  return CurrentLocationNotifier(permissionState);
});

class CurrentLocationNotifier extends StateNotifier<AsyncValue<UserLocation?>> {
  final LocationPermissionState _permissionState;

  CurrentLocationNotifier(this._permissionState) : super(const AsyncValue.data(null)) {
    _permissionState.when(
      unknown: () {},
      granted: () => getCurrentLocation(),
      denied: () {},
      deniedForever: () {},
      disabled: () {},
    );
  }

  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      String? displayName;
      String? city;
      String? country;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          city = place.locality;
          country = place.country;
          displayName = [place.locality, place.administrativeArea]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
        }
      } catch (_) {
        // Geocoding failed, continue without display name
      }

      state = AsyncValue.data(UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        displayName: displayName,
        city: city,
        country: country,
        timestamp: DateTime.now(),
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setManualLocation(double lat, double lng, {String? displayName}) {
    state = AsyncValue.data(UserLocation(
      latitude: lat,
      longitude: lng,
      displayName: displayName,
      timestamp: DateTime.now(),
    ));
  }
}

/// Selected location provider (can be different from current)
final selectedLocationProvider = StateProvider<UserLocation?>((ref) {
  return ref.watch(currentLocationProvider).valueOrNull;
});

/// Selected radius provider
final selectedRadiusProvider = StateProvider<double>((ref) => 50.0);
