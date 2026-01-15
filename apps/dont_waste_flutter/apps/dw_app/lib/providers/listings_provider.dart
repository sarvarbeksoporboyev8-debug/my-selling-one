import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_api/dw_api.dart';
import 'package:dw_domain/dw_domain.dart';

import 'api_provider.dart';
import 'filters_provider.dart';
import 'demo_data_provider.dart';

/// Listings search provider
final listingsProvider = StateNotifierProvider<ListingsNotifier, AsyncValue<ListingsState>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final filters = ref.watch(filtersProvider);

  final notifier = ListingsNotifier(apiClient, filters);
  notifier.loadListings();
  return notifier;
});

class ListingsState {
  final List<SurplusListing> listings;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const ListingsState({
    this.listings = const [],
    this.currentPage = 1,
    this.totalPages = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  ListingsState copyWith({
    List<SurplusListing>? listings,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ListingsState(
      listings: listings ?? this.listings,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ListingsNotifier extends StateNotifier<AsyncValue<ListingsState>> {
  final ApiClient _apiClient;
  final ListingFilters _filters;

  ListingsNotifier(this._apiClient, this._filters)
      : super(const AsyncValue.loading());

  Future<void> loadListings() async {
    state = const AsyncValue.loading();
    
    // Use demo data if in demo mode
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      state = AsyncValue.data(ListingsState(
        listings: demoListings,
        currentPage: 1,
        totalPages: 1,
        hasMore: false,
      ));
      return;
    }
    
    try {
      final result = await _fetchListings(page: 1);
      state = AsyncValue.data(ListingsState(
        listings: result.listings,
        currentPage: 1,
        totalPages: result.totalPages,
        hasMore: result.hasMore,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final result = await _fetchListings(page: nextPage);

      state = AsyncValue.data(currentState.copyWith(
        listings: [...currentState.listings, ...result.listings],
        currentPage: nextPage,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    await loadListings();
  }

  Future<ListingsResult> _fetchListings({required int page}) async {
    final response = await _apiClient.searchListings(
      latitude: _filters.latitude,
      longitude: _filters.longitude,
      radiusKm: _filters.radiusKm,
      query: _filters.query,
      taxonIds: _filters.taxonIds,
      minPrice: _filters.minPrice,
      maxPrice: _filters.maxPrice,
      minQuantity: _filters.minQuantity,
      maxQuantity: _filters.maxQuantity,
      expiresWithinHours: _filters.expiresWithinHours,
      pickupStartAfter: _filters.pickupStartAfter,
      pickupEndBefore: _filters.pickupEndBefore,
      sort: _filters.sortBy.apiValue,
      page: page,
    );

    final listings = response.items.map(ListingMapper.fromDto).toList();

    return ListingsResult(
      listings: listings,
      totalCount: response.pagination?.totalCount ?? listings.length,
      currentPage: response.pagination?.page ?? page,
      totalPages: response.pagination?.totalPages ?? 1,
      hasMore: response.hasMore,
    );
  }
}

/// Single listing detail provider
final listingDetailProvider = FutureProvider.family<SurplusListing, int>((ref, id) async {
  // Use demo data if in demo mode
  if (isDemoMode) {
    await Future.delayed(const Duration(milliseconds: 200));
    return demoListings.firstWhere(
      (l) => l.id == id,
      orElse: () => demoListings.first,
    );
  }
  
  final apiClient = ref.watch(apiClientProvider);
  final dto = await apiClient.getListing(id);
  return ListingMapper.fromDto(dto);
});

/// Taxons provider
final taxonsProvider = FutureProvider<List<Taxon>>((ref) async {
  // Use demo data if in demo mode
  if (isDemoMode) {
    await Future.delayed(const Duration(milliseconds: 100));
    return demoTaxons;
  }
  
  final apiClient = ref.watch(apiClientProvider);
  final dtos = await apiClient.getTaxons();
  return dtos.map(ListingMapper.taxonFromDto).toList();
});
