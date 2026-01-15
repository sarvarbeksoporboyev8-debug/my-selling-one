import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';

@freezed
class UserLocation with _$UserLocation {
  const UserLocation._();

  const factory UserLocation({
    required double latitude,
    required double longitude,
    String? displayName,
    String? city,
    String? country,
    DateTime? timestamp,
  }) = _UserLocation;

  /// Get short display name
  String get shortDisplay => displayName ?? city ?? 'Current Location';

  /// Calculate distance to another location in km
  double distanceTo(double lat, double lng) {
    const earthRadius = 6371.0; // km

    final dLat = _toRadians(lat - latitude);
    final dLng = _toRadians(lng - longitude);

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(latitude)) *
            _cos(_toRadians(lat)) *
            _sin(dLng / 2) *
            _sin(dLng / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * 3.14159265359 / 180;
  double _sin(double x) => _sinApprox(x);
  double _cos(double x) => _sinApprox(x + 1.5707963268);
  double _sqrt(double x) => x > 0 ? _sqrtApprox(x) : 0;
  double _atan2(double y, double x) => _atan2Approx(y, x);

  // Simple approximations for math functions
  double _sinApprox(double x) {
    x = x % (2 * 3.14159265359);
    if (x < 0) x += 2 * 3.14159265359;
    if (x > 3.14159265359) {
      x -= 3.14159265359;
      return -_sinApproxPositive(x);
    }
    return _sinApproxPositive(x);
  }

  double _sinApproxPositive(double x) {
    if (x > 1.5707963268) x = 3.14159265359 - x;
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  double _sqrtApprox(double x) {
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _atan2Approx(double y, double x) {
    if (x > 0) return _atanApprox(y / x);
    if (x < 0 && y >= 0) return _atanApprox(y / x) + 3.14159265359;
    if (x < 0 && y < 0) return _atanApprox(y / x) - 3.14159265359;
    if (y > 0) return 1.5707963268;
    if (y < 0) return -1.5707963268;
    return 0;
  }

  double _atanApprox(double x) {
    if (x > 1) return 1.5707963268 - _atanApprox(1 / x);
    if (x < -1) return -1.5707963268 - _atanApprox(1 / x);
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
  }
}

@freezed
class LocationPermissionState with _$LocationPermissionState {
  const factory LocationPermissionState.unknown() = _Unknown;
  const factory LocationPermissionState.granted() = _Granted;
  const factory LocationPermissionState.denied() = _Denied;
  const factory LocationPermissionState.deniedForever() = _DeniedForever;
  const factory LocationPermissionState.disabled() = _Disabled;
}
