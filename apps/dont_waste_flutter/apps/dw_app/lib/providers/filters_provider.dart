import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_domain/dw_domain.dart';

import 'location_provider.dart';

/// Filters state provider
final filtersProvider = StateNotifierProvider<FiltersNotifier, ListingFilters>((ref) {
  final location = ref.watch(selectedLocationProvider);
  final radius = ref.watch(selectedRadiusProvider);

  return FiltersNotifier(
    initialLocation: location,
    initialRadius: radius,
  );
});

class FiltersNotifier extends StateNotifier<ListingFilters> {
  FiltersNotifier({
    UserLocation? initialLocation,
    double initialRadius = 50.0,
  }) : super(ListingFilters(
          latitude: initialLocation?.latitude,
          longitude: initialLocation?.longitude,
          radiusKm: initialRadius,
        ));

  void updateLocation(double lat, double lng) {
    state = state.copyWith(latitude: lat, longitude: lng);
  }

  void updateRadius(double radius) {
    state = state.copyWith(radiusKm: radius);
  }

  void updateQuery(String? query) {
    state = state.copyWith(query: query);
  }

  void updateTaxons(List<int>? taxonIds) {
    state = state.copyWith(taxonIds: taxonIds);
  }

  void updatePriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void updateQuantityRange(double? min, double? max) {
    state = state.copyWith(minQuantity: min, maxQuantity: max);
  }

  void updateExpiryFilter(int? hours) {
    state = state.copyWith(expiresWithinHours: hours);
  }

  void updatePickupWindow(DateTime? start, DateTime? end) {
    state = state.copyWith(
      pickupStartAfter: start,
      pickupEndBefore: end,
    );
  }

  void updateSort(SortOption sort) {
    state = state.copyWith(sortBy: sort);
  }

  void clearFilters() {
    state = state.clearFilters();
  }

  void resetAll() {
    state = const ListingFilters();
  }
}

/// Sort option provider
final sortOptionProvider = Provider<SortOption>((ref) {
  return ref.watch(filtersProvider).sortBy;
});

/// Has active filters provider
final hasActiveFiltersProvider = Provider<bool>((ref) {
  return ref.watch(filtersProvider).hasActiveFilters;
});

/// Active filter count provider
final activeFilterCountProvider = Provider<int>((ref) {
  return ref.watch(filtersProvider).activeFilterCount;
});
