// lib/features/admin_web/shared/domain/entities/auth_entity.dart

import 'package:equatable/equatable.dart';

enum AppRole {
  superAdmin,
  admin,
  petani,
  pembeli,
  pengamat;

  static AppRole fromString(String value) {
    return switch (value) {
      'super_admin' => AppRole.superAdmin,
      'admin' => AppRole.admin,
      'petani' => AppRole.petani,
      'pembeli' => AppRole.pembeli,
      'pengamat' => AppRole.pengamat,
      _ => throw ArgumentError('Unknown role: $value'),
    };
  }

  bool get isAdminPanel =>
      this == AppRole.superAdmin || this == AppRole.admin;

  String get label => switch (this) {
        AppRole.superAdmin => 'Super Admin',
        AppRole.admin => 'Admin',
        AppRole.petani => 'Petani',
        AppRole.pembeli => 'Pembeli',
        AppRole.pengamat => 'Pengamat',
      };
}

class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}

class CurrentUser extends Equatable {
  const CurrentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final AppRole role;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, email, role];
}
