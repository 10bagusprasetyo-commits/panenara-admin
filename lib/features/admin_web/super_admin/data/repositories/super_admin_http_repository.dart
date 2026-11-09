// lib/features/admin_web/super_admin/data/repositories/super_admin_http_repository.dart
// Real HTTP implementation connecting to Backend REST API.
// Follows OpenAPI contract defined in docs/backend/openapi.yaml.

import '../../../shared/data/api_client.dart';
import '../../../shared/domain/entities/admin_user.dart';
import '../../domain/entities/super_admin_entities.dart';
import '../../domain/repositories/super_admin_repository.dart';

class HttpSuperAdminRepository implements SuperAdminRepository {
  HttpSuperAdminRepository(this._client);
  final ApiClient _client;

  @override
  Future<SuperDashboardStats> getDashboard() async {
    final res = await _client.dio.get<Map<String, dynamic>>('/admin/dashboard/super');
    final d = res.data!['data'] as Map<String, dynamic>;

    final alerts = (d['alerts'] as List? ?? [])
        .map((a) => AlertItem(
              title: a['title'] ?? '',
              subtitle: a['subtitle'] ?? '',
              pillLabel: a['pill_label'] ?? '',
              pillVariant: a['pill_variant'] ?? 'mt',
            ))
        .toList();

    final activities = (d['recent_activities'] as List? ?? [])
        .map((a) => ActivityItem(
              title: a['title'] ?? '',
              subtitle: a['subtitle'] ?? '',
            ))
        .toList();

    return SuperDashboardStats(
      totalUsers: d['total_users'] ?? 0,
      activeAdmins: d['active_admins'] ?? 0,
      monthlyTransactionValue: d['monthly_transaction_value'] ?? 'Rp 0',
      activeAuctions: d['active_auctions'] ?? 0,
      alerts: alerts,
      recentActivities: activities,
    );
  }
}

class HttpAdminManagementRepository implements AdminManagementRepository {
  HttpAdminManagementRepository(this._client);
  final ApiClient _client;

  @override
  Future<PaginatedResult<AdminAccount>> getAdmins({
    int page = 1,
    int pageSize = 20,
    String? q,
  }) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (q != null && q.isNotEmpty) qp['q'] = q;

    final res = await _client.dio.get<Map<String, dynamic>>(
      '/admin/admins',
      queryParameters: qp,
    );

    final list = (res.data!['data'] as List)
        .map((d) => _parseAdmin(d as Map<String, dynamic>))
        .toList();
    final meta = res.data!['meta'] as Map<String, dynamic>? ?? {};

