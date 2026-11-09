// lib/features/admin_web/admin/presentation/pages/ad_verification_page.dart
// Verifikasi Petani — dengan aksi Setujui / Minta Perbaikan / Tolak

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/presentation/widgets/stat_card.dart';
import '../../../shared/presentation/widgets/status_pill.dart';
import '../../../shared/presentation/widgets/avatar_initials.dart';
import '../../../shared/presentation/widgets/confirm_dialog.dart';
import '../../../shared/presentation/theme/admin_theme.dart';
import '../../../shared/domain/entities/admin_user.dart';
import '../../data/repositories/admin_mock_repository.dart';
import '../../domain/entities/admin_entities.dart';

final _verSearchProvider = StateProvider<String>((_) => '');
final _verStatusFilterProvider = StateProvider<VerificationStatus?>((_) => null);

final _verificationsProvider =
    FutureProvider.autoDispose<PaginatedResult<FarmerVerification>>((ref) {
  final q = ref.watch(_verSearchProvider);
  final status = ref.watch(_verStatusFilterProvider);
  return ref.watch(verificationRepositoryProvider).getVerifications(
        q: q.isEmpty ? null : q,
        status: status,
      );
});

class AdVerificationPage extends ConsumerWidget {
  const AdVerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifAsync = ref.watch(_verificationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Verifikasi Petani',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text('Tinjau dokumen lahan, KTP, dan selfie petani yang mendaftar.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ]),
              ),
            ],
          ),
        ),

        // Stat cards
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Wrap(spacing: 14, runSpacing: 14, children: [
            ConstrainedBox(constraints: const BoxConstraints(minWidth: 190),
              child: const StatCard(label: 'Menunggu', value: '23', subtitle: 'Rata-rata 4 jam', isHero: true)),
            ConstrainedBox(constraints: const BoxConstraints(minWidth: 190),
              child: const StatCard(label: 'Perlu perbaikan', value: '7', subtitle: 'Menunggu petani')),
            ConstrainedBox(constraints: const BoxConstraints(minWidth: 190),
              child: const StatCard(label: 'Disetujui bulan ini', value: '318', subtitle: 'Tingkat lolos 88%')),
            ConstrainedBox(constraints: const BoxConstraints(minWidth: 190),
              child: const StatCard(label: 'Ditolak', value: '12', subtitle: 'Bulan ini')),
          ]),
        ),

        DataPanel(
          child: Column(
            children: [
              Row(children: [
                const Expanded(
                  child: Text('Antrean Verifikasi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                _StatusFilter(
                  value: ref.watch(_verStatusFilterProvider),
                  onChanged: (v) => ref.read(_verStatusFilterProvider.notifier).state = v,
                ),
                const SizedBox(width: 10),
                _SearchBox(onChanged: (v) => ref.read(_verSearchProvider.notifier).state = v),
              ]),
              const SizedBox(height: 12),
              verifAsync.when(
                loading: () => const Padding(padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('Gagal memuat: $e'),
                data: (result) => _VerificationTable(
                  verifications: result.data,
                  onReview: (v) => _showReviewDialog(context, ref, v),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showReviewDialog(
      BuildContext context, WidgetRef ref, FarmerVerification v) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tinjau: ${v.farmerName}'),
        content: SizedBox(
          width: 420,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _InfoRow('Kelompok Tani', v.farmerGroup),
            _InfoRow('Lokasi', v.location),
            _InfoRow('Diajukan', v.submittedAt),
            _InfoRow('Status', v.statusLabel),
            if (v.reviewNote != null) _InfoRow('Catatan', v.reviewNote!),
            const SizedBox(height: 16),
            const Text('Dokumen yang diajukan:',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('KTP, Selfie dengan KTP, Dokumen lahan',
                style: TextStyle(fontSize: 13)),
          ]),
        ),
        actions: [
          if (v.status == VerificationStatus.waiting ||
              v.status == VerificationStatus.needsRevision) ...[
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final reason = await ConfirmDialog.show(
                  context,
                  title: 'Tolak Verifikasi',
                  message: 'Berikan alasan penolakan.',
                  confirmLabel: 'Tolak',
                  variant: ConfirmVariant.danger,
                  requireNote: true,
                  noteLabel: 'Alasan penolakan',
                  notePlaceholder: 'Alasan wajib diisi...',
                  noteRequired: true,
                );
                if (reason != null && reason.isNotEmpty) {
                  await ref.read(verificationRepositoryProvider).reject(id: v.id, reason: reason);
                  ref.invalidate(_verificationsProvider);
                }
              },
              style: TextButton.styleFrom(foregroundColor: AdminColors.bdTxLight),
              child: const Text('Tolak'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final note = await ConfirmDialog.show(
                  context,
                  title: 'Minta Perbaikan',
                  message: 'Tulis catatan untuk petani.',
                  confirmLabel: 'Kirim',
                  variant: ConfirmVariant.warning,
                  requireNote: true,
                  noteLabel: 'Catatan perbaikan',
                  notePlaceholder: 'Contoh: Foto KTP kurang jelas...',
                  noteRequired: true,
                );
                if (note != null && note.isNotEmpty) {
                  await ref.read(verificationRepositoryProvider)
                      .requestRevision(id: v.id, note: note);
                  ref.invalidate(_verificationsProvider);
                }
              },
              style: TextButton.styleFrom(foregroundColor: AdminColors.wnTxLight),
              child: const Text('Minta Perbaikan'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: 'Setujui Verifikasi',
                  message: 'Yakin menyetujui verifikasi ${v.farmerName}?',
                  confirmLabel: 'Setujui',
                );
                if (confirmed != null) {
                  await ref.read(verificationRepositoryProvider).approve(v.id);
                  ref.invalidate(_verificationsProvider);
                }
              },
              child: const Text('Setujui'),
            ),
          ] else
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({this.value, required this.onChanged});
  final VerificationStatus? value;
  final ValueChanged<VerificationStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      height: 40, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.bgDark : AdminColors.bgLight,
        border: Border.all(color: isDark ? AdminColors.lineDark : AdminColors.lineLight),
        borderRadius: BorderRadius.circular(11),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<VerificationStatus?>(
          value: value,
          hint: const Text('Semua status', style: TextStyle(fontSize: 13)),
          style: TextStyle(fontSize: 13, color: isDark ? AdminColors.txDark : AdminColors.txLight),
          items: const [
            DropdownMenuItem(value: null, child: Text('Semua status')),
            DropdownMenuItem(value: VerificationStatus.waiting, child: Text('Menunggu')),
            DropdownMenuItem(value: VerificationStatus.needsRevision, child: Text('Perlu perbaikan')),
            DropdownMenuItem(value: VerificationStatus.verified, child: Text('Terverifikasi')),
            DropdownMenuItem(value: VerificationStatus.rejected, child: Text('Ditolak')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SearchBox extends StatefulWidget {
  const _SearchBox({required this.onChanged});
  final ValueChanged<String> onChanged;
  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  final _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      width: 220, height: 40,
      decoration: BoxDecoration(
        color: isDark ? AdminColors.bgDark : AdminColors.bgLight,
        border: Border.all(color: isDark ? AdminColors.lineDark : AdminColors.lineLight),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(children: [
        const SizedBox(width: 10),
        Icon(Icons.search, size: 16, color: isDark ? AdminColors.mutDark : AdminColors.mutLight),
        const SizedBox(width: 6),
        Expanded(child: TextField(
          controller: _ctrl, onChanged: widget.onChanged,
          decoration: const InputDecoration(hintText: 'Cari...', border: InputBorder.none,
              enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10), isDense: true),
          style: const TextStyle(fontSize: 14),
        )),
      ]),
    );
  }
}

class _VerificationTable extends StatelessWidget {
  const _VerificationTable({required this.verifications, required this.onReview});
  final List<FarmerVerification> verifications;
  final ValueChanged<FarmerVerification> onReview;

  @override
  Widget build(BuildContext context) {
    if (verifications.isEmpty) {
      return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Tidak ada data.')));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 56, dataRowMaxHeight: 56,
        headingTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        columns: const [
          DataColumn(label: Text('Petani')),
          DataColumn(label: Text('Kelompok tani')),
          DataColumn(label: Text('Lokasi')),
          DataColumn(label: Text('Diajukan')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('')),
        ],
        rows: verifications.map((v) => DataRow(cells: [
          DataCell(Row(children: [
            AvatarInitials(name: v.farmerName, size: 30),
            const SizedBox(width: 10),
            Text(v.farmerName, style: const TextStyle(fontWeight: FontWeight.w600)),
          ])),
          DataCell(Text(v.farmerGroup)),
          DataCell(Text(v.location)),
          DataCell(Text(v.submittedAt)),
          DataCell(StatusPill.fromString(v.statusLabel, v.statusVariant)),
          DataCell(TextButton(
            onPressed: () => onReview(v),
            child: Text(v.status == VerificationStatus.verified || v.status == VerificationStatus.rejected
                ? 'Lihat' : 'Tinjau'),
          )),
        ])).toList(),
      ),
    );
  }
}
