import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_api/dw_api.dart';
import 'package:dw_domain/dw_domain.dart';

import 'api_provider.dart';

/// User reservations provider
final reservationsProvider = StateNotifierProvider<ReservationsNotifier, AsyncValue<List<Reservation>>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReservationsNotifier(apiClient);
});

class ReservationsNotifier extends StateNotifier<AsyncValue<List<Reservation>>> {
  final ApiClient _apiClient;

  ReservationsNotifier(this._apiClient) : super(const AsyncValue.loading()) {
    loadReservations();
  }

  Future<void> loadReservations() async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiClient.getMyReservations();
      final reservations = response.items.map(_mapReservation).toList();
      state = AsyncValue.data(reservations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Reservation> createReservation({
    required int listingId,
    required double quantity,
    String? message,
    DateTime? preferredPickupTime,
  }) async {
    final dto = await _apiClient.createReservation(
      listingId: listingId,
      quantity: quantity,
      message: message,
      preferredPickupTime: preferredPickupTime,
    );

    final reservation = _mapReservation(dto);

    state.whenData((reservations) {
      state = AsyncValue.data([reservation, ...reservations]);
    });

    return reservation;
  }

  Future<void> cancelReservation(int reservationId) async {
    await _apiClient.cancelReservation(reservationId);

    state.whenData((reservations) {
      state = AsyncValue.data(
        reservations.map((r) {
          if (r.id == reservationId) {
            return r.copyWith(status: ReservationStatus.cancelled);
          }
          return r;
        }).toList(),
      );
    });
  }

  Future<void> confirmPickup(int reservationId) async {
    await _apiClient.confirmPickup(reservationId);

    state.whenData((reservations) {
      state = AsyncValue.data(
        reservations.map((r) {
          if (r.id == reservationId) {
            return r.copyWith(status: ReservationStatus.completed);
          }
          return r;
        }).toList(),
      );
    });
  }

  Reservation _mapReservation(ReservationDto dto) {
    return Reservation(
      id: dto.id,
      listing: ListingMapper.fromDto(dto.listing),
      quantity: dto.quantity,
      totalPrice: dto.totalPrice,
      status: ReservationStatus.fromString(dto.status),
      message: dto.message,
      preferredPickupTime: dto.preferredPickupTime,
      confirmedPickupTime: dto.confirmedPickupTime,
      createdAt: dto.createdAt,
      expiresAt: dto.expiresAt,
    );
  }
}

/// Active reservations provider
final activeReservationsProvider = Provider<List<Reservation>>((ref) {
  final reservations = ref.watch(reservationsProvider);
  return reservations.maybeWhen(
    data: (items) => items.where((r) => r.isActive).toList(),
    orElse: () => [],
  );
});

/// Pending reservations count
final pendingReservationsCountProvider = Provider<int>((ref) {
  final reservations = ref.watch(reservationsProvider);
  return reservations.maybeWhen(
    data: (items) => items.where((r) => r.status == ReservationStatus.pending).length,
    orElse: () => 0,
  );
});

/// Single reservation detail provider
final reservationDetailProvider = FutureProvider.family<Reservation, int>((ref, id) async {
  final apiClient = ref.watch(apiClientProvider);
  final dto = await apiClient.getReservation(id);
  return Reservation(
    id: dto.id,
    listing: ListingMapper.fromDto(dto.listing),
    quantity: dto.quantity,
    totalPrice: dto.totalPrice,
    status: ReservationStatus.fromString(dto.status),
    message: dto.message,
    preferredPickupTime: dto.preferredPickupTime,
    confirmedPickupTime: dto.confirmedPickupTime,
    createdAt: dto.createdAt,
    expiresAt: dto.expiresAt,
  );
});
