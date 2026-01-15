import 'package:dw_api/dw_api.dart';
import '../entities/surplus_listing.dart';
import '../entities/reservation.dart';
import '../entities/user.dart';

/// Maps DTOs to domain entities
class ListingMapper {
  static SurplusListing fromDto(SurplusListingDto dto) {
    return SurplusListing(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      qualityNotes: dto.qualityNotes,
      quantityAvailable: dto.quantityAvailable,
      quantityOriginal: dto.quantityOriginal,
      unit: dto.unit,
      minOrderQuantity: dto.minOrderQuantity,
      basePrice: dto.basePrice,
      currentPrice: dto.currentPrice,
      currency: dto.currency,
      pricingStrategy: dto.pricingStrategy,
      expiresAt: dto.expiresAt,
      pickupStartAt: dto.pickupStartAt,
      pickupEndAt: dto.pickupEndAt,
      status: dto.status,
      visibility: dto.visibility,
      timeLeftSeconds: dto.timeLeftSeconds,
      timeLeftHours: dto.timeLeftHours,
      distanceKm: dto.distanceKm,
      photoUrls: dto.photoUrls,
      enterprise: EnterpriseSummary(
        id: dto.enterprise.id,
        name: dto.enterprise.name,
        description: dto.enterprise.description,
        latitude: dto.enterprise.latitude,
        longitude: dto.enterprise.longitude,
        isPrimaryProducer: dto.enterprise.isPrimaryProducer,
        isDistributor: dto.enterprise.isDistributor,
      ),
      variant: VariantSummary(
        id: dto.variant.id,
        sku: dto.variant.sku,
        name: dto.variant.name,
        productName: dto.variant.productName,
        unitValue: dto.variant.unitValue,
        unitDescription: dto.variant.unitDescription,
      ),
      pickupLocation: dto.pickupLocation != null
          ? AddressSummary(
              id: dto.pickupLocation!.id,
              address1: dto.pickupLocation!.address1,
              address2: dto.pickupLocation!.address2,
              city: dto.pickupLocation!.city,
              zipcode: dto.pickupLocation!.zipcode,
              stateName: dto.pickupLocation!.stateName,
              countryName: dto.pickupLocation!.countryName,
              latitude: dto.pickupLocation!.latitude,
              longitude: dto.pickupLocation!.longitude,
            )
          : null,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      latitude: dto.pickupLocation?.latitude ?? dto.enterprise.latitude,
      longitude: dto.pickupLocation?.longitude ?? dto.enterprise.longitude,
      imageUrls: dto.photoUrls ?? [],
      seller: Seller(
        id: dto.enterprise.id,
        name: dto.enterprise.name,
        isVerified: true,
      ),
    );
  }

  static Taxon taxonFromDto(TaxonDto dto) {
    return Taxon(
      id: dto.id,
      name: dto.name,
      prettyName: dto.prettyName,
      permalink: dto.permalink,
      parentId: dto.parentId,
    );
  }

  static User userFromDto(UserDto dto) {
    return User(
      id: dto.id,
      email: dto.email,
      name: '${dto.firstName ?? ''} ${dto.lastName ?? ''}'.trim(),
      createdAt: dto.createdAt,
    );
  }
}

/// Alias for backward compatibility
class UserMapper {
  static User fromDto(UserDto dto) => ListingMapper.userFromDto(dto);
}

/// Result class for paginated listings
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
}
