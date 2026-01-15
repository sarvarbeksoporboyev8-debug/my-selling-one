class ReservationDto {
  final int id;
  final double quantity;
  final double priceAtReservation;
  final double? totalPrice;
  final DateTime reservedUntil;
  final String status;
  final String? notes;
  final int? timeRemainingSeconds;
  final bool? expired;
  final ListingCompactDto? listing;
  final BuyerDto? buyer;
  final EnterpriseCompactDto? buyerEnterprise;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReservationDto({
    required this.id,
    required this.quantity,
    required this.priceAtReservation,
    this.totalPrice,
    required this.reservedUntil,
    required this.status,
    this.notes,
    this.timeRemainingSeconds,
    this.expired,
    this.listing,
    this.buyer,
    this.buyerEnterprise,
    this.createdAt,
    this.updatedAt,
  });

  factory ReservationDto.fromJson(Map<String, dynamic> json) {
    return ReservationDto(
      id: json['id'] as int,
      quantity: (json['quantity'] as num).toDouble(),
      priceAtReservation: (json['price_at_reservation'] as num).toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      reservedUntil: DateTime.parse(json['reserved_until'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      timeRemainingSeconds: json['time_remaining_seconds'] as int?,
      expired: json['expired'] as bool?,
      listing: json['surplus_listing'] != null
          ? ListingCompactDto.fromJson(json['surplus_listing'] as Map<String, dynamic>)
          : null,
      buyer: json['buyer'] != null
          ? BuyerDto.fromJson(json['buyer'] as Map<String, dynamic>)
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
    'quantity': quantity,
    'price_at_reservation': priceAtReservation,
    'total_price': totalPrice,
    'reserved_until': reservedUntil.toIso8601String(),
    'status': status,
    'notes': notes,
    'time_remaining_seconds': timeRemainingSeconds,
    'expired': expired,
    'surplus_listing': listing?.toJson(),
    'buyer': buyer?.toJson(),
    'buyer_enterprise': buyerEnterprise?.toJson(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class ListingCompactDto {
  final int id;
  final String? title;
  final String unit;
  final double basePrice;
  final double currentPrice;
  final DateTime expiresAt;
  final String status;
  final String? enterpriseName;
  final String? variantName;

  const ListingCompactDto({
    required this.id,
    this.title,
    required this.unit,
    required this.basePrice,
    required this.currentPrice,
    required this.expiresAt,
    required this.status,
    this.enterpriseName,
    this.variantName,
  });

  factory ListingCompactDto.fromJson(Map<String, dynamic> json) {
    return ListingCompactDto(
      id: json['id'] as int,
      title: json['title'] as String?,
      unit: json['unit'] as String,
      basePrice: (json['base_price'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      status: json['status'] as String,
      enterpriseName: json['enterprise_name'] as String?,
      variantName: json['variant_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'unit': unit,
    'base_price': basePrice,
    'current_price': currentPrice,
    'expires_at': expiresAt.toIso8601String(),
    'status': status,
    'enterprise_name': enterpriseName,
    'variant_name': variantName,
  };
}

class BuyerDto {
  final int id;
  final String email;
  final String? name;

  const BuyerDto({
    required this.id,
    required this.email,
    this.name,
  });

  factory BuyerDto.fromJson(Map<String, dynamic> json) {
    return BuyerDto(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
  };
}

class EnterpriseCompactDto {
  final int id;
  final String name;

  const EnterpriseCompactDto({
    required this.id,
    required this.name,
  });

  factory EnterpriseCompactDto.fromJson(Map<String, dynamic> json) {
    return EnterpriseCompactDto(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
