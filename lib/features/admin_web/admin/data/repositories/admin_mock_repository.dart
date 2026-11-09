// lib/features/admin_web/admin/data/repositories/admin_mock_repository.dart
// Mock data sesuai HTML desain Panel Admin

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/entities/admin_user.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../../../../../app_config.dart';

Future<void> _delay([int ms = 400]) =>
    Future.delayed(Duration(milliseconds: ms));

// ─── Mock Ops Dashboard ───────────────────────────────────────────────────────

class MockOpsRepository implements OpsRepository {
  @override
  Future<OpsDashboardStats> getDashboard() async {
    await _delay();
    return const OpsDashboardStats(
      pendingVerifications: 23,
      todayTransactions: 184,
      activeAuctions: 146,
      openComplaints: 9,
      verificationQueue: [
        VerificationQueueItem(
          name: 'Budi Hartono',
          subtitle: 'Dokumen lahan · Garut, Jabar',
          pillLabel: 'Menunggu',
          pillVariant: 'wn',
        ),
        VerificationQueueItem(
          name: 'Kelompok Tani Subur',
          subtitle: 'Foto KTP · Cianjur, Jabar',
          pillLabel: 'Menunggu',
          pillVariant: 'wn',
        ),
        VerificationQueueItem(
          name: 'Wayan Sudarma',
          subtitle: 'Selfie dengan KTP · Tabanan, Bali',
          pillLabel: 'Perbaiki',
          pillVariant: 'bd',
        ),
      ],
      recentComplaints: [
        ComplaintItem(
          title: 'Barang tidak sesuai grade',
          subtitle: 'Pembeli · 20 menit lalu',
          pillLabel: 'Tinggi',
          pillVariant: 'bd',
        ),
        ComplaintItem(
          title: 'Pembayaran belum masuk',
          subtitle: 'Petani · 1 jam lalu',
          pillLabel: 'Sedang',
          pillVariant: 'wn',
        ),
        ComplaintItem(
          title: 'Sulit mengunggah foto panen',
          subtitle: 'Petani · 3 jam lalu',
          pillLabel: 'Rendah',
          pillVariant: 'mt',
        ),
      ],
    );
  }
}

// ─── Mock Verification ────────────────────────────────────────────────────────

class MockVerificationRepository implements VerificationRepository {
  final _verifications = <FarmerVerification>[
    const FarmerVerification(
      id: 'ver-001',
      farmerName: 'Budi Hartono',
      farmerGroup: 'Tani Jaya',
      location: 'Garut, Jabar',
      submittedAt: 'Hari ini · 07.30',
      status: VerificationStatus.waiting,
    ),
    const FarmerVerification(
      id: 'ver-002',
      farmerName: 'Siti Rahayu',
      farmerGroup: 'Sari Bumi',
      location: 'Cianjur, Jabar',
      submittedAt: 'Hari ini · 06.10',
      status: VerificationStatus.waiting,
    ),
    const FarmerVerification(
      id: 'ver-003',
      farmerName: 'Wayan Sudarma',
      farmerGroup: 'Subak Makmur',
      location: 'Tabanan, Bali',
      submittedAt: 'Kemarin',
      status: VerificationStatus.needsRevision,
      reviewNote: 'Foto KTP kurang jelas',
    ),
    const FarmerVerification(
      id: 'ver-004',
      farmerName: 'Sari Dewi',
      farmerGroup: 'Mekar Sentosa',
      location: 'Magelang, Jateng',
      submittedAt: '12 Okt 2026',
      status: VerificationStatus.verified,
    ),
    const FarmerVerification(
      id: 'ver-005',
      farmerName: 'Eko Prasetyo',
      farmerGroup: 'Tani Mandiri',
      location: 'Malang, Jatim',
      submittedAt: '10 Okt 2026',
      status: VerificationStatus.verified,
    ),
  ];

  @override
  Future<PaginatedResult<FarmerVerification>> getVerifications({
    int page = 1,
    int pageSize = 20,
    VerificationStatus? status,
    String? q,
  }) async {
    await _delay();
    var filtered = _verifications.where((v) {
      if (status != null && v.status != status) return false;
      if (q != null && q.isNotEmpty) {
        final qLow = q.toLowerCase();
        return v.farmerName.toLowerCase().contains(qLow) ||
            v.location.toLowerCase().contains(qLow);
      }
      return true;
    }).toList();
    return PaginatedResult(data: filtered, page: page, pageSize: pageSize, total: filtered.length);
  }

