import '../entities/offer.dart';

/// Repository interface for offers
abstract class OffersRepository {
  /// Create an offer for a listing
  Future<Offer> createOffer({
    required int listingId,
    required double quantity,
    required double pricePerUnit,
    String? message,
  });

  /// Get offers for a listing
  Future<List<Offer>> getListingOffers(int listingId);
}
