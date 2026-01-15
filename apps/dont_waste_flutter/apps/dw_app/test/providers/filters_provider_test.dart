import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_domain/dw_domain.dart';
import 'package:dw_app/providers/filters_provider.dart';
import 'package:dw_app/providers/location_provider.dart';

void main() {
  group('FiltersNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has default values', () {
      final filters = container.read(filtersProvider);

      expect(filters.query, isNull);
      expect(filters.taxonIds, isNull);
      expect(filters.minPrice, isNull);
      expect(filters.maxPrice, isNull);
      expect(filters.sortBy, SortOption.distance);
    });

    test('updateQuery updates the query filter', () {
      final notifier = container.read(filtersProvider.notifier);

      notifier.updateQuery('bread');

      final filters = container.read(filtersProvider);
      expect(filters.query, 'bread');
    });

    test('updateRadius updates the radius filter', () {
      final notifier = container.read(filtersProvider.notifier);

      notifier.updateRadius(25.0);

      final filters = container.read(filtersProvider);
      expect(filters.radiusKm, 25.0);
    });

    test('updatePriceRange updates min and max price', () {
      final notifier = container.read(filtersProvider.notifier);

      notifier.updatePriceRange(5.0, 50.0);

      final filters = container.read(filtersProvider);
      expect(filters.minPrice, 5.0);
      expect(filters.maxPrice, 50.0);
    });

    test('updateTaxons updates taxon IDs', () {
      final notifier = container.read(filtersProvider.notifier);

      notifier.updateTaxons([1, 2, 3]);

      final filters = container.read(filtersProvider);
      expect(filters.taxonIds, [1, 2, 3]);
    });

    test('updateSort updates sort option', () {
      final notifier = container.read(filtersProvider.notifier);

      notifier.updateSort(SortOption.priceAsc);

      final filters = container.read(filtersProvider);
      expect(filters.sortBy, SortOption.priceAsc);
    });

    test('clearFilters resets all filters except location', () {
      final notifier = container.read(filtersProvider.notifier);

      // Set some filters
      notifier.updateQuery('test');
      notifier.updatePriceRange(10.0, 100.0);
      notifier.updateTaxons([1, 2]);

      // Clear filters
      notifier.clearFilters();

      final filters = container.read(filtersProvider);
      expect(filters.query, isNull);
      expect(filters.minPrice, isNull);
      expect(filters.maxPrice, isNull);
      expect(filters.taxonIds, isNull);
    });

    test('resetAll resets to default state', () {
      final notifier = container.read(filtersProvider.notifier);

      // Set some filters
      notifier.updateQuery('test');
      notifier.updateRadius(10.0);
      notifier.updateSort(SortOption.priceDesc);

      // Reset all
      notifier.resetAll();

      final filters = container.read(filtersProvider);
      expect(filters, const ListingFilters());
    });
  });

  group('hasActiveFiltersProvider', () {
    test('returns false when no filters are active', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final hasFilters = container.read(hasActiveFiltersProvider);
      expect(hasFilters, isFalse);
    });

    test('returns true when filters are active', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(filtersProvider.notifier).updateQuery('test');

      final hasFilters = container.read(hasActiveFiltersProvider);
      expect(hasFilters, isTrue);
    });
  });

  group('activeFilterCountProvider', () {
    test('returns 0 when no filters are active', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final count = container.read(activeFilterCountProvider);
      expect(count, 0);
    });

    test('returns correct count when filters are active', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(filtersProvider.notifier);
      notifier.updateQuery('test');
      notifier.updatePriceRange(10.0, 100.0);

      final count = container.read(activeFilterCountProvider);
      expect(count, greaterThan(0));
    });
  });
}
