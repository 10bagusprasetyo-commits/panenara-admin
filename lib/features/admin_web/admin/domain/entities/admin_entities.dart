// lib/features/admin_web/admin/domain/entities/admin_entities.dart

import 'package:equatable/equatable.dart';

// ─── Ops Dashboard ────────────────────────────────────────────────────────────

class OpsDashboardStats extends Equatable {
  const OpsDashboardStats({
    required this.pendingVerifications,
    required this.todayTransactions,
    required this.activeAuctions,
    required this.openComplaints,
    required this.verificationQueue,
    required this.recentComplaints,
  });

  final int pendingVerifications;
  final int todayTransactions;
  final int activeAuctions;
  final int openComplaints;
  final List<VerificationQueueItem> verificationQueue;
  final List<ComplaintItem> recentComplaints;

  @override
  List<Object?> get props => [pendingVerifications, todayTransactions];
}

class VerificationQueueItem extends Equatable {
  const VerificationQueueItem({
    required this.name,
    required this.subtitle,
    required this.pillLabel,
    required this.pillVariant,
  });
  final String name;
  final String subtitle;
  final String pillLabel;
  final String pillVariant;
  @override
  List<Object?> get props => [name, subtitle];
}

class ComplaintItem extends Equatable {
  const ComplaintItem({
    required this.title,
    required this.subtitle,
    required this.pillLabel,
    required this.pillVariant,
  });
  final String title;
  final String subtitle;
  final String pillLabel;
  final String pillVariant;
  @override
  List<Object?> get props => [title];
}

// ─── Farmer Verification ──────────────────────────────────────────────────────

enum VerificationStatus { waiting, needsRevision, verified, rejected }

class FarmerVerification extends Equatable {
  const FarmerVerification({
    required this.id,
    required this.farmerName,
    required this.farmerGroup,
    required this.location,
    required this.submittedAt,
    required this.status,
    this.reviewNote,
  });

  final String id;
  final String farmerName;
  final String farmerGroup;
  final String location;
  final String submittedAt;
  final VerificationStatus status;
  final String? reviewNote;

  String get statusLabel => switch (status) {
        VerificationStatus.waiting => 'Menunggu',
        VerificationStatus.needsRevision => 'Perlu perbaikan',
        VerificationStatus.verified => 'Terverifikasi',
        VerificationStatus.rejected => 'Ditolak',
      };

  String get statusVariant => switch (status) {
        VerificationStatus.waiting => 'wn',
        VerificationStatus.needsRevision => 'bd',
        VerificationStatus.verified => 'ok',
        VerificationStatus.rejected => 'bd',
      };

  @override
  List<Object?> get props => [id, farmerName, status];
}

// ─── Transaction ──────────────────────────────────────────────────────────────

enum TransactionStatus { success, awaitingPayment, failed, dispute }

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.buyer,
    required this.farmer,
    required this.commodity,
    required this.value,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String buyer;
  final String farmer;
  final String commodity;
  final String value;
  final TransactionStatus status;
  final String createdAt;

  String get statusLabel => switch (status) {
        TransactionStatus.success => 'Berhasil',
        TransactionStatus.awaitingPayment => 'Menunggu bayar',
        TransactionStatus.failed => 'Gagal',
        TransactionStatus.dispute => 'Sengketa',
      };

  String get statusVariant => switch (status) {
        TransactionStatus.success => 'ok',
        TransactionStatus.awaitingPayment => 'wn',
        TransactionStatus.failed => 'bd',
        TransactionStatus.dispute => 'bd',
      };

  @override
  List<Object?> get props => [id];
}

// ─── Auction ─────────────────────────────────────────────────────────────────

enum AuctionStatus { activeBidding, awaitingPayment, ended, cancelled }

class Auction extends Equatable {
  const Auction({
    required this.id,
    required this.title,
    required this.farmer,
    required this.highestBid,
    required this.bidCount,
    required this.endsAt,
    required this.status,
  });

  final String id;
  final String title;
  final String farmer;
  final String highestBid;
  final int bidCount;
  final String endsAt;
  final AuctionStatus status;

  String get statusLabel => switch (status) {
        AuctionStatus.activeBidding => 'Sedang ditawar',
        AuctionStatus.awaitingPayment => 'Menunggu pembayaran',
        AuctionStatus.ended => 'Selesai',
        AuctionStatus.cancelled => 'Dibatalkan',
      };

  String get statusVariant => switch (status) {
        AuctionStatus.activeBidding => 'ok',
        AuctionStatus.awaitingPayment => 'wn',
        AuctionStatus.ended => 'mt',
        AuctionStatus.cancelled => 'mt',
      };

  @override
  List<Object?> get props => [id];
}

// ─── Complaint ────────────────────────────────────────────────────────────────

enum ComplaintPriority { low, medium, high }

enum ComplaintStatus { open, inProgress, resolved, escalated }

class Complaint extends Equatable {
  const Complaint({
    required this.id,
    required this.reporterRole,
    required this.category,
    required this.summary,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.replies = const [],
  });

  final String id;
  final String reporterRole;
  final String category;
  final String summary;
  final ComplaintPriority priority;
  final ComplaintStatus status;
  final String? assignedTo;
  final List<ComplaintReply> replies;

  String get priorityLabel => switch (priority) {
        ComplaintPriority.high => 'Tinggi',
        ComplaintPriority.medium => 'Sedang',
        ComplaintPriority.low => 'Rendah',
      };

  String get priorityVariant => switch (priority) {
        ComplaintPriority.high => 'bd',
        ComplaintPriority.medium => 'wn',
        ComplaintPriority.low => 'mt',
      };

  String get statusLabel => switch (status) {
        ComplaintStatus.open => 'Terbuka',
        ComplaintStatus.inProgress => 'Diproses',
        ComplaintStatus.resolved => 'Selesai',
        ComplaintStatus.escalated => 'Eskalasi',
      };

  String get statusVariant => switch (status) {
        ComplaintStatus.open => 'wn',
        ComplaintStatus.inProgress => 'wn',
        ComplaintStatus.resolved => 'ok',
        ComplaintStatus.escalated => 'bd',
      };

  @override
  List<Object?> get props => [id, priority, status];
}

class ComplaintReply extends Equatable {
  const ComplaintReply({
    required this.id,
    required this.author,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String author;
  final String body;
  final String createdAt;

  @override
  List<Object?> get props => [id];
}
