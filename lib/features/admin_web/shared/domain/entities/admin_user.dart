// lib/features/admin_web/shared/domain/entities/admin_user.dart

import 'package:equatable/equatable.dart';

enum AdminRole { superAdmin, admin }

enum AdminAccessLevel { full, readOnly, limited }

enum UserStatus { active, inactive, suspended, pending }

class AdminUser extends Equatable {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessLevel,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final AdminAccessLevel accessLevel;
  final UserStatus status;
  final DateTime? createdAt;

  @override
  List<Object?> get props =>
      [id, name, email, role, accessLevel, status, createdAt];
}

class PaginatedResult<T> extends Equatable {
  const PaginatedResult({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<T> data;
  final int page;
  final int pageSize;
  final int total;

  int get totalPages => (total / pageSize).ceil();
  bool get hasNextPage => page < totalPages;
  bool get hasPrevPage => page > 1;

  @override
  List<Object?> get props => [page, pageSize, total];
}
