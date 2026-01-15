import '../entities/surplus_listing.dart';
import '../entities/filters.dart';

/// Repository interface for surplus listings
abstract class ListingsRepository {
  /// Search listings with filters
  Future<ListingsResult> searchListings({
    required ListingFilters filters,
    int page = 1,
    int perPage = 20,
  });

  /// Get listing by ID
  Future<SurplusListing> getListing(int id);

  /// Get taxons (categories)
  Future<List<Taxon>> getTaxons();
}

/// Result of listings search
class ListingsResult {
  final List<SurplusListing> listings;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const ListingsResult({
    required this.listings,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });

  factory ListingsResult.empty() {
    return const ListingsResult(
      listings: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 0,
      hasMore: false,
    );
  }
}
