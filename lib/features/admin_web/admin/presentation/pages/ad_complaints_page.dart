// lib/features/admin_web/admin/presentation/pages/ad_complaints_page.dart
// Halaman Pengaduan Pengguna untuk peran Admin.
// Fitur: tabel, filter status & prioritas, pencarian, detail + reply dialog.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/widgets/status_pill.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/presentation/widgets/confirm_dialog.dart';
import '../../../shared/domain/entities/admin_user.dart';
import '../../data/repositories/admin_mock_repository.dart';
import '../../domain/entities/admin_entities.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class _ComplaintFilter {
  const _ComplaintFilter({this.query = '', this.status, this.priority});
  final String query;
  final ComplaintStatus? status;
  final ComplaintPriority? priority;

  _ComplaintFilter copyWith({
    String? query,
    Object? status = _sentinel,
    Object? priority = _sentinel,
  }) {
    return _ComplaintFilter(
      query: query ?? this.query,
      status: status == _sentinel ? this.status : status as ComplaintStatus?,
      priority: priority == _sentinel
          ? this.priority
          : priority as ComplaintPriority?,
    );
  }
}

const _sentinel = Object();

final _complaintFilterProvider =
    StateProvider<_ComplaintFilter>((_) => const _ComplaintFilter());

final _complaintListProvider =
    FutureProvider.autoDispose<PaginatedResult<Complaint>>((ref) async {
  final repo = ref.watch(complaintRepositoryProvider);
  final filter = ref.watch(_complaintFilterProvider);
  return repo.getComplaints(
    page: 1,
    pageSize: 50,
    status: filter.status,
    priority: filter.priority,
    q: filter.query.isEmpty ? null : filter.query,
  );
});

// ─── Page ─────────────────────────────────────────────────────────────────────

class AdComplaintsPage extends ConsumerStatefulWidget {
  const AdComplaintsPage({super.key});

  @override
  ConsumerState<AdComplaintsPage> createState() =>
      _AdComplaintsPageState();
}

class _AdComplaintsPageState extends ConsumerState<AdComplaintsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    ref.read(_complaintFilterProvider.notifier).state =
        ref.read(_complaintFilterProvider).copyWith(query: q);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_complaintListProvider);
    final filter = ref.watch(_complaintFilterProvider);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Text('Pengaduan Pengguna',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Tinjau dan tindaklanjuti pengaduan dari petani, pembeli, dan pengamat',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurface.withOpacity(0.6))),
          const SizedBox(height: 20),

          // ── Filter bar ──────────────────────────────────────────────────────
          DataPanel(
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Cari ID atau ringkasan…',
                      prefixIcon: Icon(Icons.search, size: 18),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                    ),
                    onSubmitted: _onSearch,
                    onChanged: _onSearch,
                  ),
                ),
                _ComplaintStatusFilter(
                  value: filter.status,
                  onChanged: (s) => ref
                      .read(_complaintFilterProvider.notifier)
                      .state = filter.copyWith(status: s),
                ),
                _PriorityFilter(
                  value: filter.priority,
                  onChanged: (p) => ref
                      .read(_complaintFilterProvider.notifier)
                      .state = filter.copyWith(priority: p),
                ),
                IconButton.outlined(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Refresh',
                  onPressed: () => ref.invalidate(_complaintListProvider),
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
                  onRetry: () => ref.invalidate(_complaintListProvider)),
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
                            DataColumn(label: Text('Pelapor')),
                            DataColumn(label: Text('Kategori')),
                            DataColumn(label: Text('Ringkasan')),
                            DataColumn(label: Text('Prioritas')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Aksi')),
                          ],
                          rows: result.data.map((c) {
                            return DataRow(cells: [
                              DataCell(Text(c.id,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12))),
                              DataCell(Text(c.reporterRole)),
                              DataCell(Text(c.category)),
                              DataCell(SizedBox(
                                  width: 200,
                                  child: Text(c.summary,
                                      overflow: TextOverflow.ellipsis))),
                              DataCell(StatusPill.fromString(
                                  c.priorityLabel, c.priorityVariant)),
                              DataCell(StatusPill.fromString(
                                  c.statusLabel, c.statusVariant)),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new,
                                        size: 18),
                                    tooltip: 'Detail & Tindaklanjut',
                                    onPressed: () =>
                                        _showDetail(context, c),
                                  ),
                                ],
                              )),
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

  // ─── Detail Dialog ──────────────────────────────────────────────────────────

  void _showDetail(BuildContext context, Complaint c) {
    showDialog(
      context: context,
      builder: (_) => _ComplaintDetailDialog(
        complaint: c,
        onUpdated: () => ref.invalidate(_complaintListProvider),
      ),
    );
  }
}

// ─── Complaint Detail Dialog ─────────────────────────────────────────────────

class _ComplaintDetailDialog extends ConsumerStatefulWidget {
  const _ComplaintDetailDialog({
    required this.complaint,
    required this.onUpdated,
  });
  final Complaint complaint;
  final VoidCallback onUpdated;

  @override
  ConsumerState<_ComplaintDetailDialog> createState() =>
      _ComplaintDetailDialogState();
}