  @override
  Future<FarmerVerification> getVerificationDetail(String id) async {
    await _delay(200);
    return _verifications.firstWhere((v) => v.id == id,
        orElse: () => throw Exception('Verifikasi tidak ditemukan'));
  }

  @override
  Future<FarmerVerification> approve(String id) async {
    await _delay();
    final idx = _verifications.indexWhere((v) => v.id == id);
    if (idx < 0) throw Exception('Verifikasi tidak ditemukan');
    final updated = FarmerVerification(
      id: _verifications[idx].id,
      farmerName: _verifications[idx].farmerName,
      farmerGroup: _verifications[idx].farmerGroup,
      location: _verifications[idx].location,
      submittedAt: _verifications[idx].submittedAt,
      status: VerificationStatus.verified,
    );
    _verifications[idx] = updated;
    return updated;
  }

  @override
  Future<FarmerVerification> requestRevision({required String id, required String note}) async {
    await _delay();
    final idx = _verifications.indexWhere((v) => v.id == id);
    if (idx < 0) throw Exception('Verifikasi tidak ditemukan');
    final updated = FarmerVerification(
      id: _verifications[idx].id,
      farmerName: _verifications[idx].farmerName,
      farmerGroup: _verifications[idx].farmerGroup,
      location: _verifications[idx].location,
      submittedAt: _verifications[idx].submittedAt,
      status: VerificationStatus.needsRevision,
      reviewNote: note,
    );
    _verifications[idx] = updated;
    return updated;
  }

  @override
  Future<FarmerVerification> reject({required String id, required String reason}) async {
    await _delay();
    final idx = _verifications.indexWhere((v) => v.id == id);
    if (idx < 0) throw Exception('Verifikasi tidak ditemukan');
    final updated = FarmerVerification(
      id: _verifications[idx].id,
      farmerName: _verifications[idx].farmerName,
      farmerGroup: _verifications[idx].farmerGroup,
      location: _verifications[idx].location,
      submittedAt: _verifications[idx].submittedAt,
      status: VerificationStatus.rejected,
      reviewNote: reason,
    );
    _verifications[idx] = updated;
    return updated;
  }
}

// ─── Mock Transaction ─────────────────────────────────────────────────────────

class MockTransactionRepository implements TransactionRepository {
  final _transactions = const <Transaction>[
    Transaction(
      id: 'TRX-20811',
      buyer: 'PT Segar Nusantara',
      farmer: 'Sari Dewi',
      commodity: 'Cabai merah 1.500 kg',
      value: 'Rp 39.750.000',
      status: TransactionStatus.success,
      createdAt: 'Hari ini · 09.00',
    ),
    Transaction(
      id: 'TRX-20810',
      buyer: 'CV Tani Makmur',
      farmer: 'Eko Prasetyo',
      commodity: 'Bawang merah 800 kg',
      value: 'Rp 28.000.000',
      status: TransactionStatus.awaitingPayment,
      createdAt: 'Hari ini · 08.30',
    ),
    Transaction(
      id: 'TRX-20809',
      buyer: 'Warung Sehat',
      farmer: 'Wayan Sudarma',
      commodity: 'Tomat 300 kg',
      value: 'Rp 3.900.000',
      status: TransactionStatus.success,
      createdAt: 'Hari ini · 07.00',
    ),
    Transaction(
      id: 'TRX-20808',
      buyer: 'PT Segar Nusantara',
      farmer: 'Budi Hartono',
      commodity: 'Jagung 2 ton',
      value: 'Rp 14.400.000',
      status: TransactionStatus.dispute,
      createdAt: 'Kemarin · 16.00',
    ),
    Transaction(
      id: 'TRX-20807',
      buyer: 'Pangan Jaya',
      farmer: 'Siti Rahayu',
      commodity: 'Padi 1 ton',
      value: 'Rp 6.200.000',
      status: TransactionStatus.success,
      createdAt: 'Kemarin · 14.00',
    ),
  ];

