import 'surplus_listing.dart';

class WatchlistItem {
  final int id;
  final SurplusListing listing;
  final DateTime addedAt;
  final bool notifyOnPriceChange;
  final bool notifyOnLowStock;

  const WatchlistItem({
    required this.id,
    required this.listing,
    required this.addedAt,
    this.notifyOnPriceChange = true,
    this.notifyOnLowStock = true,
  });
}

class SavedSearch {
  final int id;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final String? queryText;
  final List<int>? taxonIds;
  final double? maxPrice;
  final double? minQuantity;
  final int? expiresWithinHours;
  final bool active;
  final bool emailNotifications;
  final DateTime? lastNotifiedAt;
  final DateTime createdAt;

  const SavedSearch({
    required this.id,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.queryText,
    this.taxonIds,
    this.maxPrice,
    this.minQuantity,
    this.expiresWithinHours,
    this.active = true,
    this.emailNotifications = true,
    this.lastNotifiedAt,
    required this.createdAt,
  });
}
