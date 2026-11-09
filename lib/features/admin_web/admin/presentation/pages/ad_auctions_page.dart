// lib/features/admin_web/admin/presentation/pages/ad_auctions_page.dart
// Halaman Monitoring Lelang untuk peran Admin.
// Fitur: tabel, pencarian, filter status, paginasi, detail dialog.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/widgets/status_pill.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/domain/entities/admin_user.dart';
import '../../data/repositories/admin_mock_repository.dart';
import '../../domain/entities/admin_entities.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class _AuctionFilter {
  const _AuctionFilter({this.query = '', this.status});
  final String query;
  final AuctionStatus? status;
  _AuctionFilter copyWith({String? query, Object? status = _sentinel}) {
    return _AuctionFilter(
      query: query ?? this.query,
      status: status == _sentinel ? this.status : status as AuctionStatus?,
    );
  }
}

const _sentinel = Object();

final _auctionFilterProvider =
    StateProvider<_AuctionFilter>((_) => const _AuctionFilter());

final _auctionListProvider =
    FutureProvider.autoDispose<PaginatedResult<Auction>>((ref) async {
  final repo = ref.watch(auctionRepositoryProvider);
  final filter = ref.watch(_auctionFilterProvider);
  return repo.getAuctions(
    page: 1,
    pageSize: 50,
    status: filter.status,
    q: filter.query.isEmpty ? null : filter.query,
  );
});

// ─── Page ─────────────────────────────────────────────────────────────────────

class AdAuctionsPage extends ConsumerStatefulWidget {
  const AdAuctionsPage({super.key});

  @override
  ConsumerState<AdAuctionsPage> createState() => _AdAuctionsPageState();
}

class _AdAuctionsPageState extends ConsumerState<AdAuctionsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    ref.read(_auctionFilterProvider.notifier).state =
        ref.read(_auctionFilterProvider).copyWith(query: q);
  }

  void _onStatusFilter(AuctionStatus? s) {
    ref.read(_auctionFilterProvider.notifier).state =
        ref.read(_auctionFilterProvider).copyWith(status: s);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_auctionListProvider);
    final filter = ref.watch(_auctionFilterProvider);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Text('Monitoring Lelang',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Pantau seluruh lelang panen yang berjalan maupun selesai',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurface.withOpacity(0.6))),
          const SizedBox(height: 20),

          // ── Filter bar ──────────────────────────────────────────────────────
          DataPanel(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Cari judul lelang atau petani…',
                      prefixIcon: Icon(Icons.search, size: 18),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    onSubmitted: _onSearch,
                    onChanged: _onSearch,
                  ),
                ),
                const SizedBox(width: 12),
                _AuctionStatusFilter(
                  value: filter.status,
                  onChanged: _onStatusFilter,
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Refresh',
                  onPressed: () => ref.invalidate(_auctionListProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Table ───────────────────────────────────────────────────────────
          Expanded(
            child: async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(_auctionListProvider)),
              data: (result) {
                if (result.data.isEmpty) return const _EmptyState();
                return DataPanel(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowHeight: 40,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 56,
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Judul Lelang')),
                            DataColumn(label: Text('Petani')),
                            DataColumn(label: Text('Penawaran Tertinggi')),
                            DataColumn(label: Text('Jml. Penawar')),
                            DataColumn(label: Text('Berakhir')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Aksi')),
                          ],
                          rows: result.data.map((a) {
                            return DataRow(cells: [
                              DataCell(Text(a.id,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12))),
                              DataCell(SizedBox(
                                  width: 180,
                                  child: Text(a.title,
                                      overflow: TextOverflow.ellipsis))),
                              DataCell(Text(a.farmer)),
                              DataCell(Text(a.highestBid,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600))),
                              DataCell(Text(a.bidCount.toString())),
                              DataCell(Text(a.endsAt)),
                              DataCell(StatusPill.fromString(
                                  a.statusLabel, a.statusVariant)),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.info_outline,
                                      size: 18),
                                  tooltip: 'Detail',
                                  onPressed: () =>
                                      _showDetail(context, a),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Auction a) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Detail Lelang',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(height: 24),
              _DetailRow('ID', a.id),
              _DetailRow('Judul', a.title),
              _DetailRow('Petani', a.farmer),
              _DetailRow('Penawaran Tertinggi', a.highestBid),
              _DetailRow('Jumlah Penawar', a.bidCount.toString()),
              _DetailRow('Berakhir', a.endsAt),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Status: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  StatusPill.fromString(a.statusLabel, a.statusVariant),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Status filter dropdown ────────────────────────────────────────────────────

class _AuctionStatusFilter extends StatelessWidget {
  const _AuctionStatusFilter({required this.value, required this.onChanged});
  final AuctionStatus? value;
  final ValueChanged<AuctionStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<AuctionStatus?>(
        value: value,
        hint: const Text('Semua status'),
        isDense: true,
        items: const [
          DropdownMenuItem(value: null, child: Text('Semua status')),
          DropdownMenuItem(
              value: AuctionStatus.activeBidding,
              child: Text('Sedang ditawar')),
          DropdownMenuItem(
              value: AuctionStatus.awaitingPayment,
              child: Text('Menunggu pembayaran')),
          DropdownMenuItem(
              value: AuctionStatus.ended, child: Text('Selesai')),
          DropdownMenuItem(
              value: AuctionStatus.cancelled, child: Text('Dibatalkan')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 140,
              child: Text(label,
                  style: TextStyle(
                      color: cs.onSurface.withOpacity(0.6), fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gavel_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text('Tidak ada lelang',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text('Gagal memuat: $message', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
