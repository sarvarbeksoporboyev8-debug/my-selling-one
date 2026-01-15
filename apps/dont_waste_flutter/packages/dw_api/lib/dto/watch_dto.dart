import 'package:freezed_annotation/freezed_annotation.dart';
import 'reservation_dto.dart';

part 'watch_dto.freezed.dart';
part 'watch_dto.g.dart';

@freezed
class WatchDto with _$WatchDto {
  const factory WatchDto({
    required int id,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'radius_km') double? radiusKm,
    @JsonKey(name: 'query_text') String? queryText,
    @JsonKey(name: 'taxon_ids') List<int>? taxonIds,
    @JsonKey(name: 'max_price') double? maxPrice,
    @JsonKey(name: 'min_quantity') double? minQuantity,
    @JsonKey(name: 'expires_within_hours') int? expiresWithinHours,
    required bool active,
    @JsonKey(name: 'email_notifications') bool? emailNotifications,
    @JsonKey(name: 'last_notified_at') DateTime? lastNotifiedAt,
    @JsonKey(name: 'buyer_enterprise') EnterpriseCompactDto? buyerEnterprise,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _WatchDto;

  factory WatchDto.fromJson(Map<String, dynamic> json) =>
      _$WatchDtoFromJson(json);
}

@freezed
class CreateWatchDto with _$CreateWatchDto {
  const factory CreateWatchDto({
    double? latitude,
    double? longitude,
    @JsonKey(name: 'radius_km') double? radiusKm,
    @JsonKey(name: 'query_text') String? queryText,
    @JsonKey(name: 'taxon_ids') List<int>? taxonIds,
    @JsonKey(name: 'max_price') double? maxPrice,
    @JsonKey(name: 'min_quantity') double? minQuantity,
    @JsonKey(name: 'expires_within_hours') int? expiresWithinHours,
    @Default(true) bool active,
    @JsonKey(name: 'email_notifications') @Default(true) bool emailNotifications,
  }) = _CreateWatchDto;

  factory CreateWatchDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWatchDtoFromJson(json);
}
