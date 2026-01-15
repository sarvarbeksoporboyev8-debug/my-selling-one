import 'reservation_dto.dart';

class WatchDto {
  final int id;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final String? queryText;
  final List<int>? taxonIds;
  final double? maxPrice;
  final double? minQuantity;
  final int? expiresWithinHours;
  final bool active;
  final bool? emailNotifications;
  final DateTime? lastNotifiedAt;
  final EnterpriseCompactDto? buyerEnterprise;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WatchDto({
    required this.id,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.queryText,
    this.taxonIds,
    this.maxPrice,
    this.minQuantity,
    this.expiresWithinHours,
    required this.active,
    this.emailNotifications,
    this.lastNotifiedAt,
    this.buyerEnterprise,
    this.createdAt,
    this.updatedAt,
  });

  factory WatchDto.fromJson(Map<String, dynamic> json) {
    return WatchDto(
      id: json['id'] as int,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusKm: (json['radius_km'] as num?)?.toDouble(),
      queryText: json['query_text'] as String?,
      taxonIds: (json['taxon_ids'] as List<dynamic>?)?.cast<int>(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      minQuantity: (json['min_quantity'] as num?)?.toDouble(),
      expiresWithinHours: json['expires_within_hours'] as int?,
      active: json['active'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool?,
      lastNotifiedAt: json['last_notified_at'] != null 
          ? DateTime.tryParse(json['last_notified_at'] as String)
          : null,
      buyerEnterprise: json['buyer_enterprise'] != null
          ? EnterpriseCompactDto.fromJson(json['buyer_enterprise'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'radius_km': radiusKm,
    'query_text': queryText,
    'taxon_ids': taxonIds,
    'max_price': maxPrice,
    'min_quantity': minQuantity,
    'expires_within_hours': expiresWithinHours,
    'active': active,
    'email_notifications': emailNotifications,
    'last_notified_at': lastNotifiedAt?.toIso8601String(),
    'buyer_enterprise': buyerEnterprise?.toJson(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class CreateWatchDto {
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final String? queryText;
  final List<int>? taxonIds;
  final double? maxPrice;
  final double? minQuantity;
  final int? expiresWithinHours;
  final bool active;
  final bool emailNotifications;

  const CreateWatchDto({
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.queryText,
    this.taxonIds,
    this.maxPrice,
    this.minQuantity,
    this.expiresWithinHours,
    this.active = true,
    this.emailNotifications = true,
  });

  factory CreateWatchDto.fromJson(Map<String, dynamic> json) {
    return CreateWatchDto(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusKm: (json['radius_km'] as num?)?.toDouble(),
      queryText: json['query_text'] as String?,
      taxonIds: (json['taxon_ids'] as List<dynamic>?)?.cast<int>(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      minQuantity: (json['min_quantity'] as num?)?.toDouble(),
      expiresWithinHours: json['expires_within_hours'] as int?,
      active: json['active'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'radius_km': radiusKm,
    'query_text': queryText,
    'taxon_ids': taxonIds,
    'max_price': maxPrice,
    'min_quantity': minQuantity,
    'expires_within_hours': expiresWithinHours,
    'active': active,
    'email_notifications': emailNotifications,
  };
}
