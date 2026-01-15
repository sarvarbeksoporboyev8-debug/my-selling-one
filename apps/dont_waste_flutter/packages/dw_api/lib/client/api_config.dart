/// API configuration
class ApiConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;

  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableLogging = false,
  });

  /// Create config from environment
  factory ApiConfig.fromEnvironment() {
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000',
    );
    const enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: false);

    return ApiConfig(
      baseUrl: baseUrl,
      enableLogging: enableLogging,
    );
  }

  /// Development config
  factory ApiConfig.development() {
    return const ApiConfig(
      baseUrl: 'http://localhost:3000',
      enableLogging: true,
    );
  }

  /// Production config
  factory ApiConfig.production() {
    return const ApiConfig(
      baseUrl: 'https://api.openfoodnetwork.org',
      enableLogging: false,
    );
  }
}
