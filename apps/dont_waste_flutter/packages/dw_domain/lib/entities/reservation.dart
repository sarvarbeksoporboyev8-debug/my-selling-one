import 'surplus_listing.dart';

class Reservation {
  final int id;
  final SurplusListing listing;
  final double quantity;
  final double totalPrice;
  final ReservationStatus status;
  final String? message;
  final DateTime? preferredPickupTime;
  final DateTime? confirmedPickupTime;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const Reservation({
    required this.id,
    required this.listing,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    this.message,
    this.preferredPickupTime,
    this.confirmedPickupTime,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isActive =>
      status == ReservationStatus.pending ||
      status == ReservationStatus.confirmed;

  bool get isExpired => status == ReservationStatus.expired;

  bool get isCancelled => status == ReservationStatus.cancelled;

  bool get isCompleted => status == ReservationStatus.completed;

  String get timeRemainingDisplay {
    if (expiresAt == null) return '';
    if (isExpired) return 'Expired';

    final now = DateTime.now();
    final diff = expiresAt!.difference(now);

    if (diff.isNegative) return 'Expired';

    if (diff.inMinutes < 1) {
      return '${diff.inSeconds}s left';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m left';
    } else {
      return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    }
  }

  Reservation copyWith({
    int? id,
    SurplusListing? listing,
    double? quantity,
    double? totalPrice,
    ReservationStatus? status,
    String? message,
    DateTime? preferredPickupTime,
    DateTime? confirmedPickupTime,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      listing: listing ?? this.listing,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      message: message ?? this.message,
      preferredPickupTime: preferredPickupTime ?? this.preferredPickupTime,
      confirmedPickupTime: confirmedPickupTime ?? this.confirmedPickupTime,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

enum ReservationStatus {
  pending('pending', 'Pending'),
  confirmed('confirmed', 'Confirmed'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled'),
  expired('expired', 'Expired');

  final String value;
  final String displayName;

  const ReservationStatus(this.value, this.displayName);

  static ReservationStatus fromString(String value) {
    return ReservationStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ReservationStatus.pending,
    );
  }
}
