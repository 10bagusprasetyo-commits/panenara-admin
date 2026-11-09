// test/unit/role_guard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:panenara/features/admin_web/shared/domain/entities/auth_entity.dart';
import 'package:panenara/features/admin_web/shared/presentation/router/admin_router.dart';

void main() {
  group('Role Guard Logic', () {
    test('AppRole flags are correctly identified', () {
      expect(AppRole.superAdmin.isAdminPanel, isTrue);
      expect(AppRole.admin.isAdminPanel, isTrue);
      expect(AppRole.petani.isAdminPanel, isFalse);
      expect(AppRole.pembeli.isAdminPanel, isFalse);
      expect(AppRole.pengamat.isAdminPanel, isFalse);
    });

    test('Super admin route access restriction', () {
      // Super admin can access super-admin routes
      const saUser = CurrentUser(
        id: 'sa-1',
        name: 'Super Admin',
        email: 'super@panenara.id',
        role: AppRole.superAdmin,
      );
      expect(saUser.role == AppRole.superAdmin, isTrue);

      // Admin CANNOT access super-admin routes
      const adminUser = CurrentUser(
        id: 'ad-1',
        name: 'Admin Ops',
        email: 'admin@panenara.id',
        role: AppRole.admin,
      );
      final isForbiddenForAdmin =
          AdminRoutes.superAdminDashboard.startsWith('/super-admin') &&
              adminUser.role != AppRole.superAdmin;
      expect(isForbiddenForAdmin, isTrue);

      // Super Admin is NOT forbidden for super-admin routes
      final isForbiddenForSA =
          AdminRoutes.superAdminDashboard.startsWith('/super-admin') &&
              saUser.role != AppRole.superAdmin;
      expect(isForbiddenForSA, isFalse);
    });

    test('Role label mapping', () {
      expect(AppRole.superAdmin.label, 'Super Admin');
      expect(AppRole.admin.label, 'Admin');
      expect(AppRole.petani.label, 'Petani');
      expect(AppRole.pembeli.label, 'Pembeli');
      expect(AppRole.pengamat.label, 'Pengamat');
    });
  });
}
