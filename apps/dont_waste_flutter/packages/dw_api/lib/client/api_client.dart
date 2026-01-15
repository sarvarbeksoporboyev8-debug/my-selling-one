import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_config.dart';
import 'api_exception.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/retry_interceptor.dart';
import '../dto/surplus_listing_dto.dart';
import '../dto/reservation_dto.dart';
import '../dto/offer_dto.dart';
import '../dto/watch_dto.dart';
import '../dto/auth_dto.dart';
import '../dto/pagination_dto.dart';

/// Main API client for DontWaste backend
class ApiClient {
  final Dio _dio;
  final AuthInterceptor _authInterceptor;

  ApiClient._({
    required Dio dio,
    required AuthInterceptor authInterceptor,
  })  : _dio = dio,
        _authInterceptor = authInterceptor;

  factory ApiClient({
    required ApiConfig config,
    AuthInterceptor? authInterceptor,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    final auth = authInterceptor ?? AuthInterceptor();

    // Add interceptors
    dio.interceptors.add(auth);
    dio.interceptors.add(RetryInterceptor(dio: dio));

    if (config.enableLogging) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ));
    }

    return ApiClient._(dio: dio, authInterceptor: auth);
  }

  AuthInterceptor get authInterceptor => _authInterceptor;

  // ============ AUTH ============

  /// Login with email and password
  Future<AuthResponseDto> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/v0/auth/login',
        data: {'email': email, 'password': password},
      );
      final authResponse = AuthResponseDto.fromJson(response.data);
      await _authInterceptor.setToken(authResponse.token);
      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException.invalidCredentials();
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// Set token directly (developer mode)
  Future<void> setToken(String token) async {
    await _authInterceptor.setToken(token);
  }

  /// Logout
  Future<void> logout() async {
    await _authInterceptor.clearToken();
  }

  /// Check if authenticated
  Future<bool> isAuthenticated() async {
    return await _authInterceptor.hasToken();
  }

  /// Get current user
  Future<UserDto> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/v0/users/current');
      return UserDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============ SURPLUS LISTINGS ============

  /// Search surplus listings
  Future<PaginatedResponse<SurplusListingDto>> searchListings({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? query,
    List<int>? taxonIds,
    double? minPrice,
    double? maxPrice,
    double? minQuantity,
    double? maxQuantity,
    int? expiresWithinHours,
    DateTime? pickupStartAfter,
    DateTime? pickupEndBefore,
    String? sort,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radiusKm != null) 'radius_km': radiusKm,
        if (query != null && query.isNotEmpty) 'query': query,
        if (taxonIds != null && taxonIds.isNotEmpty) 'taxon_ids': taxonIds,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (minQuantity != null) 'min_quantity': minQuantity,
        if (maxQuantity != null) 'max_quantity': maxQuantity,
        if (expiresWithinHours != null) 'expires_within_hours': expiresWithinHours,
        if (pickupStartAfter != null) 'pickup_start_after': pickupStartAfter.toIso8601String(),
        if (pickupEndBefore != null) 'pickup_end_before': pickupEndBefore.toIso8601String(),
        if (sort != null) 'sort': sort,
        'page': page,
        'per_page': perPage,
      };

      final response = await _dio.get(
        '/api/v0/surplus_listings',
        queryParameters: queryParams,
      );

      final listings = (response.data['surplus_listings'] as List)
          .map((json) => SurplusListingDto.fromJson(json))
          .toList();

      final pagination = response.data['pagination'] != null
          ? PaginationDto.fromJson(response.data['pagination'])
          : null;

      return PaginatedResponse(
        items: listings,
        pagination: pagination,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get listing by ID
  Future<SurplusListingDto> getListing(int id) async {
    try {
      final response = await _dio.get('/api/v0/surplus_listings/$id');
      return SurplusListingDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException(message: 'Listing not found');
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// Reserve quantity from listing
  Future<ReservationDto> reserveListing(int listingId, double quantity) async {
    try {
      final response = await _dio.post(
        '/api/v0/surplus_listings/$listingId/reserve',
        data: {'quantity': quantity},
      );
      return ReservationDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw ValidationException.fromResponse(e.response?.data);
      }
      if (e.response?.statusCode == 409) {
        throw ConflictException(
          message: e.response?.data?['error'] ?? 'Item no longer available',
        );
      }
      throw ApiException.fromDioException(e);
    }
  }

  // ============ OFFERS ============

  /// Create offer for listing
  Future<OfferDto> createOffer({
    required int listingId,
    required double quantity,
    required double pricePerUnit,
    String? message,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v0/surplus_listings/$listingId/offers',
        data: {
          'surplus_offer': {
            'offered_quantity': quantity,
            'offered_price_per_unit': pricePerUnit,
            if (message != null) 'message': message,
          },
        },
      );
      return OfferDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw ValidationException.fromResponse(e.response?.data);
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// Get offers for listing
  Future<List<OfferDto>> getListingOffers(int listingId) async {
    try {
      final response = await _dio.get(
        '/api/v0/surplus_listings/$listingId/offers',
      );
      return (response.data['surplus_offers'] as List)
          .map((json) => OfferDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============ RESERVATIONS ============

  /// Get my reservations
  Future<List<ReservationDto>> getMyReservations({String? status}) async {
    try {
      final response = await _dio.get(
        '/api/v0/surplus_reservations',
        queryParameters: {
          if (status != null) 'status': status,
        },
      );
      return (response.data['surplus_reservations'] as List)
          .map((json) => ReservationDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Cancel reservation
  Future<ReservationDto> cancelReservation(int reservationId) async {
    try {
      final response = await _dio.post(
        '/api/v0/surplus_reservations/$reservationId/cancel',
      );
      return ReservationDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============ WATCHES ============

  /// Get my watches
  Future<List<WatchDto>> getMyWatches() async {
    try {
      final response = await _dio.get('/api/v0/buyer_watches');
      return (response.data['buyer_watches'] as List)
          .map((json) => WatchDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create watch
  Future<WatchDto> createWatch(CreateWatchDto watch) async {
    try {
      final response = await _dio.post(
        '/api/v0/buyer_watches',
        data: {'buyer_watch': watch.toJson()},
      );
      return WatchDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw ValidationException.fromResponse(e.response?.data);
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// Update watch
  Future<WatchDto> updateWatch(int watchId, CreateWatchDto watch) async {
    try {
      final response = await _dio.patch(
        '/api/v0/buyer_watches/$watchId',
        data: {'buyer_watch': watch.toJson()},
      );
      return WatchDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Delete watch
  Future<void> deleteWatch(int watchId) async {
    try {
      await _dio.delete('/api/v0/buyer_watches/$watchId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============ TAXONS ============

  /// Get taxons (categories)
  Future<List<TaxonDto>> getTaxons() async {
    try {
      final response = await _dio.get('/api/v0/taxons');
      return (response.data['taxons'] as List? ?? [])
          .map((json) => TaxonDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
