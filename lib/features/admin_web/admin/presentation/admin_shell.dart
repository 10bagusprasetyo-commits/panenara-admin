// lib/features/admin_web/admin/presentation/admin_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/presentation/router/admin_router.dart';
import '../../shared/presentation/widgets/sidebar_shell.dart';
import '../../shared/data/auth_repository.dart';
import '../../shared/domain/entities/auth_entity.dart';

final _adminMenuItems = [
  const SidebarMenuItem(
    id: 'ringkasan',
    label: 'Ringkasan',
    icon: Icons.home_outlined,
  ),
  const SidebarMenuItem(
    id: 'verifikasi-petani',
    label: 'Verifikasi Petani',
    icon: Icons.verified_user_outlined,
  ),
  const SidebarMenuItem(
    id: 'data-pengguna',
    label: 'Data Pengguna',
    icon: Icons.people_outline,
  ),
  const SidebarMenuItem(
    id: 'transaksi',
    label: 'Monitoring Transaksi',
    icon: Icons.credit_card_outlined,
  ),
  const SidebarMenuItem(
    id: 'lelang',
    label: 'Monitoring Lelang',
    icon: Icons.local_offer_outlined,
  ),
  const SidebarMenuItem(
    id: 'pengaduan',
    label: 'Pengaduan Pengguna',
    icon: Icons.message_outlined,
  ),
];

String _routeForId(String id) => switch (id) {
      'ringkasan' => AdminRoutes.adminDashboard,
      'verifikasi-petani' => AdminRoutes.adminVerification,
      'data-pengguna' => AdminRoutes.adminUsers,
      'transaksi' => AdminRoutes.adminTransactions,
      'lelang' => AdminRoutes.adminAuctions,
      'pengaduan' => AdminRoutes.adminComplaints,
      _ => AdminRoutes.adminDashboard,
    };

String _pageTitle(String seg) => switch (seg) {
      'ringkasan' => 'Ringkasan Operasional',
      'verifikasi-petani' => 'Verifikasi Petani',
      'data-pengguna' => 'Data Pengguna',
      'transaksi' => 'Monitoring Transaksi',
      'lelang' => 'Monitoring Lelang',
      'pengaduan' => 'Pengaduan Pengguna',
      _ => 'Ringkasan',
    };

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});

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
          name: 'Rina Wulandari',
          email: 'rina@panenara.id',
          role: AppRole.admin,
        );

    return SidebarShell(
      panelTitle: 'Panel Admin',
      roleChip: 'Admin',
      menuItems: _adminMenuItems,
      activeItemId: activeId,
      onMenuItemTap: (id) => context.go(_routeForId(id)),
      userName: user.name,
      userRole: user.role.label,
      breadcrumb: AdminBreadcrumb(
        panelName: 'Admin',
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
