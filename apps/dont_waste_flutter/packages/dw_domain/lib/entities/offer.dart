import 'package:freezed_annotation/freezed_annotation.dart';
import 'reservation.dart';

part 'offer.freezed.dart';

@freezed
class Offer with _$Offer {
  const Offer._();

  const factory Offer({
    required int id,
    required double offeredQuantity,
    required double offeredPricePerUnit,
    required double offeredTotal,
    String? message,
    String? sellerResponse,
    required String status,
    double? discountPercentage,
    DateTime? expiresAt,
    DateTime? respondedAt,
    ListingCompact? listing,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Offer;

  /// Check if offer is pending
  bool get isPending => status == 'pending';

  /// Check if offer is accepted
  bool get isAccepted => status == 'accepted';

  /// Check if offer is rejected
  bool get isRejected => status == 'rejected';

  /// Check if offer is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if offer is expired
  bool get isExpired => status == 'expired';

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  /// Get discount display
  String? get discountDisplay {
    if (discountPercentage == null || discountPercentage! <= 0) return null;
    return '${discountPercentage!.toStringAsFixed(1)}% off';
  }
}
