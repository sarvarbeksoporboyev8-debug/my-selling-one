import 'package:dw_api/dw_api.dart';
import '../entities/surplus_listing.dart';
import '../entities/reservation.dart';
import '../entities/offer.dart';
import '../entities/watch.dart';
import '../entities/user.dart';

/// Mapper for converting DTOs to domain entities
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
      enterprise: _mapEnterprise(dto.enterprise),
      variant: _mapVariant(dto.variant),
      pickupLocation: dto.pickupLocation != null
          ? _mapAddress(dto.pickupLocation!)
          : null,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static EnterpriseSummary _mapEnterprise(EnterpriseSummaryDto dto) {
    return EnterpriseSummary(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      latitude: dto.latitude,
      longitude: dto.longitude,
      isPrimaryProducer: dto.isPrimaryProducer,
      isDistributor: dto.isDistributor,
    );
  }

  static VariantSummary _mapVariant(VariantSummaryDto dto) {
    return VariantSummary(
      id: dto.id,
      sku: dto.sku,
      name: dto.name,
      productName: dto.productName,
      unitValue: dto.unitValue,
      unitDescription: dto.unitDescription,
    );
  }

  static AddressSummary _mapAddress(AddressSummaryDto dto) {
    return AddressSummary(
      id: dto.id,
      address1: dto.address1,
      address2: dto.address2,
      city: dto.city,
      zipcode: dto.zipcode,
      stateName: dto.stateName,
      countryName: dto.countryName,
      latitude: dto.latitude,
      longitude: dto.longitude,
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
}

class ReservationMapper {
  static Reservation fromDto(ReservationDto dto) {
    return Reservation(
      id: dto.id,
      quantity: dto.quantity,
      priceAtReservation: dto.priceAtReservation,
      totalPrice: dto.totalPrice,
      reservedUntil: dto.reservedUntil,
      status: dto.status,
      notes: dto.notes,
      timeRemainingSeconds: dto.timeRemainingSeconds,
      expired: dto.expired,
      listing: dto.listing != null ? _mapListingCompact(dto.listing!) : null,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static ListingCompact _mapListingCompact(ListingCompactDto dto) {
    return ListingCompact(
      id: dto.id,
      title: dto.title,
      unit: dto.unit,
      basePrice: dto.basePrice,
      currentPrice: dto.currentPrice,
      expiresAt: dto.expiresAt,
      status: dto.status,
      enterpriseName: dto.enterpriseName,
      variantName: dto.variantName,
    );
  }
}

class OfferMapper {
  static Offer fromDto(OfferDto dto) {
    return Offer(
      id: dto.id,
      offeredQuantity: dto.offeredQuantity,
      offeredPricePerUnit: dto.offeredPricePerUnit,
      offeredTotal: dto.offeredTotal,
      message: dto.message,
      sellerResponse: dto.sellerResponse,
      status: dto.status,
      discountPercentage: dto.discountPercentage,
      expiresAt: dto.expiresAt,
      respondedAt: dto.respondedAt,
      listing: dto.listing != null
          ? ListingCompact(
              id: dto.listing!.id,
              title: dto.listing!.title,
              unit: dto.listing!.unit,
              basePrice: dto.listing!.basePrice,
              currentPrice: dto.listing!.currentPrice,
              expiresAt: dto.listing!.expiresAt,
              status: dto.listing!.status,
              enterpriseName: dto.listing!.enterpriseName,
              variantName: dto.listing!.variantName,
            )
          : null,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}

class WatchMapper {
  static Watch fromDto(WatchDto dto) {
    return Watch(
      id: dto.id,
      latitude: dto.latitude,
      longitude: dto.longitude,
      radiusKm: dto.radiusKm,
      queryText: dto.queryText,
      taxonIds: dto.taxonIds,
      maxPrice: dto.maxPrice,
      minQuantity: dto.minQuantity,
      expiresWithinHours: dto.expiresWithinHours,
      active: dto.active,
      emailNotifications: dto.emailNotifications,
      lastNotifiedAt: dto.lastNotifiedAt,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static CreateWatchDto toDto(CreateWatch watch) {
    return CreateWatchDto(
      latitude: watch.latitude,
      longitude: watch.longitude,
      radiusKm: watch.radiusKm,
      queryText: watch.queryText,
      taxonIds: watch.taxonIds,
      maxPrice: watch.maxPrice,
      minQuantity: watch.minQuantity,
      expiresWithinHours: watch.expiresWithinHours,
      active: watch.active,
      emailNotifications: watch.emailNotifications,
    );
  }
}

class UserMapper {
  static User fromDto(UserDto dto) {
    return User(
      id: dto.id,
      email: dto.email,
      firstName: dto.firstName,
      lastName: dto.lastName,
      apiKey: dto.spreeApiKey,
      createdAt: dto.createdAt,
    );
  }
}
