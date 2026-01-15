import 'package:freezed_annotation/freezed_annotation.dart';
import 'reservation_dto.dart';

part 'offer_dto.freezed.dart';
part 'offer_dto.g.dart';

@freezed
class OfferDto with _$OfferDto {
  const factory OfferDto({
    required int id,
    @JsonKey(name: 'offered_quantity') required double offeredQuantity,
    @JsonKey(name: 'offered_price_per_unit') required double offeredPricePerUnit,
    @JsonKey(name: 'offered_total') required double offeredTotal,
    String? message,
    @JsonKey(name: 'seller_response') String? sellerResponse,
    required String status,
    @JsonKey(name: 'discount_percentage') double? discountPercentage,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'surplus_listing') ListingCompactDto? listing,
    BuyerDto? buyer,
    @JsonKey(name: 'buyer_enterprise') EnterpriseCompactDto? buyerEnterprise,
    @JsonKey(name: 'surplus_reservation') ReservationCompactDto? reservation,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _OfferDto;

  factory OfferDto.fromJson(Map<String, dynamic> json) =>
      _$OfferDtoFromJson(json);
}

@freezed
class ReservationCompactDto with _$ReservationCompactDto {
  const factory ReservationCompactDto({
    required int id,
    required double quantity,
    required String status,
    @JsonKey(name: 'reserved_until') required DateTime reservedUntil,
  }) = _ReservationCompactDto;

  factory ReservationCompactDto.fromJson(Map<String, dynamic> json) =>
      _$ReservationCompactDtoFromJson(json);
}
