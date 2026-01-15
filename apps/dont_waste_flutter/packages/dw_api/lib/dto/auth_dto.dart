class AuthResponseDto {
  final String token;
  final UserDto user;

  const AuthResponseDto({
    required this.token,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      token: json['token'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'user': user.toJson(),
  };
}

class UserDto {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? spreeApiKey;
  final DateTime? createdAt;

  const UserDto({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.spreeApiKey,
    this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      spreeApiKey: json['spree_api_key'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'spree_api_key': spreeApiKey,
    'created_at': createdAt?.toIso8601String(),
  };
}

class LoginRequestDto {
  final String email;
  final String password;

  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) {
    return LoginRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}
