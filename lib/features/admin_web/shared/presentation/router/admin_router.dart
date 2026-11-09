// lib/features/admin_web/shared/presentation/router/admin_router.dart
// go_router setup dengan role guard.
// Role guard: super_admin → /super-admin/*, admin → /admin/*
// Role lain atau belum login → redirect ke /login

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/data/auth_repository.dart';
import '../../../shared/domain/entities/auth_entity.dart';
import '../pages/login_page.dart';
import '../pages/forbidden_page.dart';

// Super Admin shell & pages
import '../../../super_admin/presentation/super_admin_shell.dart';
import '../../../super_admin/presentation/pages/sa_dashboard_page.dart';
import '../../../super_admin/presentation/pages/sa_manage_admins_page.dart';
import '../../../super_admin/presentation/pages/sa_users_page.dart';
import '../../../super_admin/presentation/pages/sa_reports_page.dart';
import '../../../super_admin/presentation/pages/sa_settings_page.dart';
import '../../../super_admin/presentation/pages/sa_logs_page.dart';

// Admin shell & pages
import '../../../admin/presentation/admin_shell.dart';
import '../../../admin/presentation/pages/ad_dashboard_page.dart';
import '../../../admin/presentation/pages/ad_verification_page.dart';
import '../../../admin/presentation/pages/ad_users_page.dart';
import '../../../admin/presentation/pages/ad_transactions_page.dart';
import '../../../admin/presentation/pages/ad_auctions_page.dart';
import '../../../admin/presentation/pages/ad_complaints_page.dart';

// ─── Route name constants ─────────────────────────────────────────────────────

abstract class AdminRoutes {
  static const login = '/login';
  static const forbidden = '/forbidden';

  // Super Admin
  static const superAdminDashboard = '/super-admin/ringkasan';
  static const superAdminManageAdmins = '/super-admin/manajemen-admin';
  static const superAdminUsers = '/super-admin/manajemen-pengguna';
  static const superAdminReports = '/super-admin/laporan';
  static const superAdminSettings = '/super-admin/pengaturan';
  static const superAdminLogs = '/super-admin/log-aktivitas';

  // Admin
  static const adminDashboard = '/admin/ringkasan';
  static const adminVerification = '/admin/verifikasi-petani';
  static const adminUsers = '/admin/data-pengguna';
  static const adminTransactions = '/admin/transaksi';
  static const adminAuctions = '/admin/lelang';
  static const adminComplaints = '/admin/pengaduan';
}

// ─── Router provider ──────────────────────────────────────────────────────────

final adminRouterProvider = Provider<GoRouter>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: AdminRoutes.login,
    redirect: (context, state) {
      return userAsync.when(
        loading: () => null,
        error: (_, __) => AdminRoutes.login,
        data: (user) {
          final loc = state.matchedLocation;
          final isLoginPage = loc == AdminRoutes.login;

          if (user == null) {
            return isLoginPage ? null : AdminRoutes.login;
          }

          if (!user.role.isAdminPanel) {
            return AdminRoutes.forbidden;
          }

          // Redirect from login to home page
          if (isLoginPage) {
            return user.role == AppRole.superAdmin
                ? AdminRoutes.superAdminDashboard
                : AdminRoutes.adminDashboard;
          }

          // Guard super-admin routes from admin role
          if (loc.startsWith('/super-admin') &&
              user.role != AppRole.superAdmin) {
            return AdminRoutes.forbidden;
          }

          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: AdminRoutes.login,
        builder: (ctx, state) =>
            LoginPage(redirectPath: state.uri.queryParameters['redirect']),
      ),
      GoRoute(
        path: AdminRoutes.forbidden,
        builder: (ctx, state) => const ForbiddenPage(),
      ),

      // ── Super Admin Shell ────────────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => SuperAdminShell(child: child),
        routes: [
          GoRoute(
            path: AdminRoutes.superAdminDashboard,
            builder: (ctx, state) => const SaDashboardPage(),
          ),
          GoRoute(
            path: AdminRoutes.superAdminManageAdmins,
            builder: (ctx, state) => const SaManageAdminsPage(),
          ),
          GoRoute(
            path: AdminRoutes.superAdminUsers,
            builder: (ctx, state) => const SaUsersPage(),
          ),
          GoRoute(
            path: AdminRoutes.superAdminReports,
            builder: (ctx, state) => const SaReportsPage(),
          ),
          GoRoute(
            path: AdminRoutes.superAdminSettings,
            builder: (ctx, state) => const SaSettingsPage(),
          ),
          GoRoute(
            path: AdminRoutes.superAdminLogs,
            builder: (ctx, state) => const SaLogsPage(),
          ),
        ],
      ),

      // ── Admin Shell ──────────────────────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AdminRoutes.adminDashboard,
            builder: (ctx, state) => const AdDashboardPage(),
          ),
          GoRoute(
            path: AdminRoutes.adminVerification,
            builder: (ctx, state) => const AdVerificationPage(),
          ),
          GoRoute(
            path: AdminRoutes.adminUsers,
            builder: (ctx, state) => const AdUsersPage(),
          ),
          GoRoute(
            path: AdminRoutes.adminTransactions,
            builder: (ctx, state) => const AdTransactionsPage(),
          ),
          GoRoute(
            path: AdminRoutes.adminAuctions,
            builder: (ctx, state) => const AdAuctionsPage(),
          ),
          GoRoute(
            path: AdminRoutes.adminComplaints,
            builder: (ctx, state) => const AdComplaintsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
    ),
  );
});
