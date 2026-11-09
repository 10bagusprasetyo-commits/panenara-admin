// lib/features/admin_web/super_admin/data/repositories/super_admin_mock_repository.dart
// Mock data sesuai HTML desain Panel Super Admin

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/api_client.dart';
import '../../../shared/domain/entities/admin_user.dart';
import '../../domain/entities/super_admin_entities.dart';
import '../../domain/repositories/super_admin_repository.dart';
import '../../../../../../../app_config.dart';
import 'super_admin_http_repository.dart';

// ─── Mock Super Dashboard ─────────────────────────────────────────────────────

class MockSuperAdminRepository implements SuperAdminRepository {
  @override
  Future<SuperDashboardStats> getDashboard() async {
    await _delay();
    return const SuperDashboardStats(
      totalUsers: 12480,
      activeAdmins: 8,
      monthlyTransactionValue: 'Rp 4,82 M',
      activeAuctions: 146,
      alerts: [
        AlertItem(
          title: 'Permintaan ubah peran: Rizky A.',
          subtitle: 'Menunggu persetujuan Super Admin',
          pillLabel: 'Baru',
          pillVariant: 'wn',
        ),
        AlertItem(
          title: 'Percobaan masuk gagal berulang',
          subtitle: 'IP 103.28.x.x · 14 menit lalu',
          pillLabel: 'Cek',
          pillVariant: 'bd',
        ),
        AlertItem(
          title: 'Pencadangan data harian selesai',
          subtitle: 'Hari ini 02.00 WIB',
          pillLabel: 'Aman',
          pillVariant: 'ok',
        ),
      ],
      recentActivities: [
        ActivityItem(
          title: 'Rina W. memverifikasi 5 petani',
          subtitle: 'Admin · 09.12 WIB',
        ),
        ActivityItem(
          title: 'Bagas P. mengubah biaya layanan',
          subtitle: 'Super Admin · 08.40 WIB',
        ),
        ActivityItem(
          title: 'Dimas S. menonaktifkan akun pembeli',
          subtitle: 'Admin · Kemarin',
        ),
      ],
    );
  }
}

// ─── Mock Admin Management ────────────────────────────────────────────────────

class MockAdminManagementRepository implements AdminManagementRepository {
  final _admins = <AdminAccount>[
    const AdminAccount(
      id: 'sa-001',
      name: 'Bagas Pratama',
      email: 'bagas@panenara.id',
      role: AdminRole.superAdmin,
      access: 'Akses penuh',
      status: UserStatus.active,
    ),
    const AdminAccount(
      id: 'sa-002',
      name: 'Maya Lestari',
      email: 'maya@panenara.id',
      role: AdminRole.superAdmin,
      access: 'Hanya baca',
      status: UserStatus.active,
    ),
    const AdminAccount(
      id: 'ad-001',
      name: 'Rina Wulandari',
      email: 'rina@panenara.id',
      role: AdminRole.admin,
      access: 'Verifikasi & pengaduan',
      status: UserStatus.active,
    ),
    const AdminAccount(
      id: 'ad-002',
      name: 'Dimas Saputra',
      email: 'dimas@panenara.id',
      role: AdminRole.admin,
      access: 'Transaksi & lelang',
      status: UserStatus.active,
    ),
    const AdminAccount(
      id: 'ad-003',
      name: 'Fajar Nugroho',
      email: 'fajar@panenara.id',
      role: AdminRole.admin,
      access: 'Terbatas',
      status: UserStatus.inactive,
    ),
  ];

