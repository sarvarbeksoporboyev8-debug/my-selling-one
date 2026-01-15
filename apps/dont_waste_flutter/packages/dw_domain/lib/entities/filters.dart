class ListingFilters {
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final String? query;
  final List<int>? taxonIds;
  final double? minPrice;
  final double? maxPrice;
  final double? minQuantity;
  final double? maxQuantity;
  final int? expiresWithinHours;
  final DateTime? pickupStartAfter;
  final DateTime? pickupEndBefore;
  final SortOption sortBy;

  const ListingFilters({
    this.latitude,
    this.longitude,
    this.radiusKm = 50.0,
    this.query,
    this.taxonIds,
    this.minPrice,
    this.maxPrice,
    this.minQuantity,
    this.maxQuantity,
    this.expiresWithinHours,
    this.pickupStartAfter,
    this.pickupEndBefore,
    this.sortBy = SortOption.distance,
  });

  ListingFilters copyWith({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? query,
    List<int>? taxonIds,
    double? minPrice,
    double? maxPrice,
    double? minQuantity,
    double? maxQuantity,
    int? expiresWithinHours,
    DateTime? pickupStartAfter,
    DateTime? pickupEndBefore,
    SortOption? sortBy,
  }) {
    return ListingFilters(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      query: query ?? this.query,
      taxonIds: taxonIds ?? this.taxonIds,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      expiresWithinHours: expiresWithinHours ?? this.expiresWithinHours,
      pickupStartAfter: pickupStartAfter ?? this.pickupStartAfter,
      pickupEndBefore: pickupEndBefore ?? this.pickupEndBefore,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return (query != null && query!.isNotEmpty) ||
        (taxonIds != null && taxonIds!.isNotEmpty) ||
        minPrice != null ||
        maxPrice != null ||
        minQuantity != null ||
        maxQuantity != null ||
        expiresWithinHours != null ||
        pickupStartAfter != null ||
        pickupEndBefore != null;
  }

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

  ListingFilters withLocation(double lat, double lng) {
    return copyWith(latitude: lat, longitude: lng);
  }

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
  priceAsc('price_asc', 'Price: Low to High'),
  priceDesc('price_desc', 'Price: High to Low'),
  newest('newest', 'Newest First');

  final String apiValue;
  final String displayName;

  const SortOption(this.apiValue, this.displayName);
}

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
