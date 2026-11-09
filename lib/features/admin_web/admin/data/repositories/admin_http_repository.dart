// lib/features/admin_web/admin/data/repositories/admin_http_repository.dart
// Real HTTP implementation connecting to Backend REST API.
// Follows OpenAPI contract defined in docs/backend/openapi.yaml.

import '../../../shared/data/api_client.dart';
import '../../../shared/domain/entities/admin_user.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

class HttpOpsRepository implements OpsRepository {
  HttpOpsRepository(this._client);
  final ApiClient _client;

  @override
  Future<OpsDashboardStats> getDashboard() async {
    final res = await _client.dio.get<Map<String, dynamic>>('/admin/dashboard/ops');
    final d = res.data!['data'] as Map<String, dynamic>;

    final qList = (d['verification_queue'] as List? ?? [])
        .map((x) => VerificationQueueItem(
              name: x['name'] ?? '',
              subtitle: x['subtitle'] ?? '',
              pillLabel: x['pill_label'] ?? '',
              pillVariant: x['pill_variant'] ?? 'mt',
            ))
        .toList();

    final cList = (d['recent_complaints'] as List? ?? [])
        .map((x) => ComplaintItem(
              title: x['title'] ?? '',
              subtitle: x['subtitle'] ?? '',
              pillLabel: x['pill_label'] ?? '',
              pillVariant: x['pill_variant'] ?? 'mt',
            ))
        .toList();

    return OpsDashboardStats(
      pendingVerifications: d['pending_verifications'] ?? 0,
      todayTransactions: d['today_transactions'] ?? 0,
      activeAuctions: d['active_auctions'] ?? 0,
      openComplaints: d['open_complaints'] ?? 0,
      verificationQueue: qList,
      recentComplaints: cList,
    );
  }
}

class HttpVerificationRepository implements VerificationRepository {
  HttpVerificationRepository(this._client);
  final ApiClient _client;

