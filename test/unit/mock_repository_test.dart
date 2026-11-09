// test/unit/mock_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:panenara/features/admin_web/admin/data/repositories/admin_mock_repository.dart';
import 'package:panenara/features/admin_web/admin/domain/entities/admin_entities.dart';
import 'package:panenara/features/admin_web/shared/domain/entities/admin_user.dart';
import 'package:panenara/features/admin_web/super_admin/data/repositories/super_admin_mock_repository.dart';

void main() {
  group('MockOpsRepository', () {
    final repo = MockOpsRepository();

    test('getDashboard returns valid initial statistics', () async {
      final stats = await repo.getDashboard();
      expect(stats.pendingVerifications, greaterThan(0));
      expect(stats.todayTransactions, greaterThan(0));
      expect(stats.activeAuctions, greaterThan(0));
      expect(stats.openComplaints, greaterThan(0));
      expect(stats.verificationQueue.isNotEmpty, isTrue);
      expect(stats.recentComplaints.isNotEmpty, isTrue);
    });
  });

  group('MockVerificationRepository', () {
    late MockVerificationRepository repo;

    setUp(() {
      repo = MockVerificationRepository();
    });

    test('getVerifications supports status filter and pagination', () async {
      final all = await repo.getVerifications();
      expect(all.data.isNotEmpty, isTrue);

      final waiting = await repo.getVerifications(
        status: VerificationStatus.waiting,
      );
      for (final v in waiting.data) {
        expect(v.status, VerificationStatus.waiting);
      }
    });

    test('approve updates status to verified', () async {
      final updated = await repo.approve('ver-001');
      expect(updated.status, VerificationStatus.verified);

      final detail = await repo.getVerificationDetail('ver-001');
      expect(detail.status, VerificationStatus.verified);
    });

    test('requestRevision updates status and sets review note', () async {
      final updated = await repo.requestRevision(
        id: 'ver-002',
        note: 'KTP tidak terbaca jelas',
      );
      expect(updated.status, VerificationStatus.needsRevision);
      expect(updated.reviewNote, 'KTP tidak terbaca jelas');
    });

    test('reject updates status to rejected with reason', () async {
      final updated = await repo.reject(
        id: 'ver-002',
        reason: 'Dokumen palsu',
      );
      expect(updated.status, VerificationStatus.rejected);
      expect(updated.reviewNote, 'Dokumen palsu');
    });
  });

  group('MockTransactionRepository', () {
    final repo = MockTransactionRepository();

    test('getTransactions filters by query and status', () async {
      final result = await repo.getTransactions(q: 'Cabai');
      expect(result.data.isNotEmpty, isTrue);
      for (final tx in result.data) {
        expect(
          tx.commodity.toLowerCase().contains('cabai') ||
              tx.buyer.toLowerCase().contains('cabai') ||
              tx.farmer.toLowerCase().contains('cabai'),
          isTrue,
        );
      }
    });
  });

  group('MockComplaintRepository', () {
    final repo = MockComplaintRepository();

    test('addReply appends a reply to complaint', () async {
      final initial = await repo.getComplaintDetail('ADU-0412');
      final initialReplyCount = initial.replies.length;

      final reply = await repo.addReply(
        complaintId: 'ADU-0412',
        body: 'Tim kami sedang mengecek dokumen panen Anda.',
      );
      expect(reply.body, 'Tim kami sedang mengecek dokumen panen Anda.');

      final updated = await repo.getComplaintDetail('ADU-0412');
      expect(updated.replies.length, initialReplyCount + 1);
    });

    test('updateComplaint changes status and priority', () async {
      final updated = await repo.updateComplaint(
        id: 'ADU-0412',
        status: ComplaintStatus.resolved,
        priority: ComplaintPriority.low,
      );
      expect(updated.status, ComplaintStatus.resolved);
      expect(updated.priority, ComplaintPriority.low);
    });
  });

  group('MockSuperAdminRepository', () {
    test('getDashboard returns full super admin metrics', () async {
      final repo = MockSuperAdminRepository();
      final dash = await repo.getDashboard();
      expect(dash.totalUsers, greaterThan(0));
      expect(dash.monthlyTransactionValue.isNotEmpty, isTrue);
      expect(dash.recentActivities.isNotEmpty, isTrue);
      expect(dash.alerts.isNotEmpty, isTrue);
    });

    test('createAdmin and setAdminStatus work in MockAdminManagementRepository', () async {
      final repo = MockAdminManagementRepository();
      final created = await repo.createAdmin(
        name: 'Admin Baru',
        email: 'baru@panenara.id',
        role: AdminRole.admin,
        accessLevel: 'limited',
        password: 'Password123!',
      );
      expect(created.name, 'Admin Baru');
      expect(created.status, UserStatus.active);

      final suspended = await repo.setAdminStatus(
        id: created.id,
        status: UserStatus.suspended,
      );
      expect(suspended.status, UserStatus.suspended);
    });

    test('updateSettings updates parameters in MockSettingsRepository', () async {
      final repo = MockSettingsRepository();
      await repo.updateSettings({'auction_fee': '3.0%'});
      final settings = await repo.getSettings();
      final feeSetting =
          settings.firstWhere((s) => s.key == 'auction_fee');
      expect(feeSetting.value, '3.0%');
    });
  });
}