  @override
  Future<PaginatedResult<Transaction>> getTransactions({
    int page = 1,
    int pageSize = 20,
    TransactionStatus? status,
    String? q,
  }) async {
    await _delay();
    var filtered = _transactions.where((t) {
      if (status != null && t.status != status) return false;
      if (q != null && q.isNotEmpty) {
        final qLow = q.toLowerCase();
        return t.id.toLowerCase().contains(qLow) ||
            t.buyer.toLowerCase().contains(qLow) ||
            t.farmer.toLowerCase().contains(qLow) ||
            t.commodity.toLowerCase().contains(qLow);
      }
      return true;
    }).toList();
    return PaginatedResult(data: filtered, page: page, pageSize: pageSize, total: filtered.length);
  }

  @override
  Future<Transaction> getTransactionDetail(String id) async {
    await _delay(200);
    return _transactions.firstWhere((t) => t.id == id,
        orElse: () => throw Exception('Transaksi tidak ditemukan'));
  }
}

// ─── Mock Auction ─────────────────────────────────────────────────────────────

class MockAuctionRepository implements AuctionRepository {
  final _auctions = const <Auction>[
    Auction(
      id: 'lel-001',
      title: 'Cabai Merah Keriting Unggul',
      farmer: 'Sari Dewi',
      highestBid: 'Rp 26.500 /kg',
      bidCount: 12,
      endsAt: 'Hari ini · 18.00',
      status: AuctionStatus.activeBidding,
    ),
    Auction(
      id: 'lel-002',
      title: 'Bawang Merah Brebes',
      farmer: 'Eko Prasetyo',
      highestBid: 'Rp 35.000 /kg',
      bidCount: 7,
      endsAt: 'Besok · 12.00',
      status: AuctionStatus.activeBidding,
    ),
    Auction(
      id: 'lel-003',
      title: 'Tomat Ranti Segar',
      farmer: 'Wayan Sudarma',
      highestBid: 'Rp 13.000 /kg',
      bidCount: 4,
      endsAt: '9 Nov · 09.00',
      status: AuctionStatus.activeBidding,
    ),
    Auction(
      id: 'lel-004',
      title: 'Jagung Pipil Kering',
      farmer: 'Budi Hartono',
      highestBid: 'Rp 7.200 /kg',
      bidCount: 9,
      endsAt: 'Selesai',
      status: AuctionStatus.awaitingPayment,
    ),
    Auction(
      id: 'lel-005',
      title: 'Padi Inpari 32',
      farmer: 'Siti Rahayu',
      highestBid: 'Rp 6.200 /kg',
      bidCount: 0,
      endsAt: 'Dibatalkan',
      status: AuctionStatus.cancelled,
    ),
  ];

  @override
  Future<PaginatedResult<Auction>> getAuctions({
    int page = 1,
    int pageSize = 20,
    AuctionStatus? status,
    String? q,
  }) async {
    await _delay();
    var filtered = _auctions.where((a) {
      if (status != null && a.status != status) return false;
      if (q != null && q.isNotEmpty) {
        final qLow = q.toLowerCase();
        return a.title.toLowerCase().contains(qLow) ||
            a.farmer.toLowerCase().contains(qLow);
      }
      return true;
    }).toList();
    return PaginatedResult(data: filtered, page: page, pageSize: pageSize, total: filtered.length);
  }

  @override
  Future<Auction> getAuctionDetail(String id) async {
    await _delay(200);
    return _auctions.firstWhere((a) => a.id == id,
        orElse: () => throw Exception('Lelang tidak ditemukan'));
  }
}

// ─── Mock Complaint ───────────────────────────────────────────────────────────

class MockComplaintRepository implements ComplaintRepository {
  final _complaints = <Complaint>[
    const Complaint(
      id: 'ADU-0412',
      reporterRole: 'Pembeli',
      category: 'Kualitas barang',
      summary: 'Grade tidak sesuai hasil AI',
      priority: ComplaintPriority.high,
      status: ComplaintStatus.open,
    ),
    const Complaint(
      id: 'ADU-0411',
      reporterRole: 'Petani',
      category: 'Pembayaran',
      summary: 'Dana belum masuk 2 hari',
      priority: ComplaintPriority.medium,
      status: ComplaintStatus.inProgress,
    ),
    const Complaint(
      id: 'ADU-0410',
      reporterRole: 'Petani',
      category: 'Aplikasi',
      summary: 'Gagal mengunggah foto panen',
      priority: ComplaintPriority.low,
      status: ComplaintStatus.inProgress,
    ),
    const Complaint(
      id: 'ADU-0409',
      reporterRole: 'Pengamat',
      category: 'Investasi',
      summary: 'Pertanyaan bagi hasil proyek',
      priority: ComplaintPriority.low,
      status: ComplaintStatus.resolved,
    ),
  ];

