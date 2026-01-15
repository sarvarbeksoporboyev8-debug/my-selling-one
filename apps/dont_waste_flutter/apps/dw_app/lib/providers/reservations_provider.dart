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
      final reservations = await _apiClient.getMyReservations();
      state = AsyncValue.data(reservations.map(_mapReservation).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Reservation> createReservation({
    required int listingId,
    required double quantity,
    String? notes,
  }) async {
    final dto = await _apiClient.reserveListing(listingId, quantity);

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

  Reservation _mapReservation(ReservationDto dto) {
    // Create a minimal listing from the compact DTO if available
    final listingDto = dto.listing;
    final listing = listingDto != null
        ? SurplusListing(
            id: listingDto.id,
            title: listingDto.title ?? 'Unknown',
            price: listingDto.currentPrice,
            quantity: 0,
            unit: listingDto.unit,
            expiresAt: listingDto.expiresAt,
            status: listingDto.status,
            enterpriseName: listingDto.enterpriseName,
          )
        : SurplusListing(
            id: 0,
            title: 'Unknown',
            price: 0,
            quantity: 0,
            unit: 'unit',
            expiresAt: DateTime.now(),
            status: 'unknown',
          );

    return Reservation(
      id: dto.id,
      listing: listing,
      quantity: dto.quantity,
      totalPrice: dto.totalPrice ?? (dto.quantity * dto.priceAtReservation),
      status: ReservationStatus.fromString(dto.status),
      message: dto.notes,
      createdAt: dto.createdAt ?? DateTime.now(),
      expiresAt: dto.reservedUntil,
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
