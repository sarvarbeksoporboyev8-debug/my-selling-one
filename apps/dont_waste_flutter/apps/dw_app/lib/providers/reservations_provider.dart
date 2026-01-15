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
    final now = DateTime.now();
    final listing = listingDto != null
        ? SurplusListing(
            id: listingDto.id,
            title: listingDto.title,
            quantityAvailable: 0,
            unit: listingDto.unit,
            basePrice: listingDto.basePrice,
            currentPrice: listingDto.currentPrice,
            currency: 'USD',
            expiresAt: listingDto.expiresAt,
            pickupStartAt: now,
            pickupEndAt: listingDto.expiresAt,
            status: listingDto.status,
            visibility: 'public',
            enterprise: EnterpriseSummary(
              id: 0,
              name: listingDto.enterpriseName ?? 'Unknown',
            ),
            variant: VariantSummary(
              id: 0,
              name: listingDto.variantName,
            ),
          )
        : SurplusListing(
            id: 0,
            title: 'Unknown',
            quantityAvailable: 0,
            unit: 'unit',
            basePrice: 0,
            currentPrice: 0,
            currency: 'USD',
            expiresAt: now,
            pickupStartAt: now,
            pickupEndAt: now,
            status: 'unknown',
            visibility: 'public',
            enterprise: const EnterpriseSummary(id: 0, name: 'Unknown'),
            variant: const VariantSummary(id: 0),
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

/// Single reservation detail provider
final reservationDetailProvider = Provider.family<AsyncValue<Reservation>, int>((ref, id) {
  final reservations = ref.watch(reservationsProvider);
  return reservations.whenData((items) {
    final reservation = items.where((r) => r.id == id).firstOrNull;
    if (reservation == null) {
      throw Exception('Reservation not found');
    }
    return reservation;
  });
});
