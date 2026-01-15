import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation.freezed.dart';

@freezed
class Reservation with _$Reservation {
  const Reservation._();

  const factory Reservation({
    required int id,
    required double quantity,
    required double priceAtReservation,
    double? totalPrice,
    required DateTime reservedUntil,
    required String status,
    String? notes,
    int? timeRemainingSeconds,
    bool? expired,
    ListingCompact? listing,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Reservation;

  /// Check if reservation is active
  bool get isActive => status == 'active';

  /// Check if reservation is expired
  bool get isExpired => status == 'expired' || reservedUntil.isBefore(DateTime.now());

  /// Check if reservation is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if reservation is converted to order
  bool get isConverted => status == 'converted';

  /// Get time remaining as human readable string
  String get timeRemainingDisplay {
    if (isExpired) return 'Expired';

    final now = DateTime.now();
    final diff = reservedUntil.difference(now);

    if (diff.isNegative) return 'Expired';

    if (diff.inMinutes < 1) {
      return '${diff.inSeconds}s left';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m left';
    } else {
      return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    }
  }

  /// Get calculated total price
  double get calculatedTotal => totalPrice ?? (quantity * priceAtReservation);

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      case 'converted':
        return 'Completed';
      default:
        return status;
    }
  }
}

@freezed
class ListingCompact with _$ListingCompact {
  const ListingCompact._();

  const factory ListingCompact({
    required int id,
    String? title,
    required String unit,
    required double basePrice,
    required double currentPrice,
    required DateTime expiresAt,
    required String status,
    String? enterpriseName,
    String? variantName,
  }) = _ListingCompact;

  String get displayName => title ?? variantName ?? 'Unknown';
}
