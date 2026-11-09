// lib/features/admin_web/admin/presentation/pages/ad_users_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/presentation/widgets/status_pill.dart';
import '../../../shared/presentation/widgets/avatar_initials.dart';
import '../../../shared/presentation/theme/admin_theme.dart';
import '../../../shared/domain/entities/admin_user.dart';
// Reuse super_admin user mock for now (same data layer)
import '../../../super_admin/data/repositories/super_admin_mock_repository.dart';
import '../../../super_admin/domain/entities/super_admin_entities.dart';

final _adUserSearchProvider = StateProvider<String>((_) => '');

final _adUsersProvider = FutureProvider.autoDispose<PaginatedResult<AppUser>>((ref) {
  final q = ref.watch(_adUserSearchProvider);
  return ref.watch(superUserRepositoryProvider).getUsers(q: q.isEmpty ? null : q);
});

class AdUsersPage extends ConsumerWidget {
  const AdUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(_adUsersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Data Pengguna',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text('Daftar pengguna untuk kebutuhan operasional dan layanan.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            ])),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Ekspor data'),
            ),
          ]),
        ),

        DataPanel(
          child: Column(children: [
            Row(children: [
              const Expanded(child: Text('Semua Pengguna',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              _SearchBox(onChanged: (v) => ref.read(_adUserSearchProvider.notifier).state = v),
            ]),
            const SizedBox(height: 12),
            usersAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Gagal memuat: $e'),
              data: (result) => _UsersTable(users: result.data),
            ),
          ]),
        ),
      ],
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
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
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
        Expanded(child: TextField(controller: _ctrl, onChanged: widget.onChanged,
          decoration: const InputDecoration(hintText: 'Cari...', border: InputBorder.none,
              enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10), isDense: true),
          style: const TextStyle(fontSize: 14))),
      ]),
    );
  }
}

class _UsersTable extends StatelessWidget {
  const _UsersTable({required this.users});
  final List<AppUser> users;

  String _statusLabel(UserStatus s) => switch (s) {
        UserStatus.active => 'Terverifikasi',
        UserStatus.pending => 'Menunggu',
        UserStatus.suspended => 'Ditangguhkan',
        UserStatus.inactive => 'Nonaktif',
      };

  PillVariant _statusVariant(UserStatus s) => switch (s) {
        UserStatus.active => PillVariant.ok,
        UserStatus.pending => PillVariant.warning,
        UserStatus.suspended => PillVariant.bad,
        UserStatus.inactive => PillVariant.muted,
      };

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Tidak ada data.')));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40, dataRowMinHeight: 56, dataRowMaxHeight: 56,
        headingTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        columns: const [
          DataColumn(label: Text('Nama')),
          DataColumn(label: Text('Peran')),
          DataColumn(label: Text('Wilayah')),
          DataColumn(label: Text('Verifikasi')),
          DataColumn(label: Text('Terakhir aktif')),
        ],
        rows: users.map((u) => DataRow(cells: [
          DataCell(Row(children: [
            AvatarInitials(name: u.name, size: 30),
            const SizedBox(width: 10),
            Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          ])),
          DataCell(Text(u.roleLabel)),
          DataCell(Text(u.region)),
          DataCell(StatusPill(label: _statusLabel(u.status), variant: _statusVariant(u.status))),
          DataCell(Text(u.joinedAt)),
        ])).toList(),
      ),
    );
  }
}
