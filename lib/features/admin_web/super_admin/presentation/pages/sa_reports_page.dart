// lib/features/admin_web/super_admin/presentation/pages/sa_reports_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/presentation/widgets/stat_card.dart';
import '../../../shared/presentation/widgets/status_pill.dart';
import '../../../shared/presentation/widgets/simple_bar_chart.dart';
import '../../data/repositories/super_admin_mock_repository.dart';
import '../../domain/entities/super_admin_entities.dart';

final _monthlyProvider = FutureProvider.autoDispose<List<MonthlyVolume>>(
    (ref) => ref.watch(reportRepositoryProvider).getMonthlyVolume());

final _commoditiesProvider = FutureProvider.autoDispose<List<TopCommodity>>(
    (ref) => ref.watch(reportRepositoryProvider).getTopCommodities());

class SaReportsPage extends ConsumerWidget {
  const SaReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyAsync = ref.watch(_monthlyProvider);
    final commoditiesAsync = ref.watch(_commoditiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Laporan Keseluruhan',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    Text('Ringkasan kinerja platform lintas lelang dan investasi tani.',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Unduh laporan'),
              ),
            ],
          ),
        ),

        // Stats
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Wrap(spacing: 14, runSpacing: 14, children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 190),
              child: const StatCard(
                  label: 'Nilai transaksi (Okt)',
                  value: 'Rp 4,82 M',
                  subtitle: '+17%',
                  isHero: true),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 190),
              child: const StatCard(label: 'Lelang selesai', value: '1.208', subtitle: 'Tingkat sukses 91%'),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 190),
              child: const StatCard(label: 'Dana investasi tani', value: 'Rp 1,36 M', subtitle: '64 proyek berjalan'),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 190),
              child: const StatCard(label: 'Pendapatan platform', value: 'Rp 118 jt', subtitle: 'Biaya layanan 2,5%'),
            ),
          ]),
        ),

        // Bar chart
        monthlyAsync.when(
          loading: () => const DataPanel(child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Error: $e'),
          data: (vols) => DataPanel(
            title: 'Nilai transaksi 6 bulan terakhir (Rp juta)',
            child: SimpleBarChart(
              data: vols
                  .map((v) => BarChartData(label: v.month, value: v.valueMillions))
                  .toList(),
              formatValue: (v) => v.toStringAsFixed(0),
            ),
          ),
        ),

        // Top commodities table
        commoditiesAsync.when(
          loading: () => const DataPanel(child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Error: $e'),
          data: (items) => DataPanel(
            title: 'Komoditas Teratas',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                columns: const [
                  DataColumn(label: Text('Komoditas')),
                  DataColumn(label: Text('Volume')),
                  DataColumn(label: Text('Nilai')),
                  DataColumn(label: Text('Pertumbuhan')),
                ],
                rows: items
                    .map((c) => DataRow(cells: [
                          DataCell(Text(c.name,
                              style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(c.volume)),
                          DataCell(Text(c.value)),
                          DataCell(StatusPill(
                            label: c.growth,
                            variant: c.growthPositive ? PillVariant.ok : PillVariant.bad,
                          )),
                        ]))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
