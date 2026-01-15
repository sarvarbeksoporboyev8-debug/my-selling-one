import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_domain/dw_domain.dart';

import 'demo_data_provider.dart';

/// Watchlist provider - local-only implementation
/// Note: Backend watchlist API not yet available
final watchlistProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<List<WatchlistItem>>>((ref) {
  return WatchlistNotifier();
});

class WatchlistNotifier extends StateNotifier<AsyncValue<List<WatchlistItem>>> {
  final List<WatchlistItem> _items = [];

  WatchlistNotifier() : super(const AsyncValue.data([])) {
    _loadInitialData();
  }

  void _loadInitialData() {
    if (isDemoMode) {
      _items.addAll(demoWatchlist);
      state = AsyncValue.data(List.from(_items));
    }
  }

  Future<void> loadWatchlist() async {
    if (isDemoMode && _items.isEmpty) {
      _items.addAll(demoWatchlist);
    }
    state = AsyncValue.data(List.from(_items));
  }

  Future<void> addToWatchlist(SurplusListing listing) async {
    final item = WatchlistItem(
      id: DateTime.now().millisecondsSinceEpoch,
      listing: listing,
      addedAt: DateTime.now(),
    );
    _items.add(item);
    state = AsyncValue.data(List.from(_items));
  }

  Future<void> removeFromWatchlist(int listingId) async {
    _items.removeWhere((item) => item.listing.id == listingId);
    state = AsyncValue.data(List.from(_items));
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
