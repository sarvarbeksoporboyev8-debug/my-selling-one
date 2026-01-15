import 'package:freezed_annotation/freezed_annotation.dart';
import 'surplus_listing_dto.dart';

part 'reservation_dto.freezed.dart';
part 'reservation_dto.g.dart';

@freezed
class ReservationDto with _$ReservationDto {
  const factory ReservationDto({
    required int id,
    required double quantity,
    @JsonKey(name: 'price_at_reservation') required double priceAtReservation,
    @JsonKey(name: 'total_price') double? totalPrice,
    @JsonKey(name: 'reserved_until') required DateTime reservedUntil,
    required String status,
    String? notes,
    @JsonKey(name: 'time_remaining_seconds') int? timeRemainingSeconds,
    bool? expired,
    @JsonKey(name: 'surplus_listing') ListingCompactDto? listing,
    BuyerDto? buyer,
    @JsonKey(name: 'buyer_enterprise') EnterpriseCompactDto? buyerEnterprise,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ReservationDto;

  factory ReservationDto.fromJson(Map<String, dynamic> json) =>
      _$ReservationDtoFromJson(json);
}

@freezed
class ListingCompactDto with _$ListingCompactDto {
  const factory ListingCompactDto({
    required int id,
    String? title,
    required String unit,
    @JsonKey(name: 'base_price') required double basePrice,
    @JsonKey(name: 'current_price') required double currentPrice,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    required String status,
    @JsonKey(name: 'enterprise_name') String? enterpriseName,
    @JsonKey(name: 'variant_name') String? variantName,
  }) = _ListingCompactDto;

  factory ListingCompactDto.fromJson(Map<String, dynamic> json) =>
      _$ListingCompactDtoFromJson(json);
}

@freezed
class BuyerDto with _$BuyerDto {
  const factory BuyerDto({
    required int id,
    required String email,
    String? name,
  }) = _BuyerDto;

  factory BuyerDto.fromJson(Map<String, dynamic> json) =>
      _$BuyerDtoFromJson(json);
}

@freezed
class EnterpriseCompactDto with _$EnterpriseCompactDto {
  const factory EnterpriseCompactDto({
    required int id,
    required String name,
  }) = _EnterpriseCompactDto;

  factory EnterpriseCompactDto.fromJson(Map<String, dynamic> json) =>
      _$EnterpriseCompactDtoFromJson(json);
}
