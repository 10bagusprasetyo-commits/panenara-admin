// lib/features/admin_web/admin/presentation/pages/ad_transactions_page.dart
// Halaman Monitoring Transaksi untuk peran Admin.
// Fitur: tabel, pencarian, filter status, paginasi, detail dialog.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/widgets/status_pill.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/domain/entities/admin_user.dart';
import '../../data/repositories/admin_mock_repository.dart';
import '../../domain/entities/admin_entities.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class _TxFilter {
  const _TxFilter({this.query = '', this.status});
  final String query;
  final TransactionStatus? status;
  _TxFilter copyWith({String? query, Object? status = _sentinel}) {
    return _TxFilter(
      query: query ?? this.query,
      status: status == _sentinel ? this.status : status as TransactionStatus?,
    );
  }
}

const _sentinel = Object();

final _txFilterProvider =
    StateProvider<_TxFilter>((_) => const _TxFilter());

final _txListProvider =
    FutureProvider.autoDispose<PaginatedResult<Transaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final filter = ref.watch(_txFilterProvider);
  return repo.getTransactions(
    page: 1,
    pageSize: 50,
    status: filter.status,
    q: filter.query.isEmpty ? null : filter.query,
  );
});

// ─── Page ─────────────────────────────────────────────────────────────────────

class AdTransactionsPage extends ConsumerStatefulWidget {
  const AdTransactionsPage({super.key});

  @override
  ConsumerState<AdTransactionsPage> createState() => _AdTransactionsPageState();
}

class _AdTransactionsPageState extends ConsumerState<AdTransactionsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    ref.read(_txFilterProvider.notifier).state =
        ref.read(_txFilterProvider).copyWith(query: q);
  }

  void _onStatusFilter(TransactionStatus? s) {
    ref.read(_txFilterProvider.notifier).state =
        ref.read(_txFilterProvider).copyWith(status: s);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_txListProvider);
    final filter = ref.watch(_txFilterProvider);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Text('Monitoring Transaksi',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Pantau seluruh transaksi penjualan hasil panen',
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
                      hintText: 'Cari ID, pembeli, atau petani…',
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
                _StatusFilterDropdown(
                  value: filter.status,
                  onChanged: _onStatusFilter,
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Refresh',
                  onPressed: () => ref.invalidate(_txListProvider),
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
              error: (e, _) => _ErrorState(message: e.toString(),
                  onRetry: () => ref.invalidate(_txListProvider)),
              data: (result) {
                if (result.data.isEmpty) {
                  return const _EmptyState();
                }
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
                            DataColumn(label: Text('ID Transaksi')),
                            DataColumn(label: Text('Pembeli')),
                            DataColumn(label: Text('Petani')),
                            DataColumn(label: Text('Komoditas')),
                            DataColumn(label: Text('Nilai')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Waktu')),
                            DataColumn(label: Text('Aksi')),
                          ],
                          rows: result.data.map((tx) {
                            return DataRow(cells: [
                              DataCell(Text(tx.id,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600))),
                              DataCell(Text(tx.buyer)),
                              DataCell(Text(tx.farmer)),
                              DataCell(Text(tx.commodity)),
                              DataCell(Text(tx.value,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600))),
                              DataCell(StatusPill.fromString(
                                  tx.statusLabel, tx.statusVariant)),
                              DataCell(Text(tx.createdAt)),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.info_outline,
                                      size: 18),
                                  tooltip: 'Detail',
                                  onPressed: () =>
                                      _showDetail(context, tx),
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

  void _showDetail(BuildContext context, Transaction tx) {
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
                  Text('Detail Transaksi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(height: 24),
              _DetailRow('ID', tx.id),
              _DetailRow('Pembeli', tx.buyer),
              _DetailRow('Petani', tx.farmer),
              _DetailRow('Komoditas', tx.commodity),
              _DetailRow('Nilai', tx.value),
              _DetailRow('Waktu', tx.createdAt),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Status: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  StatusPill.fromString(tx.statusLabel, tx.statusVariant),
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

class _StatusFilterDropdown extends StatelessWidget {
  const _StatusFilterDropdown(
      {required this.value, required this.onChanged});
  final TransactionStatus? value;
  final ValueChanged<TransactionStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<TransactionStatus?>(
        value: value,
        hint: const Text('Semua status'),
        isDense: true,
        items: const [
          DropdownMenuItem(value: null, child: Text('Semua status')),
          DropdownMenuItem(
              value: TransactionStatus.success, child: Text('Berhasil')),
          DropdownMenuItem(
              value: TransactionStatus.awaitingPayment,
              child: Text('Menunggu bayar')),
          DropdownMenuItem(
              value: TransactionStatus.failed, child: Text('Gagal')),
          DropdownMenuItem(
              value: TransactionStatus.dispute, child: Text('Sengketa')),
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
              width: 100,
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
          const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text('Tidak ada transaksi',
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
          Text('Gagal memuat: $message',
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
