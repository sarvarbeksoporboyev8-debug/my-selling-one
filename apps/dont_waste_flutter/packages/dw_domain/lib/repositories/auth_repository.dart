import '../entities/user.dart';

/// Repository interface for authentication
abstract class AuthRepository {
  /// Login with email and password
  Future<User> login(String email, String password);

  /// Set token directly (developer mode)
  Future<void> setToken(String token);

  /// Logout
  Future<void> logout();

  /// Check if authenticated
  Future<bool> isAuthenticated();

  /// Get current user
  Future<User?> getCurrentUser();
}