  @override
  Future<PaginatedResult<AdminAccount>> getAdmins({
    int page = 1,
    int pageSize = 20,
    String? q,
  }) async {
    await _delay();
    final filtered = q == null || q.isEmpty
        ? _admins
        : _admins
            .where((a) =>
                a.name.toLowerCase().contains(q.toLowerCase()) ||
                a.email.toLowerCase().contains(q.toLowerCase()))
            .toList();
    return PaginatedResult(
      data: filtered,
      page: page,
      pageSize: pageSize,
      total: filtered.length,
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
    await _delay();
    final newAdmin = AdminAccount(
      id: 'ad-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      access: accessLevel,
      status: UserStatus.active,
    );
    _admins.add(newAdmin);
    return newAdmin;
  }

  @override
  Future<AdminAccount> updateAdmin({
    required String id,
    String? name,
    String? accessLevel,
  }) async {
    await _delay();
    final idx = _admins.indexWhere((a) => a.id == id);
    if (idx < 0) throw Exception('Admin tidak ditemukan');
    final updated = AdminAccount(
      id: id,
      name: name ?? _admins[idx].name,
      email: _admins[idx].email,
      role: _admins[idx].role,
      access: accessLevel ?? _admins[idx].access,
      status: _admins[idx].status,
    );
    _admins[idx] = updated;
    return updated;
  }

  @override
  Future<AdminAccount> setAdminStatus({
    required String id,
    required UserStatus status,
  }) async {
    await _delay();
    final idx = _admins.indexWhere((a) => a.id == id);
    if (idx < 0) throw Exception('Admin tidak ditemukan');
    final updated = AdminAccount(
      id: id,
      name: _admins[idx].name,
      email: _admins[idx].email,
      role: _admins[idx].role,
      access: _admins[idx].access,
      status: status,
    );
    _admins[idx] = updated;
    return updated;
  }
}

// ─── Mock Users ───────────────────────────────────────────────────────────────

class MockSuperUserRepository implements SuperUserRepository {
  final _users = <AppUser>[
    const AppUser(
      id: 'u-001',
      name: 'Sari Dewi',
      role: UserRole.petani,
      region: 'Magelang, Jateng',
      joinedAt: '12 Okt 2026',
      status: UserStatus.active,
      verificationStatus: 'Terverifikasi',
    ),
    const AppUser(
      id: 'u-002',
      name: 'PT Segar Nusantara',
      role: UserRole.pembeli,
      region: 'Bekasi, Jabar',
      joinedAt: '3 Okt 2026',
      status: UserStatus.active,
      verificationStatus: 'Terverifikasi',
    ),
    const AppUser(
      id: 'u-003',
      name: 'Budi Hartono',
      role: UserRole.petani,
      region: 'Garut, Jabar',
      joinedAt: '28 Sep 2026',
      status: UserStatus.pending,
      verificationStatus: 'Menunggu',
    ),
    const AppUser(
      id: 'u-004',
      name: 'Anisa Putri',
      role: UserRole.pengamat,
      region: 'Sleman, DIY',
      joinedAt: '21 Sep 2026',
      status: UserStatus.active,
      verificationStatus: 'Aktif',
    ),
    const AppUser(
      id: 'u-005',
      name: 'CV Tani Makmur',
      role: UserRole.pembeli,
      region: 'Surabaya, Jatim',
      joinedAt: '15 Sep 2026',
      status: UserStatus.suspended,
      verificationStatus: 'Ditangguhkan',
    ),
    const AppUser(
      id: 'u-006',
      name: 'Wayan Sudarma',
      role: UserRole.petani,
      region: 'Tabanan, Bali',
      joinedAt: '9 Sep 2026',
      status: UserStatus.active,
      verificationStatus: 'Terverifikasi',
    ),
  ];

  @override
  Future<PaginatedResult<AppUser>> getUsers({
    int page = 1,
    int pageSize = 20,
    String? q,
    UserRole? role,
    UserStatus? status,
  }) async {
    await _delay();
    var filtered = _users.where((u) {
      if (role != null && u.role != role) return false;
      if (status != null && u.status != status) return false;
      if (q != null && q.isNotEmpty) {
        final qLow = q.toLowerCase();
        return u.name.toLowerCase().contains(qLow) ||
            u.region.toLowerCase().contains(qLow);
      }
      return true;
    }).toList();
    return PaginatedResult(
      data: filtered,
      page: page,
      pageSize: pageSize,
      total: filtered.length,
    );
  }

  @override
  Future<AppUser> getUserDetail(String id) async {
    await _delay();
    return _users.firstWhere((u) => u.id == id,
        orElse: () => throw Exception('Pengguna tidak ditemukan'));
  }

