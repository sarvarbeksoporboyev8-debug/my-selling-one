class SurplusListingDto {
  final int id;
  final String? title;
  final String? description;
  final String? qualityNotes;
  final double quantityAvailable;
  final double? quantityOriginal;
  final String unit;
  final double? minOrderQuantity;
  final double basePrice;
  final double currentPrice;
  final String currency;
  final String? pricingStrategy;
  final DateTime expiresAt;
  final DateTime pickupStartAt;
  final DateTime pickupEndAt;
  final String status;
  final String visibility;
  final int? timeLeftSeconds;
  final double? timeLeftHours;
  final double? distanceKm;
  final List<String>? photoUrls;
  final EnterpriseSummaryDto enterprise;
  final VariantSummaryDto variant;
  final AddressSummaryDto? pickupLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SurplusListingDto({
    required this.id,
    this.title,
    this.description,
    this.qualityNotes,
    required this.quantityAvailable,
    this.quantityOriginal,
    required this.unit,
    this.minOrderQuantity,
    required this.basePrice,
    required this.currentPrice,
    required this.currency,
    this.pricingStrategy,
    required this.expiresAt,
    required this.pickupStartAt,
    required this.pickupEndAt,
    required this.status,
    required this.visibility,
    this.timeLeftSeconds,
    this.timeLeftHours,
    this.distanceKm,
    this.photoUrls,
    required this.enterprise,
    required this.variant,
    this.pickupLocation,
    this.createdAt,
    this.updatedAt,
  });

  factory SurplusListingDto.fromJson(Map<String, dynamic> json) {
    return SurplusListingDto(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      qualityNotes: json['quality_notes'] as String?,
      quantityAvailable: (json['quantity_available'] as num).toDouble(),
      quantityOriginal: (json['quantity_original'] as num?)?.toDouble(),
      unit: json['unit'] as String,
      minOrderQuantity: (json['min_order_quantity'] as num?)?.toDouble(),
      basePrice: (json['base_price'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
      currency: json['currency'] as String,
      pricingStrategy: json['pricing_strategy'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      pickupStartAt: DateTime.parse(json['pickup_start_at'] as String),
      pickupEndAt: DateTime.parse(json['pickup_end_at'] as String),
      status: json['status'] as String,
      visibility: json['visibility'] as String,
      timeLeftSeconds: json['time_left_seconds'] as int?,
      timeLeftHours: (json['time_left_hours'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      photoUrls: (json['photo_urls'] as List<dynamic>?)?.cast<String>(),
      enterprise: EnterpriseSummaryDto.fromJson(json['enterprise'] as Map<String, dynamic>),
      variant: VariantSummaryDto.fromJson(json['variant'] as Map<String, dynamic>),
      pickupLocation: json['pickup_location'] != null
          ? AddressSummaryDto.fromJson(json['pickup_location'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'quality_notes': qualityNotes,
    'quantity_available': quantityAvailable,
    'quantity_original': quantityOriginal,
    'unit': unit,
    'min_order_quantity': minOrderQuantity,
    'base_price': basePrice,
    'current_price': currentPrice,
    'currency': currency,
    'pricing_strategy': pricingStrategy,
    'expires_at': expiresAt.toIso8601String(),
    'pickup_start_at': pickupStartAt.toIso8601String(),
    'pickup_end_at': pickupEndAt.toIso8601String(),
    'status': status,
    'visibility': visibility,
    'time_left_seconds': timeLeftSeconds,
    'time_left_hours': timeLeftHours,
    'distance_km': distanceKm,
    'photo_urls': photoUrls,
    'enterprise': enterprise.toJson(),
    'variant': variant.toJson(),
    'pickup_location': pickupLocation?.toJson(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class EnterpriseSummaryDto {
  final int id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final bool? isPrimaryProducer;
  final bool? isDistributor;

  const EnterpriseSummaryDto({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.isPrimaryProducer,
    this.isDistributor,
  });

  factory EnterpriseSummaryDto.fromJson(Map<String, dynamic> json) {
    return EnterpriseSummaryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isPrimaryProducer: json['is_primary_producer'] as bool?,
      isDistributor: json['is_distributor'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'is_primary_producer': isPrimaryProducer,
    'is_distributor': isDistributor,
  };
}

class VariantSummaryDto {
  final int id;
  final String? sku;
  final String? name;
  final String? productName;
  final double? unitValue;
  final String? unitDescription;

  const VariantSummaryDto({
    required this.id,
    this.sku,
    this.name,
    this.productName,
    this.unitValue,
    this.unitDescription,
  });

  factory VariantSummaryDto.fromJson(Map<String, dynamic> json) {
    return VariantSummaryDto(
      id: json['id'] as int,
      sku: json['sku'] as String?,
      name: json['name'] as String?,
      productName: json['product_name'] as String?,
      unitValue: (json['unit_value'] as num?)?.toDouble(),
      unitDescription: json['unit_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'name': name,
    'product_name': productName,
    'unit_value': unitValue,
    'unit_description': unitDescription,
  };
}

class AddressSummaryDto {
  final int? id;
  final String? address1;
  final String? address2;
  final String? city;
  final String? zipcode;
  final String? stateName;
  final String? countryName;
  final double? latitude;
  final double? longitude;

  const AddressSummaryDto({
    this.id,
    this.address1,
    this.address2,
    this.city,
    this.zipcode,
    this.stateName,
    this.countryName,
    this.latitude,
    this.longitude,
  });

  factory AddressSummaryDto.fromJson(Map<String, dynamic> json) {
    return AddressSummaryDto(
      id: json['id'] as int?,
      address1: json['address1'] as String?,
      address2: json['address2'] as String?,
      city: json['city'] as String?,
      zipcode: json['zipcode'] as String?,
      stateName: json['state_name'] as String?,
      countryName: json['country_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'address1': address1,
    'address2': address2,
    'city': city,
    'zipcode': zipcode,
    'state_name': stateName,
    'country_name': countryName,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class TaxonDto {
  final int id;
  final String name;
  final String? prettyName;
  final String? permalink;
  final int? parentId;

  const TaxonDto({
    required this.id,
    required this.name,
    this.prettyName,
    this.permalink,
    this.parentId,
  });

  factory TaxonDto.fromJson(Map<String, dynamic> json) {
    return TaxonDto(
      id: json['id'] as int,
      name: json['name'] as String,
      prettyName: json['pretty_name'] as String?,
      permalink: json['permalink'] as String?,
      parentId: json['parent_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'pretty_name': prettyName,
    'permalink': permalink,
    'parent_id': parentId,
  };
}
