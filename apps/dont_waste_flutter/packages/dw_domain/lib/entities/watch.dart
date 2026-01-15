import 'package:freezed_annotation/freezed_annotation.dart';

part 'watch.freezed.dart';

@freezed
class Watch with _$Watch {
  const Watch._();

  const factory Watch({
    required int id,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? queryText,
    List<int>? taxonIds,
    double? maxPrice,
    double? minQuantity,
    int? expiresWithinHours,
    required bool active,
    bool? emailNotifications,
    DateTime? lastNotifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Watch;

  /// Get a human-readable description of the watch
  String get description {
    final parts = <String>[];

    if (queryText != null && queryText!.isNotEmpty) {
      parts.add('"$queryText"');
    }

    if (radiusKm != null) {
      parts.add('within ${radiusKm!.toInt()}km');
    }

    if (expiresWithinHours != null) {
      if (expiresWithinHours! <= 24) {
        parts.add('expiring in ${expiresWithinHours}h');
      } else {
        parts.add('expiring in ${(expiresWithinHours! / 24).round()}d');
      }
    }

    if (maxPrice != null) {
      parts.add('under \$${maxPrice!.toStringAsFixed(0)}');
    }

    if (minQuantity != null) {
      parts.add('min ${minQuantity!.toStringAsFixed(0)} qty');
    }

    if (parts.isEmpty) {
      return 'All nearby listings';
    }

    return parts.join(' • ');
  }

  /// Check if watch has location filter
  bool get hasLocationFilter => latitude != null && longitude != null;
}

@freezed
class CreateWatch with _$CreateWatch {
  const factory CreateWatch({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? queryText,
    List<int>? taxonIds,
    double? maxPrice,
    double? minQuantity,
    int? expiresWithinHours,
    @Default(true) bool active,
    @Default(true) bool emailNotifications,
  }) = _CreateWatch;
}
