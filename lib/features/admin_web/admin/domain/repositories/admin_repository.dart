// lib/features/admin_web/admin/domain/repositories/admin_repository.dart

import '../../../shared/domain/entities/admin_user.dart';
import '../entities/admin_entities.dart';

abstract class OpsRepository {
  Future<OpsDashboardStats> getDashboard();
}

abstract class VerificationRepository {
  Future<PaginatedResult<FarmerVerification>> getVerifications({
    int page = 1,
    int pageSize = 20,
    VerificationStatus? status,
    String? q,
  });

  Future<FarmerVerification> getVerificationDetail(String id);

  Future<FarmerVerification> approve(String id);

  Future<FarmerVerification> requestRevision({
    required String id,
    required String note,
  });

  Future<FarmerVerification> reject({
    required String id,
    required String reason,
  });
}

abstract class TransactionRepository {
  Future<PaginatedResult<Transaction>> getTransactions({
    int page = 1,
    int pageSize = 20,
    TransactionStatus? status,
    String? q,
  });

  Future<Transaction> getTransactionDetail(String id);
}

abstract class AuctionRepository {
  Future<PaginatedResult<Auction>> getAuctions({
    int page = 1,
    int pageSize = 20,
    AuctionStatus? status,
    String? q,
  });

  Future<Auction> getAuctionDetail(String id);
}

abstract class ComplaintRepository {
  Future<PaginatedResult<Complaint>> getComplaints({
    int page = 1,
    int pageSize = 20,
    ComplaintStatus? status,
    ComplaintPriority? priority,
    String? q,
  });

  Future<Complaint> getComplaintDetail(String id);

  Future<Complaint> updateComplaint({
    required String id,
    ComplaintStatus? status,
    ComplaintPriority? priority,
    String? assignedTo,
  });

  Future<ComplaintReply> addReply({
    required String complaintId,
    required String body,
  });
}
