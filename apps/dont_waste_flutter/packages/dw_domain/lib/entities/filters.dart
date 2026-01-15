import 'package:freezed_annotation/freezed_annotation.dart';

part 'filters.freezed.dart';

@freezed
class ListingFilters with _$ListingFilters {
  const ListingFilters._();

  const factory ListingFilters({
    double? latitude,
    double? longitude,
    @Default(50.0) double radiusKm,
    String? query,
    List<int>? taxonIds,
    double? minPrice,
    double? maxPrice,
    double? minQuantity,
    double? maxQuantity,
    int? expiresWithinHours,
    DateTime? pickupStartAfter,
    DateTime? pickupEndBefore,
    @Default(SortOption.expiresAt) SortOption sortBy,
  }) = _ListingFilters;

  /// Check if any filters are active (besides location)
  bool get hasActiveFilters {
    return query != null && query!.isNotEmpty ||
        taxonIds != null && taxonIds!.isNotEmpty ||
        minPrice != null ||
        maxPrice != null ||
        minQuantity != null ||
        maxQuantity != null ||
        expiresWithinHours != null ||
        pickupStartAfter != null ||
        pickupEndBefore != null;
  }

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (query != null && query!.isNotEmpty) count++;
    if (taxonIds != null && taxonIds!.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minQuantity != null || maxQuantity != null) count++;
    if (expiresWithinHours != null) count++;
    if (pickupStartAfter != null || pickupEndBefore != null) count++;
    return count;
  }

  /// Create a copy with location updated
  ListingFilters withLocation(double lat, double lng) {
    return copyWith(latitude: lat, longitude: lng);
  }

  /// Create a copy with filters cleared (keep location)
  ListingFilters clearFilters() {
    return ListingFilters(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}

enum SortOption {
  distance('distance', 'Distance'),
  expiresAt('expires_at', 'Expiring Soon'),
  price('price', 'Price'),
  bestValue('best_value', 'Best Value');

  final String apiValue;
  final String displayName;

  const SortOption(this.apiValue, this.displayName);
}

/// Preset expiry filter options
enum ExpiryFilter {
  twoHours(2, '2 hours'),
  eightHours(8, '8 hours'),
  twentyFourHours(24, '24 hours'),
  fortyEightHours(48, '48 hours'),
  oneWeek(168, '1 week');

  final int hours;
  final String displayName;

  const ExpiryFilter(this.hours, this.displayName);
}