class _ComplaintDetailDialogState
    extends ConsumerState<_ComplaintDetailDialog> {
  late Complaint _complaint;
  final _replyCtrl = TextEditingController();
  bool _sendingReply = false;
  bool _updatingStatus = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final body = _replyCtrl.text.trim();
    if (body.isEmpty) return;
    setState(() {
      _sendingReply = true;
      _error = null;
    });
    try {
      final repo = ref.read(complaintRepositoryProvider);
      final reply = await repo.addReply(
          complaintId: _complaint.id, body: body);
      setState(() {
        _complaint = Complaint(
          id: _complaint.id,
          reporterRole: _complaint.reporterRole,
          category: _complaint.category,
          summary: _complaint.summary,
          priority: _complaint.priority,
          status: _complaint.status,
          assignedTo: _complaint.assignedTo,
          replies: [..._complaint.replies, reply],
        );
        _replyCtrl.clear();
      });
      widget.onUpdated();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _sendingReply = false);
    }
  }

  Future<void> _updateStatus(ComplaintStatus newStatus) async {
    final label = switch (newStatus) {
      ComplaintStatus.inProgress => 'Proses',
      ComplaintStatus.resolved => 'Selesaikan',
      ComplaintStatus.escalated => 'Eskalasi',
      _ => 'Ubah',
    };
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Ubah Status Pengaduan',
      message:
          'Apakah Anda yakin ingin mengubah status pengaduan ${_complaint.id} menjadi "$label"?',
      confirmLabel: label,
    );
    if (confirm == null) return;

    setState(() {
      _updatingStatus = true;
      _error = null;
    });
    try {
      final repo = ref.read(complaintRepositoryProvider);
      final updated = await repo.updateComplaint(
          id: _complaint.id, status: newStatus);
      setState(() => _complaint = updated);
      widget.onUpdated();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _updatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text('Pengaduan ${_complaint.id}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 20),

            // Info rows
            Row(
              children: [
                _InfoChip('Pelapor', _complaint.reporterRole),
                const SizedBox(width: 12),
                _InfoChip('Kategori', _complaint.category),
                const SizedBox(width: 12),
                StatusPill.fromString(
                    _complaint.priorityLabel, _complaint.priorityVariant),
                const SizedBox(width: 8),
                StatusPill.fromString(
                    _complaint.statusLabel, _complaint.statusVariant),
              ],
            ),
            const SizedBox(height: 12),
            Text('Ringkasan', style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(0.7),
                fontSize: 12)),
            const SizedBox(height: 4),
            Text(_complaint.summary),
            const Divider(height: 20),

            // Status actions
            if (_updatingStatus)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 8,
                children: [
                  if (_complaint.status != ComplaintStatus.inProgress)
                    OutlinedButton.icon(
                      onPressed: () =>
                          _updateStatus(ComplaintStatus.inProgress),
                      icon: const Icon(Icons.autorenew, size: 16),
                      label: const Text('Proses'),
                    ),
                  if (_complaint.status != ComplaintStatus.resolved)
                    OutlinedButton.icon(
                      onPressed: () =>
                          _updateStatus(ComplaintStatus.resolved),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Selesaikan'),
                    ),
                  if (_complaint.status != ComplaintStatus.escalated)
                    OutlinedButton.icon(
                      onPressed: () =>
                          _updateStatus(ComplaintStatus.escalated),
                      icon: const Icon(Icons.warning_amber_outlined,
                          size: 16),
                      label: const Text('Eskalasi'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.error),
                    ),
                ],
              ),
            const SizedBox(height: 12),

            // Replies list
            Text('Riwayat Balasan (${_complaint.replies.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Expanded(
              child: _complaint.replies.isEmpty
                  ? Center(
                      child: Text('Belum ada balasan',
                          style: TextStyle(
                              color: cs.onSurface.withOpacity(0.5))))
                  : ListView.builder(
                      itemCount: _complaint.replies.length,
                      itemBuilder: (_, i) {
                        final r = _complaint.replies[i];
                        return _ReplyBubble(
                            author: r.author,
                            body: r.body,
                            createdAt: r.createdAt);
                      }),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12)),
            ],

            // Reply input
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Tulis balasan untuk pelapor…',
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendingReply ? null : _sendReply,
                  child: _sendingReply
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Kirim'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  const _ReplyBubble(
      {required this.author, required this.body, required this.createdAt});
  final String author;
  final String body;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(author,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 8),
              Text(createdAt,
                  style: TextStyle(
                      color: cs.onSurface.withOpacity(0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _ComplaintStatusFilter extends StatelessWidget {
  const _ComplaintStatusFilter(
      {required this.value, required this.onChanged});
  final ComplaintStatus? value;
  final ValueChanged<ComplaintStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<ComplaintStatus?>(
        value: value,
        hint: const Text('Semua status'),
        isDense: true,
        items: const [
          DropdownMenuItem(value: null, child: Text('Semua status')),
          DropdownMenuItem(
              value: ComplaintStatus.open, child: Text('Terbuka')),
          DropdownMenuItem(
              value: ComplaintStatus.inProgress, child: Text('Diproses')),
          DropdownMenuItem(
              value: ComplaintStatus.resolved, child: Text('Selesai')),
          DropdownMenuItem(
              value: ComplaintStatus.escalated, child: Text('Eskalasi')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _PriorityFilter extends StatelessWidget {
  const _PriorityFilter({required this.value, required this.onChanged});
  final ComplaintPriority? value;
  final ValueChanged<ComplaintPriority?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<ComplaintPriority?>(
        value: value,
        hint: const Text('Semua prioritas'),
        isDense: true,
        items: const [
          DropdownMenuItem(value: null, child: Text('Semua prioritas')),
          DropdownMenuItem(
              value: ComplaintPriority.high, child: Text('Tinggi')),
          DropdownMenuItem(
              value: ComplaintPriority.medium, child: Text('Sedang')),
          DropdownMenuItem(
              value: ComplaintPriority.low, child: Text('Rendah')),
        ],
        onChanged: onChanged,
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
          const Icon(Icons.support_agent_outlined,
              size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text('Tidak ada pengaduan',
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
