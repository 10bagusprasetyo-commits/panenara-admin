// lib/features/admin_web/super_admin/presentation/pages/sa_logs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/presentation/widgets/avatar_initials.dart';
import '../../../shared/presentation/theme/admin_theme.dart';
import '../../data/repositories/super_admin_mock_repository.dart';
import '../../domain/entities/super_admin_entities.dart';
import '../../../shared/domain/entities/admin_user.dart';

final _logSearchProvider = StateProvider<String>((_) => '');
final _logModuleProvider = StateProvider<String?>((_) => null);

final _logsProvider = FutureProvider.autoDispose<PaginatedResult<AuditLog>>((ref) {
  final q = ref.watch(_logSearchProvider);
  final module = ref.watch(_logModuleProvider);
  return ref.watch(auditLogRepositoryProvider).getLogs(
        q: q.isEmpty ? null : q,
        module: module,
      );
});

class SaLogsPage extends ConsumerWidget {
  const SaLogsPage({super.key});

  static const _modules = ['', 'Verifikasi', 'Pengaturan', 'Pengguna', 'Laporan', 'Sistem', 'Autentikasi'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(_logsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Log Aktivitas',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text('Catatan seluruh tindakan admin dan perubahan sistem.',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ]),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Ekspor log'),
              ),
            ],
          ),
        ),

        DataPanel(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Aktivitas Terbaru',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  _ModuleFilter(
                    modules: _modules,
                    value: ref.watch(_logModuleProvider),
                    onChanged: (v) => ref.read(_logModuleProvider.notifier).state = v?.isEmpty == true ? null : v,
                  ),
                  const SizedBox(width: 10),
                  _SearchBox(
                    onChanged: (v) => ref.read(_logSearchProvider.notifier).state = v,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              logsAsync.when(
                loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('Gagal memuat: $e'),
                data: (result) => _LogTable(logs: result.data),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModuleFilter extends StatelessWidget {
  const _ModuleFilter({required this.modules, this.value, required this.onChanged});
  final List<String> modules;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.bgDark : AdminColors.bgLight,
        border: Border.all(color: isDark ? AdminColors.lineDark : AdminColors.lineLight),
        borderRadius: BorderRadius.circular(11),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value ?? '',
          style: TextStyle(
              fontSize: 13, color: isDark ? AdminColors.txDark : AdminColors.txLight),
          items: modules
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m.isEmpty ? 'Semua modul' : m),
                  ))
              .toList(),
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
      width: 220,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AdminColors.bgDark : AdminColors.bgLight,
        border: Border.all(color: isDark ? AdminColors.lineDark : AdminColors.lineLight),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(children: [
        const SizedBox(width: 10),
        Icon(Icons.search, size: 16, color: isDark ? AdminColors.mutDark : AdminColors.mutLight),
        const SizedBox(width: 6),
        Expanded(
          child: TextField(
            controller: _ctrl,
            onChanged: widget.onChanged,
            decoration: const InputDecoration(
              hintText: 'Cari...',
              border: InputBorder.none, enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10), isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ]),
    );
  }
}

class _LogTable extends StatelessWidget {
  const _LogTable({required this.logs});
  final List<AuditLog> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Tidak ada data.')));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 56,
        dataRowMaxHeight: 56,
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 12.5,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        columns: const [
          DataColumn(label: Text('Pengguna')),
          DataColumn(label: Text('Aksi')),
          DataColumn(label: Text('Modul')),
          DataColumn(label: Text('IP')),
          DataColumn(label: Text('Waktu')),
        ],
        rows: logs.map((l) => DataRow(cells: [
          DataCell(Row(children: [
            AvatarInitials(name: l.actor, size: 28),
            const SizedBox(width: 8),
            Text(l.actor, style: const TextStyle(fontWeight: FontWeight.w600)),
          ])),
          DataCell(SizedBox(width: 280, child: Text(l.action, overflow: TextOverflow.ellipsis))),
          DataCell(Text(l.module)),
          DataCell(Text(l.ip, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
          DataCell(Text(l.timestamp)),
        ])).toList(),
      ),
    );
  }
}
