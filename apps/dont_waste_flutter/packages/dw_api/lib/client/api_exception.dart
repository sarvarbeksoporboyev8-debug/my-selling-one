import 'package:dio/dio.dart';

/// Base API exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;

    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.connectionError:
        message = 'Unable to connect to server. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        message = _parseErrorMessage(response?.data) ?? 
                  'Server error (${statusCode ?? 'unknown'})';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      default:
        message = e.message ?? 'An unexpected error occurred';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: response?.data,
    );
  }

  static String? _parseErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      return data['error'] as String? ??
             data['message'] as String? ??
             (data['errors'] as List?)?.join(', ');
    }
    return null;
  }

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// Authentication exception
class AuthException extends ApiException {
  const AuthException({required super.message, super.statusCode});

  factory AuthException.invalidCredentials() {
    return const AuthException(
      message: 'Invalid email or password',
      statusCode: 401,
    );
  }

  factory AuthException.tokenExpired() {
    return const AuthException(
      message: 'Your session has expired. Please log in again.',
      statusCode: 401,
    );
  }

  factory AuthException.unauthorized() {
    return const AuthException(
      message: 'You are not authorized to perform this action',
      statusCode: 403,
    );
  }
}

/// Not found exception
class NotFoundException extends ApiException {
  const NotFoundException({required super.message})
      : super(statusCode: 404);
}

/// Validation exception
class ValidationException extends ApiException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
  }) : super(statusCode: 422);

  factory ValidationException.fromResponse(dynamic data) {
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map) {
        final fieldErrors = errors.map<String, List<String>>(
          (key, value) => MapEntry(
            key.toString(),
            (value as List).map((e) => e.toString()).toList(),
          ),
        );
        return ValidationException(
          message: fieldErrors.values.expand((e) => e).join(', '),
          fieldErrors: fieldErrors,
        );
      }
    }
    return ValidationException(
      message: data?['error']?.toString() ?? 'Validation failed',
    );
  }
}

/// Conflict exception (e.g., out of stock)
class ConflictException extends ApiException {
  const ConflictException({required super.message})
      : super(statusCode: 409);
}
