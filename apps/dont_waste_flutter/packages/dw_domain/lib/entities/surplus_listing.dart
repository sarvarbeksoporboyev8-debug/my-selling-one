import 'package:freezed_annotation/freezed_annotation.dart';

part 'surplus_listing.freezed.dart';

@freezed
class SurplusListing with _$SurplusListing {
  const SurplusListing._();

  const factory SurplusListing({
    required int id,
    String? title,
    String? description,
    String? qualityNotes,
    required double quantityAvailable,
    double? quantityOriginal,
    required String unit,
    double? minOrderQuantity,
    required double basePrice,
    required double currentPrice,
    required String currency,
    String? pricingStrategy,
    required DateTime expiresAt,
    required DateTime pickupStartAt,
    required DateTime pickupEndAt,
    required String status,
    required String visibility,
    int? timeLeftSeconds,
    double? timeLeftHours,
    double? distanceKm,
    List<String>? photoUrls,
    required EnterpriseSummary enterprise,
    required VariantSummary variant,
    AddressSummary? pickupLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SurplusListing;

  /// Display name for the listing
  String get displayName => title ?? variant.displayName;

  /// Price per unit formatted
  String get pricePerUnit => '$currency ${currentPrice.toStringAsFixed(2)}/$unit';

  /// Check if listing is expired
  bool get isExpired => expiresAt.isBefore(DateTime.now());

  /// Check if listing is expiring soon (within 24 hours)
  bool get isExpiringSoon {
    final hoursLeft = expiresAt.difference(DateTime.now()).inHours;
    return hoursLeft > 0 && hoursLeft <= 24;
  }

  /// Check if listing is urgent (within 2 hours)
  bool get isUrgent {
    final hoursLeft = expiresAt.difference(DateTime.now()).inHours;
    return hoursLeft > 0 && hoursLeft <= 2;
  }

  /// Get time left as human readable string
  String get timeLeftDisplay {
    final now = DateTime.now();
    if (expiresAt.isBefore(now)) return 'Expired';

    final diff = expiresAt.difference(now);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ${diff.inHours % 24}h left';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    } else {
      return '${diff.inMinutes}m left';
    }
  }

  /// Get pickup window as human readable string
  String get pickupWindowDisplay {
    final startDate = _formatDate(pickupStartAt);
    final endDate = _formatDate(pickupEndAt);
    final startTime = _formatTime(pickupStartAt);
    final endTime = _formatTime(pickupEndAt);

    if (startDate == endDate) {
      return '$startDate, $startTime - $endTime';
    }
    return '$startDate $startTime - $endDate $endTime';
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  /// Check if can reserve given quantity
  bool canReserve(double quantity) {
    if (isExpired) return false;
    if (status != 'active' && status != 'reserved') return false;
    if (quantity > quantityAvailable) return false;
    if (minOrderQuantity != null && quantity < minOrderQuantity!) return false;
    return true;
  }

  /// Get discount percentage if price is reduced
  double? get discountPercentage {
    if (currentPrice >= basePrice) return null;
    return ((basePrice - currentPrice) / basePrice * 100);
  }

  /// Check if has discount
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  /// Get first photo URL or null
  String? get primaryPhotoUrl => photoUrls?.isNotEmpty == true ? photoUrls!.first : null;
}

@freezed
class EnterpriseSummary with _$EnterpriseSummary {
  const EnterpriseSummary._();

  const factory EnterpriseSummary({
    required int id,
    required String name,
    String? description,
    double? latitude,
    double? longitude,
    bool? isPrimaryProducer,
    bool? isDistributor,
  }) = _EnterpriseSummary;

  /// Check if enterprise is verified (has location)
  bool get isVerified => latitude != null && longitude != null;
}

@freezed
class VariantSummary with _$VariantSummary {
  const VariantSummary._();

  const factory VariantSummary({
    required int id,
    String? sku,
    String? name,
    String? productName,
    double? unitValue,
    String? unitDescription,
  }) = _VariantSummary;

  /// Display name for the variant
  String get displayName => name ?? productName ?? 'Unknown Product';
}

@freezed
class AddressSummary with _$AddressSummary {
  const AddressSummary._();

  const factory AddressSummary({
    int? id,
    String? address1,
    String? address2,
    String? city,
    String? zipcode,
    String? stateName,
    String? countryName,
    double? latitude,
    double? longitude,
  }) = _AddressSummary;

  /// Get short address display
  String get shortDisplay {
    final parts = <String>[];
    if (city != null) parts.add(city!);
    if (stateName != null) parts.add(stateName!);
    return parts.join(', ');
  }

  /// Get full address display
  String get fullDisplay {
    final parts = <String>[];
    if (address1 != null) parts.add(address1!);
    if (address2 != null) parts.add(address2!);
    if (city != null) parts.add(city!);
    if (stateName != null) parts.add(stateName!);
    if (zipcode != null) parts.add(zipcode!);
    return parts.join(', ');
  }
}

@freezed
class Taxon with _$Taxon {
  const factory Taxon({
    required int id,
    required String name,
    String? prettyName,
    String? permalink,
    int? parentId,
  }) = _Taxon;
}