  @override
  Future<PaginatedResult<Complaint>> getComplaints({
    int page = 1,
    int pageSize = 20,
    ComplaintStatus? status,
    ComplaintPriority? priority,
    String? q,
  }) async {
    await _delay();
    var filtered = _complaints.where((c) {
      if (status != null && c.status != status) return false;
      if (priority != null && c.priority != priority) return false;
      if (q != null && q.isNotEmpty) {
        final qLow = q.toLowerCase();
        return c.id.toLowerCase().contains(qLow) ||
            c.summary.toLowerCase().contains(qLow) ||
            c.category.toLowerCase().contains(qLow);
      }
      return true;
    }).toList();
    return PaginatedResult(data: filtered, page: page, pageSize: pageSize, total: filtered.length);
  }

  @override
  Future<Complaint> getComplaintDetail(String id) async {
    await _delay(200);
    return _complaints.firstWhere((c) => c.id == id,
        orElse: () => throw Exception('Pengaduan tidak ditemukan'));
  }

  @override
  Future<Complaint> updateComplaint({
    required String id,
    ComplaintStatus? status,
    ComplaintPriority? priority,
    String? assignedTo,
  }) async {
    await _delay();
    final idx = _complaints.indexWhere((c) => c.id == id);
    if (idx < 0) throw Exception('Pengaduan tidak ditemukan');
    final updated = Complaint(
      id: id,
      reporterRole: _complaints[idx].reporterRole,
      category: _complaints[idx].category,
      summary: _complaints[idx].summary,
      priority: priority ?? _complaints[idx].priority,
      status: status ?? _complaints[idx].status,
      assignedTo: assignedTo ?? _complaints[idx].assignedTo,
      replies: _complaints[idx].replies,
    );
    _complaints[idx] = updated;
    return updated;
  }

  @override
  Future<ComplaintReply> addReply({
    required String complaintId,
    required String body,
  }) async {
    await _delay();
    final reply = ComplaintReply(
      id: 'reply-${DateTime.now().millisecondsSinceEpoch}',
      author: 'Admin',
      body: body,
      createdAt: 'Baru saja',
    );
    final idx = _complaints.indexWhere((c) => c.id == complaintId);
    if (idx >= 0) {
      _complaints[idx] = Complaint(
        id: _complaints[idx].id,
        reporterRole: _complaints[idx].reporterRole,
        category: _complaints[idx].category,
        summary: _complaints[idx].summary,
        priority: _complaints[idx].priority,
        status: _complaints[idx].status,
        assignedTo: _complaints[idx].assignedTo,
        replies: [..._complaints[idx].replies, reply],
      );
    }
    return reply;
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final _mockOpsRepo = MockOpsRepository();
final _mockVerificationRepo = MockVerificationRepository();
final _mockTransactionRepo = MockTransactionRepository();
final _mockAuctionRepo = MockAuctionRepository();
final _mockComplaintRepo = MockComplaintRepository();

final opsRepositoryProvider = Provider<OpsRepository>(
  (_) => AppConfig.useMock ? _mockOpsRepo : _mockOpsRepo,
);

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (_) => AppConfig.useMock ? _mockVerificationRepo : _mockVerificationRepo,
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (_) => AppConfig.useMock ? _mockTransactionRepo : _mockTransactionRepo,
);

final auctionRepositoryProvider = Provider<AuctionRepository>(
  (_) => AppConfig.useMock ? _mockAuctionRepo : _mockAuctionRepo,
);

final complaintRepositoryProvider = Provider<ComplaintRepository>(
  (_) => AppConfig.useMock ? _mockComplaintRepo : _mockComplaintRepo,
);

