import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const User._();

  const factory User({
    required int id,
    required String email,
    String? firstName,
    String? lastName,
    String? apiKey,
    DateTime? createdAt,
  }) = _User;

  /// Get full name
  String get fullName {
    final parts = <String>[];
    if (firstName != null) parts.add(firstName!);
    if (lastName != null) parts.add(lastName!);
    return parts.isEmpty ? email : parts.join(' ');
  }

  /// Get initials for avatar
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    if (firstName != null) {
      return firstName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
