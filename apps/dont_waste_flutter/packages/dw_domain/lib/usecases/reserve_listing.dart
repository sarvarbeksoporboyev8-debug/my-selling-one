import '../entities/reservation.dart';
import '../repositories/reservations_repository.dart';

/// Use case for reserving a listing
class ReserveListingUseCase {
  final ReservationsRepository _repository;

  ReserveListingUseCase(this._repository);

  Future<Reservation> call({
    required int listingId,
    required double quantity,
  }) {
    return _repository.reserveListing(
      listingId: listingId,
      quantity: quantity,
    );
  }
}

/// Use case for getting user's reservations
class GetMyReservationsUseCase {
  final ReservationsRepository _repository;

  GetMyReservationsUseCase(this._repository);

  Future<List<Reservation>> call({String? status}) {
    return _repository.getMyReservations(status: status);
  }
}

/// Use case for cancelling a reservation
class CancelReservationUseCase {
  final ReservationsRepository _repository;

  CancelReservationUseCase(this._repository);

  Future<Reservation> call(int reservationId) {
    return _repository.cancelReservation(reservationId);
  }
}
