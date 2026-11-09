// lib/features/admin_web/admin/presentation/pages/ad_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/presentation/widgets/stat_card.dart';
import '../../../shared/presentation/widgets/status_pill.dart';
import '../../../shared/presentation/widgets/avatar_initials.dart';
import '../../data/repositories/admin_mock_repository.dart';
import '../../domain/entities/admin_entities.dart';

final _opsDashProvider = FutureProvider.autoDispose<OpsDashboardStats>(
    (ref) => ref.watch(opsRepositoryProvider).getDashboard());

class AdDashboardPage extends ConsumerWidget {
  const AdDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(_opsDashProvider);

    return dashAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat: $e')),
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ringkasan Operasional',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text('Pengelolaan operasional harian Panenara.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            ]),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Wrap(spacing: 14, runSpacing: 14, children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 190),
                child: StatCard(
                    label: 'Menunggu verifikasi',
                    value: '${stats.pendingVerifications}',
                    subtitle: 'Petani baru',
                    isHero: true),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 190),
                child: StatCard(
                    label: 'Transaksi hari ini',
                    value: '${stats.todayTransactions}',
                    subtitle: 'Rp 212 jt'),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 190),
                child: StatCard(
                    label: 'Lelang berlangsung',
                    value: '${stats.activeAuctions}',
                    subtitle: '23 berakhir hari ini'),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 190),
                child: StatCard(
                    label: 'Pengaduan terbuka',
                    value: '${stats.openComplaints}',
                    subtitle: '3 prioritas tinggi'),
              ),
            ]),
          ),

          // Two column panels
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DataPanel(
                  title: 'Antrean verifikasi petani',
                  child: Column(
                    children: stats.verificationQueue
                        .map((item) => _QueueTile(item: item))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: DataPanel(
                  title: 'Pengaduan terbaru',
                  child: Column(
                    children: stats.recentComplaints
                        .map((item) => _ComplaintTile(item: item))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({required this.item});
  final VerificationQueueItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        AvatarInitials(name: item.name, size: 32),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(item.subtitle,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ]),
        ),
        StatusPill.fromString(item.pillLabel, item.pillVariant),
      ]),
    );
  }
}

class _ComplaintTile extends StatelessWidget {
  const _ComplaintTile({required this.item});
  final ComplaintItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(item.subtitle,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ]),
        ),
        StatusPill.fromString(item.pillLabel, item.pillVariant),
      ]),
    );
  }
}
