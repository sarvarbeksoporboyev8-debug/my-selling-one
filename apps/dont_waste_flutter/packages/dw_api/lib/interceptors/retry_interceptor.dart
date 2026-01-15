import 'dart:async';
import 'package:dio/dio.dart';

/// Interceptor that retries failed requests with exponential backoff
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;
  final Set<int> retryStatusCodes;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.retryStatusCodes = const {502, 503, 504},
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // Check if we should retry
    final shouldRetry = _shouldRetry(err, statusCode, retryCount);

    if (shouldRetry) {
      // Calculate delay with exponential backoff
      final delay = initialDelay * (1 << retryCount);
      
      await Future.delayed(delay);

      // Update retry count
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // If retry fails, continue with error handling
        if (e is DioException) {
          return handler.next(e);
        }
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err, int? statusCode, int retryCount) {
    // Don't retry if max retries reached
    if (retryCount >= maxRetries) return false;

    // Retry on timeout errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }

    // Retry on specific status codes (server errors)
    if (statusCode != null && retryStatusCodes.contains(statusCode)) {
      return true;
    }

    // Retry on connection errors
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    return false;
  }
}