  @override
  Future<PaginatedResult<FarmerVerification>> getVerifications({
    int page = 1,
    int pageSize = 20,
    VerificationStatus? status,
    String? q,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null) queryParams['status'] = status.name;
    if (q != null && q.isNotEmpty) queryParams['q'] = q;

    final res = await _client.dio.get<Map<String, dynamic>>(
      '/admin/farmer-verifications',
      queryParameters: queryParams,
    );

    final list = (res.data!['data'] as List)
        .map((d) => _parseVerification(d as Map<String, dynamic>))
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
  Future<FarmerVerification> getVerificationDetail(String id) async {
    final res = await _client.dio.get<Map<String, dynamic>>('/admin/farmer-verifications/$id');
    return _parseVerification(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<FarmerVerification> approve(String id) async {
    final res = await _client.dio.post<Map<String, dynamic>>('/admin/farmer-verifications/$id/approve');
    return _parseVerification(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<FarmerVerification> requestRevision({required String id, required String note}) async {
    final res = await _client.dio.post<Map<String, dynamic>>(
      '/admin/farmer-verifications/$id/request-revision',
      data: {'note': note},
    );
    return _parseVerification(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<FarmerVerification> reject({required String id, required String reason}) async {
    final res = await _client.dio.post<Map<String, dynamic>>(
      '/admin/farmer-verifications/$id/reject',
      data: {'reason': reason},
    );
    return _parseVerification(res.data!['data'] as Map<String, dynamic>);
  }

  FarmerVerification _parseVerification(Map<String, dynamic> d) {
    return FarmerVerification(
      id: d['id'] as String,
      farmerName: d['farmer_name'] ?? d['farmerName'] ?? '',
      farmerGroup: d['farmer_group'] ?? d['farmerGroup'] ?? '',
      location: d['location'] ?? '',
      submittedAt: d['submitted_at'] ?? d['submittedAt'] ?? '',
      status: _parseStatus(d['status'] as String?),
      reviewNote: d['review_note'] ?? d['reviewNote'],
    );
  }

  VerificationStatus _parseStatus(String? s) {
    return switch (s?.toLowerCase()) {
      'verified' => VerificationStatus.verified,
      'needs_revision' || 'needsrevision' => VerificationStatus.needsRevision,
      'rejected' => VerificationStatus.rejected,
      _ => VerificationStatus.waiting,
    };
  }
}

class HttpTransactionRepository implements TransactionRepository {
  HttpTransactionRepository(this._client);
  final ApiClient _client;

  @override
  Future<PaginatedResult<Transaction>> getTransactions({
    int page = 1,
    int pageSize = 20,
    TransactionStatus? status,
    String? q,
  }) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (status != null) qp['status'] = status.name;
    if (q != null && q.isNotEmpty) qp['q'] = q;

    final res = await _client.dio.get<Map<String, dynamic>>(
      '/admin/transactions',
      queryParameters: qp,
    );

    final list = (res.data!['data'] as List)
        .map((d) => _parseTransaction(d as Map<String, dynamic>))
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
  Future<Transaction> getTransactionDetail(String id) async {
    final res = await _client.dio.get<Map<String, dynamic>>('/admin/transactions/$id');
    return _parseTransaction(res.data!['data'] as Map<String, dynamic>);
  }

  Transaction _parseTransaction(Map<String, dynamic> d) {
    return Transaction(
      id: d['id'] as String,
      buyer: d['buyer'] ?? '',
      farmer: d['farmer'] ?? '',
      commodity: d['commodity'] ?? '',
      value: d['value'] ?? '',
      status: _parseTxStatus(d['status'] as String?),
      createdAt: d['created_at'] ?? d['createdAt'] ?? '',
    );
  }

  TransactionStatus _parseTxStatus(String? s) {
    return switch (s?.toLowerCase()) {
      'awaiting_payment' || 'awaitingpayment' => TransactionStatus.awaitingPayment,
      'failed' => TransactionStatus.failed,
      'dispute' => TransactionStatus.dispute,
      _ => TransactionStatus.success,
    };
  }
}

class HttpAuctionRepository implements AuctionRepository {
  HttpAuctionRepository(this._client);
  final ApiClient _client;

  @override
  Future<PaginatedResult<Auction>> getAuctions({
    int page = 1,
    int pageSize = 20,
    AuctionStatus? status,
    String? q,
  }) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (status != null) qp['status'] = status.name;
    if (q != null && q.isNotEmpty) qp['q'] = q;

    final res = await _client.dio.get<Map<String, dynamic>>(
      '/admin/auctions',
      queryParameters: qp,
    );

    final list = (res.data!['data'] as List)
        .map((d) => _parseAuction(d as Map<String, dynamic>))
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
  Future<Auction> getAuctionDetail(String id) async {
    final res = await _client.dio.get<Map<String, dynamic>>('/admin/auctions/$id');
    return _parseAuction(res.data!['data'] as Map<String, dynamic>);
  }

  Auction _parseAuction(Map<String, dynamic> d) {
    return Auction(
      id: d['id'] as String,
      title: d['title'] ?? '',
      farmer: d['farmer'] ?? '',
      highestBid: d['highest_bid'] ?? d['highestBid'] ?? '',
      bidCount: d['bid_count'] ?? d['bidCount'] ?? 0,
      endsAt: d['ends_at'] ?? d['endsAt'] ?? '',
      status: _parseAuctionStatus(d['status'] as String?),
    );
  }

  AuctionStatus _parseAuctionStatus(String? s) {
    return switch (s?.toLowerCase()) {
      'awaiting_payment' || 'awaitingpayment' => AuctionStatus.awaitingPayment,
      'ended' => AuctionStatus.ended,
      'cancelled' => AuctionStatus.cancelled,
      _ => AuctionStatus.activeBidding,
    };
  }
}

class HttpComplaintRepository implements ComplaintRepository {
  HttpComplaintRepository(this._client);
  final ApiClient _client;

  @override
  Future<PaginatedResult<Complaint>> getComplaints({
    int page = 1,
    int pageSize = 20,
    ComplaintStatus? status,
    ComplaintPriority? priority,
    String? q,
  }) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (status != null) qp['status'] = status.name;
    if (priority != null) qp['priority'] = priority.name;
    if (q != null && q.isNotEmpty) qp['q'] = q;

    final res = await _client.dio.get<Map<String, dynamic>>(
      '/admin/complaints',
      queryParameters: qp,
    );

    final list = (res.data!['data'] as List)
        .map((d) => _parseComplaint(d as Map<String, dynamic>))
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
  Future<Complaint> getComplaintDetail(String id) async {
    final res = await _client.dio.get<Map<String, dynamic>>('/admin/complaints/$id');
    return _parseComplaint(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<Complaint> updateComplaint({
    required String id,
    ComplaintStatus? status,
    ComplaintPriority? priority,
    String? assignedTo,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status.name;
    if (priority != null) body['priority'] = priority.name;
    if (assignedTo != null) body['assigned_to'] = assignedTo;

    final res = await _client.dio.patch<Map<String, dynamic>>(
      '/admin/complaints/$id',
      data: body,
    );
    return _parseComplaint(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<ComplaintReply> addReply({
    required String complaintId,
    required String body,
  }) async {
    final res = await _client.dio.post<Map<String, dynamic>>(
      '/admin/complaints/$complaintId/replies',
      data: {'body': body},
    );
    final d = res.data!['data'] as Map<String, dynamic>;
    return ComplaintReply(
      id: d['id'] as String,
      author: d['author'] ?? 'Admin',
      body: d['body'] ?? body,
      createdAt: d['created_at'] ?? d['createdAt'] ?? 'Baru saja',
    );
  }

  Complaint _parseComplaint(Map<String, dynamic> d) {
    final repliesList = (d['replies'] as List? ?? [])
        .map((r) => ComplaintReply(
              id: r['id'] as String,
              author: r['author'] ?? 'Admin',
              body: r['body'] ?? '',
              createdAt: r['created_at'] ?? r['createdAt'] ?? '',
            ))
        .toList();

    return Complaint(
      id: d['id'] as String,
      reporterRole: d['reporter_role'] ?? d['reporterRole'] ?? 'Pengguna',
      category: d['category'] ?? '',
      summary: d['summary'] ?? '',
      priority: _parsePriority(d['priority'] as String?),
      status: _parseComplaintStatus(d['status'] as String?),
      assignedTo: d['assigned_to'] ?? d['assignedTo'],
      replies: repliesList,
    );
  }

  ComplaintPriority _parsePriority(String? p) {
    return switch (p?.toLowerCase()) {
      'high' => ComplaintPriority.high,
      'medium' => ComplaintPriority.medium,
      _ => ComplaintPriority.low,
    };
  }

  ComplaintStatus _parseComplaintStatus(String? s) {
    return switch (s?.toLowerCase()) {
      'in_progress' || 'inprogress' => ComplaintStatus.inProgress,
      'resolved' => ComplaintStatus.resolved,
      'escalated' => ComplaintStatus.escalated,
      _ => ComplaintStatus.open,
    };
  }
}
