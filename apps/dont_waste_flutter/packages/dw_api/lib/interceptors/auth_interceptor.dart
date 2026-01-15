import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interceptor that adds authentication token to requests
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'api_token';

  AuthInterceptor({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['X-Spree-Token'] = token;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 errors - token might be invalid
    if (err.response?.statusCode == 401) {
      // Clear invalid token
      clearToken();
    }
    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    final publicPaths = [
      '/api/v0/auth/login',
      '/api/v0/surplus_listings', // GET is public
    ];
    return publicPaths.any((p) => path.startsWith(p));
  }

  /// Get stored token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Store token
  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Clear token
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
