// lib/features/admin_web/super_admin/presentation/super_admin_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/presentation/router/admin_router.dart';
import '../../shared/presentation/widgets/sidebar_shell.dart';
import '../../shared/data/auth_repository.dart';
import '../../shared/domain/entities/auth_entity.dart';

final _superAdminMenuItems = [
  const SidebarMenuItem(
    id: 'ringkasan',
    label: 'Ringkasan',
    icon: Icons.home_outlined,
  ),
  const SidebarMenuItem(
    id: 'manajemen-admin',
    label: 'Manajemen Admin',
    icon: Icons.shield_outlined,
  ),
  const SidebarMenuItem(
    id: 'manajemen-pengguna',
    label: 'Manajemen Pengguna',
    icon: Icons.people_outline,
  ),
  const SidebarMenuItem(
    id: 'laporan',
    label: 'Laporan Keseluruhan',
    icon: Icons.bar_chart_outlined,
  ),
  const SidebarMenuItem(
    id: 'pengaturan',
    label: 'Pengaturan Sistem',
    icon: Icons.settings_outlined,
  ),
  const SidebarMenuItem(
    id: 'log-aktivitas',
    label: 'Log Aktivitas',
    icon: Icons.list_alt_outlined,
  ),
];

String _routeForId(String id) => switch (id) {
      'ringkasan' => AdminRoutes.superAdminDashboard,
      'manajemen-admin' => AdminRoutes.superAdminManageAdmins,
      'manajemen-pengguna' => AdminRoutes.superAdminUsers,
      'laporan' => AdminRoutes.superAdminReports,
      'pengaturan' => AdminRoutes.superAdminSettings,
      'log-aktivitas' => AdminRoutes.superAdminLogs,
      _ => AdminRoutes.superAdminDashboard,
    };

String _pageTitle(String routeSegment) => switch (routeSegment) {
      'ringkasan' => 'Ringkasan Sistem',
      'manajemen-admin' => 'Manajemen Admin',
      'manajemen-pengguna' => 'Manajemen Pengguna',
      'laporan' => 'Laporan Keseluruhan',
      'pengaturan' => 'Pengaturan Sistem',
      'log-aktivitas' => 'Log Aktivitas',
      _ => 'Ringkasan',
    };

class SuperAdminShell extends ConsumerWidget {
  const SuperAdminShell({super.key, required this.child});

  final Widget child;

  String _activeId(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final seg = loc.split('/').last;
    return seg.isEmpty ? 'ringkasan' : seg;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final activeId = _activeId(context);

    final user = userAsync.valueOrNull ??
        const CurrentUser(
          id: '',
          name: 'Bagas Pratama',
          email: 'bagas@panenara.id',
          role: AppRole.superAdmin,
        );

    return SidebarShell(
      panelTitle: 'Panel Super Admin',
      roleChip: 'Super Admin',
      menuItems: _superAdminMenuItems,
      activeItemId: activeId,
      onMenuItemTap: (id) => context.go(_routeForId(id)),
      userName: user.name,
      userRole: user.role.label,
      breadcrumb: AdminBreadcrumb(
        panelName: 'Super Admin',
        currentPage: _pageTitle(activeId),
      ),
      topActions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
          tooltip: 'Cari',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
          tooltip: 'Notifikasi',
        ),
        IconButton(
          icon: const Icon(Icons.logout_outlined),
          onPressed: () async {
            await ref.read(authRepositoryProvider).logout();
            if (context.mounted) context.go(AdminRoutes.login);
          },
          tooltip: 'Keluar',
        ),
      ],
      child: child,
    );
  }
}
