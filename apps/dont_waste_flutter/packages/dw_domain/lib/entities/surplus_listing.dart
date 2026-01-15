class SurplusListing {
  final int id;
  final String? title;
  final String? description;
  final String? qualityNotes;
  final double quantityAvailable;
  final double? quantityOriginal;
  final String unit;
  final double? minOrderQuantity;
  final double basePrice;
  final double currentPrice;
  final String currency;
  final String? pricingStrategy;
  final DateTime expiresAt;
  final DateTime pickupStartAt;
  final DateTime pickupEndAt;
  final String status;
  final String visibility;
  final int? timeLeftSeconds;
  final double? timeLeftHours;
  final double? distanceKm;
  final List<String>? photoUrls;
  final EnterpriseSummary enterprise;
  final VariantSummary variant;
  final AddressSummary? pickupLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Additional fields for app usage
  final double? latitude;
  final double? longitude;
  final List<Taxon> taxons;
  final Seller? seller;
  final double? originalPrice;
  final String? pickupAddress;
  final DateTime? pickupStart;
  final DateTime? pickupEnd;
  final double? distance;
  final double? price;
  final double? quantity;
  final List<String> imageUrls;

  const SurplusListing({
    required this.id,
    this.title,
    this.description,
    this.qualityNotes,
    required this.quantityAvailable,
    this.quantityOriginal,
    required this.unit,
    this.minOrderQuantity,
    required this.basePrice,
    required this.currentPrice,
    required this.currency,
    this.pricingStrategy,
    required this.expiresAt,
    required this.pickupStartAt,
    required this.pickupEndAt,
    required this.status,
    required this.visibility,
    this.timeLeftSeconds,
    this.timeLeftHours,
    this.distanceKm,
    this.photoUrls,
    required this.enterprise,
    required this.variant,
    this.pickupLocation,
    this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.taxons = const [],
    this.seller,
    this.originalPrice,
    this.pickupAddress,
    this.pickupStart,
    this.pickupEnd,
    this.distance,
    this.price,
    this.quantity,
    this.imageUrls = const [],
  });

  String get displayName => title ?? variant.displayName;

  String get pricePerUnit => '$currency ${currentPrice.toStringAsFixed(2)}/$unit';

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  bool get isExpiringSoon {
    final hoursLeft = expiresAt.difference(DateTime.now()).inHours;
    return hoursLeft > 0 && hoursLeft <= 24;
  }

  bool get isUrgent {
    final hoursLeft = expiresAt.difference(DateTime.now()).inHours;
    return hoursLeft > 0 && hoursLeft <= 2;
  }

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

  bool canReserve(double qty) {
    if (isExpired) return false;
    if (status != 'active' && status != 'reserved') return false;
    if (qty > quantityAvailable) return false;
    if (minOrderQuantity != null && qty < minOrderQuantity!) return false;
    return true;
  }

  double? get discountPercentage {
    if (currentPrice >= basePrice) return null;
    return ((basePrice - currentPrice) / basePrice * 100);
  }

  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  String? get primaryPhotoUrl => photoUrls?.isNotEmpty == true ? photoUrls!.first : null;

  SurplusListing copyWith({
    int? id,
    String? title,
    String? description,
    double? quantityAvailable,
    String? unit,
    double? basePrice,
    double? currentPrice,
    String? currency,
    DateTime? expiresAt,
    DateTime? pickupStartAt,
    DateTime? pickupEndAt,
    String? status,
    String? visibility,
    EnterpriseSummary? enterprise,
    VariantSummary? variant,
  }) {
    return SurplusListing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      unit: unit ?? this.unit,
      basePrice: basePrice ?? this.basePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      currency: currency ?? this.currency,
      expiresAt: expiresAt ?? this.expiresAt,
      pickupStartAt: pickupStartAt ?? this.pickupStartAt,
      pickupEndAt: pickupEndAt ?? this.pickupEndAt,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      enterprise: enterprise ?? this.enterprise,
      variant: variant ?? this.variant,
      qualityNotes: qualityNotes,
      quantityOriginal: quantityOriginal,
      minOrderQuantity: minOrderQuantity,
      pricingStrategy: pricingStrategy,
      timeLeftSeconds: timeLeftSeconds,
      timeLeftHours: timeLeftHours,
      distanceKm: distanceKm,
      photoUrls: photoUrls,
      pickupLocation: pickupLocation,
      createdAt: createdAt,
      updatedAt: updatedAt,
      latitude: latitude,
      longitude: longitude,
      taxons: taxons,
      seller: seller,
      originalPrice: originalPrice,
      pickupAddress: pickupAddress,
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      distance: distance,
      price: price,
      quantity: quantity,
      imageUrls: imageUrls,
    );
  }
}

class EnterpriseSummary {
  final int id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final bool? isPrimaryProducer;
  final bool? isDistributor;

  const EnterpriseSummary({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.isPrimaryProducer,
    this.isDistributor,
  });

  bool get isVerified => latitude != null && longitude != null;
}

class VariantSummary {
  final int id;
  final String? sku;
  final String? name;
  final String? productName;
  final double? unitValue;
  final String? unitDescription;

  const VariantSummary({
    required this.id,
    this.sku,
    this.name,
    this.productName,
    this.unitValue,
    this.unitDescription,
  });

  String get displayName => name ?? productName ?? 'Unknown Product';
}

class AddressSummary {
  final int? id;
  final String? address1;
  final String? address2;
  final String? city;
  final String? zipcode;
  final String? stateName;
  final String? countryName;
  final double? latitude;
  final double? longitude;

  const AddressSummary({
    this.id,
    this.address1,
    this.address2,
    this.city,
    this.zipcode,
    this.stateName,
    this.countryName,
    this.latitude,
    this.longitude,
  });

  String get shortDisplay {
    final parts = <String>[];
    if (city != null) parts.add(city!);
    if (stateName != null) parts.add(stateName!);
    return parts.join(', ');
  }

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

class Taxon {
  final int id;
  final String name;
  final String? prettyName;
  final String? permalink;
  final int? parentId;

  const Taxon({
    required this.id,
    required this.name,
    this.prettyName,
    this.permalink,
    this.parentId,
  });
}

class Seller {
  final int id;
  final String name;
  final String? avatarUrl;
  final bool isVerified;
  final double? rating;
  final int? reviewCount;

  const Seller({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isVerified = false,
    this.rating,
    this.reviewCount,
  });
}
