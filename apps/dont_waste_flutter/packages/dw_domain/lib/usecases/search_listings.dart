import '../entities/filters.dart';
import '../entities/surplus_listing.dart';
import '../repositories/listings_repository.dart';

/// Use case for searching surplus listings
class SearchListingsUseCase {
  final ListingsRepository _repository;

  SearchListingsUseCase(this._repository);

  Future<ListingsResult> call({
    required ListingFilters filters,
    int page = 1,
    int perPage = 20,
  }) {
    return _repository.searchListings(
      filters: filters,
      page: page,
      perPage: perPage,
    );
  }
}

/// Use case for getting a single listing
class GetListingUseCase {
  final ListingsRepository _repository;

  GetListingUseCase(this._repository);

  Future<SurplusListing> call(int id) {
    return _repository.getListing(id);
  }
}

/// Use case for getting taxons
class GetTaxonsUseCase {
  final ListingsRepository _repository;

  GetTaxonsUseCase(this._repository);

  Future<List<Taxon>> call() {
    return _repository.getTaxons();
  }
}
