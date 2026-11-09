// lib/features/admin_web/super_admin/presentation/pages/sa_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/widgets/stat_card.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/presentation/widgets/status_pill.dart';
import '../../../shared/presentation/widgets/avatar_initials.dart';
import '../../data/repositories/super_admin_mock_repository.dart';
import '../../domain/entities/super_admin_entities.dart';

class SaDashboardPage extends ConsumerWidget {
  const SaDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(_dashboardProvider);

    return dashAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat: $e')),
      data: (stats) => _DashboardContent(stats: stats),
    );
  }
}

final _dashboardProvider = FutureProvider<SuperDashboardStats>((ref) {
  return ref.watch(superAdminRepositoryProvider).getDashboard();
});

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.stats});

  final SuperDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const _PageHeader(
          title: 'Ringkasan Sistem',
          subtitle: 'Kontrol keseluruhan sistem Panenara dalam satu tampilan.',
        ),

        // Stat cards
        _StatsGrid(
          items: [
            (
              label: 'Total pengguna',
              value: '${stats.totalUsers.toLocaleString()}',
              sub: '+312 bulan ini',
              hero: true,
            ),
            (
              label: 'Admin aktif',
              value: '${stats.activeAdmins}',
              sub: '2 Super Admin · 6 Admin',
              hero: false,
            ),
            (
              label: 'Nilai transaksi bulan ini',
              value: stats.monthlyTransactionValue,
              sub: '+17% dari September',
              hero: false,
            ),
            (
              label: 'Lelang aktif',
              value: '${stats.activeAuctions}',
              sub: '23 berakhir hari ini',
              hero: false,
            ),
          ],
        ),

        // Two-column panels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DataPanel(
                title: 'Perlu perhatian',
                child: Column(
                  children: stats.alerts
                      .map((a) => _AlertTile(alert: a))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: DataPanel(
                title: 'Aktivitas terbaru',
                child: Column(
                  children: stats.recentActivities
                      .map((a) => _ActivityTile(activity: a))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.items});

  final List<
      ({
        String label,
        String value,
        String sub,
        bool hero,
      })> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: items.map((item) {
          return ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 190),
            child: StatCard(
              label: item.label,
              value: item.value,
              subtitle: item.sub,
              isHero: item.hero,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final AlertItem alert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  alert.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          StatusPill.fromString(alert.pillLabel, alert.pillVariant),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          AvatarInitials(name: activity.title.split(' ').first, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                if (activity.subtitle != null)
                  Text(
                    activity.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _IntX on int {
  String toLocaleString() {
    final s = toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

