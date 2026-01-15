class Offer {
  final int id;
  final int listingId;
  final double offeredQuantity;
  final double offeredPricePerUnit;
  final double offeredTotal;
  final String? message;
  final String? sellerResponse;
  final OfferStatus status;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final DateTime createdAt;

  const Offer({
    required this.id,
    required this.listingId,
    required this.offeredQuantity,
    required this.offeredPricePerUnit,
    required this.offeredTotal,
    this.message,
    this.sellerResponse,
    required this.status,
    this.expiresAt,
    this.respondedAt,
    required this.createdAt,
  });

  bool get isPending => status == OfferStatus.pending;
  bool get isAccepted => status == OfferStatus.accepted;
  bool get isRejected => status == OfferStatus.rejected;
  bool get isExpired => status == OfferStatus.expired;
}

enum OfferStatus {
  pending('pending', 'Pending'),
  accepted('accepted', 'Accepted'),
  rejected('rejected', 'Rejected'),
  expired('expired', 'Expired'),
  countered('countered', 'Countered');

  final String value;
  final String displayName;

  const OfferStatus(this.value, this.displayName);

  static OfferStatus fromString(String value) {
    return OfferStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => OfferStatus.pending,
    );
  }
}
