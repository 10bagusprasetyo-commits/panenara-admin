// lib/features/admin_web/super_admin/domain/repositories/super_admin_repository.dart

import '../../../shared/domain/entities/admin_user.dart';
import '../entities/super_admin_entities.dart';

abstract class SuperAdminRepository {
  Future<SuperDashboardStats> getDashboard();
}

abstract class AdminManagementRepository {
  Future<PaginatedResult<AdminAccount>> getAdmins({
    int page = 1,
    int pageSize = 20,
    String? q,
  });

  Future<AdminAccount> createAdmin({
    required String name,
    required String email,
    required AdminRole role,
    required String accessLevel,
    required String password,
  });

  Future<AdminAccount> updateAdmin({
    required String id,
    String? name,
    String? accessLevel,
  });

  Future<AdminAccount> setAdminStatus({
    required String id,
    required UserStatus status,
  });
}

abstract class SuperUserRepository {
  Future<PaginatedResult<AppUser>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? q,
    UserRole? role,
    UserStatus? status,
  });

  Future<AppUser> getUserDetail(String id);

  Future<AppUser> setUserStatus({
    required String id,
    required UserStatus status,
  });
}

abstract class ReportRepository {
  Future<List<MonthlyVolume>> getMonthlyVolume();
  Future<List<TopCommodity>> getTopCommodities();
}

abstract class SettingsRepository {
  Future<List<SystemSetting>> getSettings();
  Future<void> updateSettings(Map<String, dynamic> values);
}

abstract class AuditLogRepository {
  Future<PaginatedResult<AuditLog>> getLogs({
    int page = 1,
    int pageSize = 20,
    String? q,
    String? module,
  });
}