    return PaginatedResult(
      data: list,
      page: meta['page'] ?? page,
      pageSize: meta['pageSize'] ?? pageSize,
      total: meta['total'] ?? list.length,
    );
  }

  @override
  Future<AdminAccount> createAdmin({
    required String name,
    required String email,
    required AdminRole role,
    required String accessLevel,
    required String password,
  }) async {
    final res = await _client.dio.post<Map<String, dynamic>>(
      '/admin/admins',
      data: {
        'name': name,
        'email': email,
        'role': role == AdminRole.superAdmin ? 'super_admin' : 'admin',
        'access_level': accessLevel,
        'password': password,
      },
    );
    return _parseAdmin(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<AdminAccount> updateAdmin({
    required String id,
    String? name,
    String? accessLevel,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (accessLevel != null) body['access_level'] = accessLevel;

    final res = await _client.dio.patch<Map<String, dynamic>>(
      '/admin/admins/$id',
      data: body,
    );
    return _parseAdmin(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<AdminAccount> setAdminStatus({
    required String id,
    required UserStatus status,
  }) async {
    final res = await _client.dio.patch<Map<String, dynamic>>(
      '/admin/admins/$id/status',
      data: {'status': status.name},
    );
    return _parseAdmin(res.data!['data'] as Map<String, dynamic>);
  }

  AdminAccount _parseAdmin(Map<String, dynamic> d) {
    return AdminAccount(
      id: d['id'] as String,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      role: (d['role'] as String?)?.toLowerCase() == 'super_admin'
          ? AdminRole.superAdmin
          : AdminRole.admin,
      access: d['access_level'] ?? d['access'] ?? 'limited',
      status: (d['status'] as String?)?.toLowerCase() == 'suspended'
          ? UserStatus.suspended
          : UserStatus.active,
    );
  }
}

class HttpSuperUserRepository implements SuperUserRepository {
  HttpSuperUserRepository(this._client);
  final ApiClient _client;

  @override
  Future<PaginatedResult<AppUser>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? q,
    UserRole? role,
    UserStatus? status,
  }) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (q != null && q.isNotEmpty) qp['q'] = q;
    if (role != null) qp['role'] = role.name;
    if (status != null) qp['status'] = status.name;

    final res = await _client.dio.get<Map<String, dynamic>>(
      '/admin/users',
      queryParameters: qp,
    );

    final list = (res.data!['data'] as List)
        .map((d) => _parseUser(d as Map<String, dynamic>))
        .toList();
    final meta = res.data!['meta'] as Map<String, dynamic>? ?? {};

    return PaginatedResult(
      data: list,
      page: meta['page'] ?? page,
      pageSize: meta['pageSize'] ?? pageSize,
      total: meta['total'] ?? list.length,
    );
  }

  @override
  Future<AppUser> getUserDetail(String id) async {
    final res = await _client.dio.get<Map<String, dynamic>>('/admin/users/$id');
    return _parseUser(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<AppUser> setUserStatus({
    required String id,
    required UserStatus status,
  }) async {
    final res = await _client.dio.patch<Map<String, dynamic>>(
      '/admin/users/$id/status',
      data: {'status': status.name},
    );
    return _parseUser(res.data!['data'] as Map<String, dynamic>);
  }

  AppUser _parseUser(Map<String, dynamic> d) {
    return AppUser(
      id: d['id'] as String,
      name: d['name'] ?? '',
      role: _parseRole(d['role'] as String?),
      region: d['region'] ?? d['location'] ?? '',
      joinedAt: d['joined_at'] ?? d['registered_at'] ?? '',
      status: (d['status'] as String?)?.toLowerCase() == 'suspended'
          ? UserStatus.suspended
          : UserStatus.active,
      verificationStatus: d['verification_status'] ?? d['verificationStatus'],
    );
  }

  UserRole _parseRole(String? r) {
    return switch (r?.toLowerCase()) {
      'petani' => UserRole.petani,
      'pembeli' => UserRole.pembeli,
      _ => UserRole.pengamat,
    };
  }
}

class HttpReportRepository implements ReportRepository {
  HttpReportRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<MonthlyVolume>> getMonthlyVolume() async {
    final res = await _client.dio.get<Map<String, dynamic>>('/admin/reports/monthly-volume');
    return (res.data!['data'] as List)
        .map((x) => MonthlyVolume(
              month: x['month'] ?? '',
              valueMillions: (x['value_millions'] ?? x['valueMillions'] ?? 0).toDouble(),
            ))
        .toList();
  }

  @override
  Future<List<TopCommodity>> getTopCommodities() async {
    final res = await _client.dio.get<Map<String, dynamic>>('/admin/reports/top-commodities');
    return (res.data!['data'] as List)
        .map((x) => TopCommodity(
              name: x['name'] ?? x['commodity'] ?? '',
              volume: x['volume'] ?? '',
              value: x['value'] ?? '',
              growth: x['growth'] ?? '0%',
              growthPositive: x['growth_positive'] ?? x['growthPositive'] ?? true,
            ))
        .toList();
  }
}

class HttpSettingsRepository implements SettingsRepository {
  HttpSettingsRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<SystemSetting>> getSettings() async {
    final res = await _client.dio.get<Map<String, dynamic>>('/admin/settings');
    return (res.data!['data'] as List)
        .map((x) => SystemSetting(
              key: x['key'] ?? '',
              label: x['label'] ?? '',
              description: x['description'] ?? '',
              value: x['value'],
            ))
        .toList();
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> values) async {
    await _client.dio.put<Map<String, dynamic>>(
      '/admin/settings',
      data: {'settings': values},
    );
  }
}

class HttpAuditLogRepository implements AuditLogRepository {
  HttpAuditLogRepository(this._client);
  final ApiClient _client;

  @override
  Future<PaginatedResult<AuditLog>> getLogs({
    int page = 1,
    int pageSize = 20,
    String? module,
    String? q,
  }) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (module != null && module.isNotEmpty) qp['module'] = module;
    if (q != null && q.isNotEmpty) qp['q'] = q;

    final res = await _client.dio.get<Map<String, dynamic>>(
      '/admin/audit-logs',
      queryParameters: qp,
    );

    final list = (res.data!['data'] as List)
        .map((d) => AuditLog(
              id: d['id'] as String,
              actor: d['actor'] ?? '',
              action: d['action'] ?? '',
              module: d['module'] ?? '',
              ip: d['ip'] ?? d['ip_address'] ?? '',
              timestamp: d['timestamp'] ?? d['created_at'] ?? '',
            ))
        .toList();
    final meta = res.data!['meta'] as Map<String, dynamic>? ?? {};

    return PaginatedResult(
      data: list,
      page: meta['page'] ?? page,
      pageSize: meta['pageSize'] ?? pageSize,
      total: meta['total'] ?? list.length,
    );
  }
}
