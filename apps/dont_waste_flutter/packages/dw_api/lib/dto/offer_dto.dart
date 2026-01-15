import 'reservation_dto.dart';

class OfferDto {
  final int id;
  final double offeredQuantity;
  final double offeredPricePerUnit;
  final double offeredTotal;
  final String? message;
  final String? sellerResponse;
  final String status;
  final double? discountPercentage;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final ListingCompactDto? listing;
  final BuyerDto? buyer;
  final EnterpriseCompactDto? buyerEnterprise;
  final ReservationCompactDto? reservation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OfferDto({
    required this.id,
    required this.offeredQuantity,
    required this.offeredPricePerUnit,
    required this.offeredTotal,
    this.message,
    this.sellerResponse,
    required this.status,
    this.discountPercentage,
    this.expiresAt,
    this.respondedAt,
    this.listing,
    this.buyer,
    this.buyerEnterprise,
    this.reservation,
    this.createdAt,
    this.updatedAt,
  });

  factory OfferDto.fromJson(Map<String, dynamic> json) {
    return OfferDto(
      id: json['id'] as int,
      offeredQuantity: (json['offered_quantity'] as num).toDouble(),
      offeredPricePerUnit: (json['offered_price_per_unit'] as num).toDouble(),
      offeredTotal: (json['offered_total'] as num).toDouble(),
      message: json['message'] as String?,
      sellerResponse: json['seller_response'] as String?,
      status: json['status'] as String,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
      respondedAt: json['responded_at'] != null ? DateTime.tryParse(json['responded_at'] as String) : null,
      listing: json['surplus_listing'] != null
          ? ListingCompactDto.fromJson(json['surplus_listing'] as Map<String, dynamic>)
          : null,
      buyer: json['buyer'] != null
          ? BuyerDto.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
      buyerEnterprise: json['buyer_enterprise'] != null
          ? EnterpriseCompactDto.fromJson(json['buyer_enterprise'] as Map<String, dynamic>)
          : null,
      reservation: json['surplus_reservation'] != null
          ? ReservationCompactDto.fromJson(json['surplus_reservation'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'offered_quantity': offeredQuantity,
    'offered_price_per_unit': offeredPricePerUnit,
    'offered_total': offeredTotal,
    'message': message,
    'seller_response': sellerResponse,
    'status': status,
    'discount_percentage': discountPercentage,
    'expires_at': expiresAt?.toIso8601String(),
    'responded_at': respondedAt?.toIso8601String(),
    'surplus_listing': listing?.toJson(),
    'buyer': buyer?.toJson(),
    'buyer_enterprise': buyerEnterprise?.toJson(),
    'surplus_reservation': reservation?.toJson(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class ReservationCompactDto {
  final int id;
  final double quantity;
  final String status;
  final DateTime reservedUntil;

  const ReservationCompactDto({
    required this.id,
    required this.quantity,
    required this.status,
    required this.reservedUntil,
  });

  factory ReservationCompactDto.fromJson(Map<String, dynamic> json) {
    return ReservationCompactDto(
      id: json['id'] as int,
      quantity: (json['quantity'] as num).toDouble(),
      status: json['status'] as String,
      reservedUntil: DateTime.parse(json['reserved_until'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'quantity': quantity,
    'status': status,
    'reserved_until': reservedUntil.toIso8601String(),
  };
}
