import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_api/dw_api.dart';

/// Provider for API client
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ApiConfig.fromEnvironment();
  return ApiClient(config: config);
});

/// Provider for API config
final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig.fromEnvironment();
});
