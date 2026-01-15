import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_api/dw_api.dart';
import 'package:dw_domain/dw_domain.dart';

import 'api_provider.dart';

/// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthNotifier(apiClient);
});

/// Auth notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient) : super(const AsyncValue.data(null)) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final isAuth = await _apiClient.isAuthenticated();
      if (isAuth) {
        final userDto = await _apiClient.getCurrentUser();
        state = AsyncValue.data(UserMapper.fromDto(userDto));
      }
    } catch (e) {
      // Not authenticated
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiClient.login(email, password);
      state = AsyncValue.data(UserMapper.fromDto(response.user));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> setToken(String token) async {
    state = const AsyncValue.loading();
    try {
      await _apiClient.setToken(token);
      final userDto = await _apiClient.getCurrentUser();
      state = AsyncValue.data(UserMapper.fromDto(userDto));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiClient.logout();
    state = const AsyncValue.data(null);
  }
}

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