  @override
  Future<AppUser> setUserStatus({
    required String id,
    required UserStatus status,
  }) async {
    await _delay();
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx < 0) throw Exception('Pengguna tidak ditemukan');
    final updated = AppUser(
      id: id,
      name: _users[idx].name,
      role: _users[idx].role,
      region: _users[idx].region,
      joinedAt: _users[idx].joinedAt,
      status: status,
      verificationStatus: _users[idx].verificationStatus,
    );
    _users[idx] = updated;
    return updated;
  }
}

// ─── Mock Reports ─────────────────────────────────────────────────────────────

class MockReportRepository implements ReportRepository {
  @override
  Future<List<MonthlyVolume>> getMonthlyVolume() async {
    await _delay();
    return const [
      MonthlyVolume(month: 'Mei', valueMillions: 2100),
      MonthlyVolume(month: 'Jun', valueMillions: 2600),
      MonthlyVolume(month: 'Jul', valueMillions: 3050),
      MonthlyVolume(month: 'Agu', valueMillions: 3400),
      MonthlyVolume(month: 'Sep', valueMillions: 4100),
      MonthlyVolume(month: 'Okt', valueMillions: 4820),
    ];
  }

  @override
  Future<List<TopCommodity>> getTopCommodities() async {
    await _delay();
    return const [
      TopCommodity(
        name: 'Cabai merah keriting',
        volume: '182 ton',
        value: 'Rp 1,41 M',
        growth: '+12%',
        growthPositive: true,
      ),
      TopCommodity(
        name: 'Bawang merah',
        volume: '240 ton',
        value: 'Rp 1,12 M',
        growth: '+8%',
        growthPositive: true,
      ),
      TopCommodity(
        name: 'Padi Inpari 32',
        volume: '610 ton',
        value: 'Rp 0,98 M',
        growth: '+3%',
        growthPositive: true,
      ),
      TopCommodity(
        name: 'Jagung pipil',
        volume: '420 ton',
        value: 'Rp 0,71 M',
        growth: '-2%',
        growthPositive: false,
      ),
      TopCommodity(
        name: 'Tomat',
        volume: '96 ton',
        value: 'Rp 0,34 M',
        growth: '+5%',
        growthPositive: true,
      ),
    ];
  }
}

// ─── Mock Settings ────────────────────────────────────────────────────────────

class MockSettingsRepository implements SettingsRepository {
  final _settings = [
    const SystemSetting(
      key: '2fa_admin',
      label: 'Verifikasi dua langkah wajib untuk admin',
      description: 'Berlaku untuk seluruh akun Admin dan Super Admin',
      value: true,
    ),
    const SystemSetting(
      key: 'ai_grading',
      label: 'Penilaian kualitas AI otomatis',
      description:
          'Grade komoditas dinilai AI saat petani mengunggah foto panen',
      value: true,
    ),
    const SystemSetting(
      key: 'email_winner',
      label: 'Notifikasi email pemenang lelang',
      description: 'Kirim ke pembeli saat penawaran tertinggi terpilih',
      value: true,
    ),
    const SystemSetting(
      key: 'maintenance',
      label: 'Mode pemeliharaan',
      description: 'Tampilkan halaman pemeliharaan ke semua pengguna',
      value: false,
    ),
    const SystemSetting(
      key: 'auction_fee',
      label: 'Biaya layanan lelang',
      description: '',
      value: '2,5%',
    ),
    const SystemSetting(
      key: 'auction_duration',
      label: 'Durasi lelang maksimal',
      description: '',
      value: '7 hari',
    ),
    const SystemSetting(
      key: 'min_bid_increment',
      label: 'Kenaikan penawaran minimum',
      description: '',
      value: 'Rp 500 / kg',
    ),
    const SystemSetting(
      key: 'payment_deadline',
      label: 'Batas waktu pembayaran pemenang',
      description: '',
      value: '24 jam',
    ),
  ];


  @override
  Future<List<SystemSetting>> getSettings() async {
    await _delay();
    return List.unmodifiable(_settings);
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> values) async {
    await _delay();
    for (var i = 0; i < _settings.length; i++) {
      if (values.containsKey(_settings[i].key)) {
        _settings[i] = SystemSetting(
          key: _settings[i].key,
          label: _settings[i].label,
          description: _settings[i].description,
          value: values[_settings[i].key],
        );
      }
    }
  }
}

