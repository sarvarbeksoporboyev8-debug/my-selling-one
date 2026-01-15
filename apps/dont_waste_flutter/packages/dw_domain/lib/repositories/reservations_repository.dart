import '../entities/reservation.dart';

/// Repository interface for reservations
abstract class ReservationsRepository {
  /// Reserve quantity from a listing
  Future<Reservation> reserveListing({
    required int listingId,
    required double quantity,
  });

  /// Get user's reservations
  Future<List<Reservation>> getMyReservations({String? status});

  /// Cancel a reservation
  Future<Reservation> cancelReservation(int reservationId);
}
