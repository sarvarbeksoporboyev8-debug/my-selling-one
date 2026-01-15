import 'dart:math' as math;

class UserLocation {
  final double latitude;
  final double longitude;
  final String? displayName;
  final String? city;
  final String? country;
  final DateTime? timestamp;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.displayName,
    this.city,
    this.country,
    this.timestamp,
  });

  String get shortDisplay => displayName ?? city ?? 'Current Location';
  
  // Alias for compatibility
  String? get name => displayName;

  double distanceTo(double lat, double lng) {
    const earthRadius = 6371.0; // km

    final dLat = _toRadians(lat - latitude);
    final dLng = _toRadians(lng - longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  UserLocation copyWith({
    double? latitude,
    double? longitude,
    String? displayName,
    String? city,
    String? country,
    DateTime? timestamp,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      displayName: displayName ?? this.displayName,
      city: city ?? this.city,
      country: country ?? this.country,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
