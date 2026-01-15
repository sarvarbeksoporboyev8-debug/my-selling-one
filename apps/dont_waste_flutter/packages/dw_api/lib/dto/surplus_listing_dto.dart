import 'package:freezed_annotation/freezed_annotation.dart';

part 'surplus_listing_dto.freezed.dart';
part 'surplus_listing_dto.g.dart';

@freezed
class SurplusListingDto with _$SurplusListingDto {
  const factory SurplusListingDto({
    required int id,
    String? title,
    String? description,
    @JsonKey(name: 'quality_notes') String? qualityNotes,
    @JsonKey(name: 'quantity_available') required double quantityAvailable,
    @JsonKey(name: 'quantity_original') double? quantityOriginal,
    required String unit,
    @JsonKey(name: 'min_order_quantity') double? minOrderQuantity,
    @JsonKey(name: 'base_price') required double basePrice,
    @JsonKey(name: 'current_price') required double currentPrice,
    required String currency,
    @JsonKey(name: 'pricing_strategy') String? pricingStrategy,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @JsonKey(name: 'pickup_start_at') required DateTime pickupStartAt,
    @JsonKey(name: 'pickup_end_at') required DateTime pickupEndAt,
    required String status,
    required String visibility,
    @JsonKey(name: 'time_left_seconds') int? timeLeftSeconds,
    @JsonKey(name: 'time_left_hours') double? timeLeftHours,
    @JsonKey(name: 'distance_km') double? distanceKm,
    @JsonKey(name: 'photo_urls') List<String>? photoUrls,
    required EnterpriseSummaryDto enterprise,
    required VariantSummaryDto variant,
    @JsonKey(name: 'pickup_location') AddressSummaryDto? pickupLocation,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SurplusListingDto;

  factory SurplusListingDto.fromJson(Map<String, dynamic> json) =>
      _$SurplusListingDtoFromJson(json);
}

@freezed
class EnterpriseSummaryDto with _$EnterpriseSummaryDto {
  const factory EnterpriseSummaryDto({
    required int id,
    required String name,
    String? description,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'is_primary_producer') bool? isPrimaryProducer,
    @JsonKey(name: 'is_distributor') bool? isDistributor,
  }) = _EnterpriseSummaryDto;

  factory EnterpriseSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$EnterpriseSummaryDtoFromJson(json);
}

@freezed
class VariantSummaryDto with _$VariantSummaryDto {
  const factory VariantSummaryDto({
    required int id,
    String? sku,
    String? name,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'unit_value') double? unitValue,
    @JsonKey(name: 'unit_description') String? unitDescription,
  }) = _VariantSummaryDto;

  factory VariantSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$VariantSummaryDtoFromJson(json);
}

@freezed
class AddressSummaryDto with _$AddressSummaryDto {
  const factory AddressSummaryDto({
    int? id,
    String? address1,
    String? address2,
    String? city,
    String? zipcode,
    @JsonKey(name: 'state_name') String? stateName,
    @JsonKey(name: 'country_name') String? countryName,
    double? latitude,
    double? longitude,
  }) = _AddressSummaryDto;

  factory AddressSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$AddressSummaryDtoFromJson(json);
}

@freezed
class TaxonDto with _$TaxonDto {
  const factory TaxonDto({
    required int id,
    required String name,
    @JsonKey(name: 'pretty_name') String? prettyName,
    String? permalink,
    @JsonKey(name: 'parent_id') int? parentId,
  }) = _TaxonDto;

  factory TaxonDto.fromJson(Map<String, dynamic> json) =>
      _$TaxonDtoFromJson(json);
}