// ─── Mock Audit Log ───────────────────────────────────────────────────────────

class MockAuditLogRepository implements AuditLogRepository {
  final _logs = const [
    AuditLog(
      id: 'log-001',
      actor: 'Rina Wulandari',
      action: 'Menyetujui verifikasi petani',
      module: 'Verifikasi',
      ip: '103.28.14.7',
      timestamp: '8 Nov · 09.12',
    ),
    AuditLog(
      id: 'log-002',
      actor: 'Bagas Pratama',
      action: 'Mengubah biaya layanan jadi 2,5%',
      module: 'Pengaturan',
      ip: '103.28.14.2',
      timestamp: '8 Nov · 08.40',
    ),
    AuditLog(
      id: 'log-003',
      actor: 'Dimas Saputra',
      action: 'Menonaktifkan akun pembeli',
      module: 'Pengguna',
      ip: '103.28.14.9',
      timestamp: '7 Nov · 16.05',
    ),
    AuditLog(
      id: 'log-004',
      actor: 'Maya Lestari',
      action: 'Mengunduh laporan Oktober',
      module: 'Laporan',
      ip: '114.5.20.31',
      timestamp: '7 Nov · 10.22',
    ),
    AuditLog(
      id: 'log-005',
      actor: 'Sistem',
      action: 'Pencadangan data harian',
      module: 'Sistem',
      ip: '-',
      timestamp: '8 Nov · 02.00',
    ),
    AuditLog(
      id: 'log-006',
      actor: 'Fajar Nugroho',
      action: 'Gagal masuk (3x)',
      module: 'Autentikasi',
      ip: '36.72.8.140',
      timestamp: '6 Nov · 21.47',
    ),
  ];

  @override
  Future<PaginatedResult<AuditLog>> getLogs({
    int page = 1,
    int pageSize = 20,
    String? q,
    String? module,
  }) async {
    await _delay();
    var filtered = _logs.where((l) {
      if (module != null &&
          module.isNotEmpty &&
          l.module.toLowerCase() != module.toLowerCase()) {
        return false;
      }
      if (q != null && q.isNotEmpty) {
        final qLow = q.toLowerCase();
        return l.actor.toLowerCase().contains(qLow) ||
            l.action.toLowerCase().contains(qLow);
      }
      return true;
    }).toList();
    return PaginatedResult(
      data: filtered,
      page: page,
      pageSize: pageSize,
      total: filtered.length,
    );
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

Future<void> _delay() =>
    Future.delayed(const Duration(milliseconds: 400));

// Singleton mock instances
final _mockSuperAdminRepo = MockSuperAdminRepository();
final _mockAdminMgmtRepo = MockAdminManagementRepository();
final _mockSuperUserRepo = MockSuperUserRepository();
final _mockReportRepo = MockReportRepository();
final _mockSettingsRepo = MockSettingsRepository();
final _mockAuditLogRepo = MockAuditLogRepository();

final superAdminRepositoryProvider = Provider<SuperAdminRepository>(
  (_) => AppConfig.useMock
      ? _mockSuperAdminRepo
      : HttpSuperAdminRepository(ApiClient.instance),
);

final adminManagementRepositoryProvider =
    Provider<AdminManagementRepository>(
  (_) => AppConfig.useMock
      ? _mockAdminMgmtRepo
      : HttpAdminManagementRepository(ApiClient.instance),
);

final superUserRepositoryProvider = Provider<SuperUserRepository>(
  (_) => AppConfig.useMock
      ? _mockSuperUserRepo
      : HttpSuperUserRepository(ApiClient.instance),
);

final reportRepositoryProvider = Provider<ReportRepository>(
  (_) => AppConfig.useMock
      ? _mockReportRepo
      : HttpReportRepository(ApiClient.instance),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (_) => AppConfig.useMock
      ? _mockSettingsRepo
      : HttpSettingsRepository(ApiClient.instance),
);

final auditLogRepositoryProvider = Provider<AuditLogRepository>(
  (_) => AppConfig.useMock
      ? _mockAuditLogRepo
      : HttpAuditLogRepository(ApiClient.instance),
);

