import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_api/dw_api.dart';
import 'package:dw_domain/dw_domain.dart';

import 'api_provider.dart';

/// Watchlist provider
final watchlistProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<List<WatchlistItem>>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WatchlistNotifier(apiClient);
});

class WatchlistNotifier extends StateNotifier<AsyncValue<List<WatchlistItem>>> {
  final ApiClient _apiClient;

  WatchlistNotifier(this._apiClient) : super(const AsyncValue.loading()) {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiClient.getWatchlist();
      final items = response.items.map(_mapWatchlistItem).toList();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addToWatchlist(int listingId) async {
    try {
      final dto = await _apiClient.addToWatchlist(listingId);
      final item = _mapWatchlistItem(dto);

      state.whenData((items) {
        state = AsyncValue.data([...items, item]);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromWatchlist(int listingId) async {
    try {
      await _apiClient.removeFromWatchlist(listingId);

      state.whenData((items) {
        state = AsyncValue.data(
          items.where((item) => item.listing.id != listingId).toList(),
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  WatchlistItem _mapWatchlistItem(WatchlistItemDto dto) {
    return WatchlistItem(
      id: dto.id,
      listing: ListingMapper.fromDto(dto.listing),
      addedAt: dto.addedAt,
      notifyOnPriceChange: dto.notifyOnPriceChange,
      notifyOnLowStock: dto.notifyOnLowStock,
    );
  }
}

/// Check if listing is in watchlist
final isInWatchlistProvider = Provider.family<bool, int>((ref, listingId) {
  final watchlist = ref.watch(watchlistProvider);
  return watchlist.maybeWhen(
    data: (items) => items.any((item) => item.listing.id == listingId),
    orElse: () => false,
  );
});

/// Watchlist count provider
final watchlistCountProvider = Provider<int>((ref) {
  final watchlist = ref.watch(watchlistProvider);
  return watchlist.maybeWhen(
    data: (items) => items.length,
    orElse: () => 0,
  );
});
