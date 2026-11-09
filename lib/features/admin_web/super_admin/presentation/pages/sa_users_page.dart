// lib/features/admin_web/super_admin/presentation/pages/sa_users_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/presentation/widgets/status_pill.dart';
import '../../../shared/presentation/widgets/avatar_initials.dart';
import '../../../shared/presentation/widgets/stat_card.dart';
import '../../../shared/presentation/theme/admin_theme.dart';
import '../../../shared/domain/entities/admin_user.dart';
import '../../data/repositories/super_admin_mock_repository.dart';
import '../../domain/entities/super_admin_entities.dart';

final _userSearchProvider = StateProvider<String>((_) => '');
final _userRoleFilterProvider = StateProvider<UserRole?>((_) => null);

final _usersProvider = FutureProvider.autoDispose<PaginatedResult<AppUser>>((ref) {
  final q = ref.watch(_userSearchProvider);
  final role = ref.watch(_userRoleFilterProvider);
  return ref.watch(superUserRepositoryProvider).getUsers(
        q: q.isEmpty ? null : q,
        role: role,
      );
});

class SaUsersPage extends ConsumerWidget {
  const SaUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(_usersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, ref),

        // Stat cards
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 190),
                child: const StatCard(label: 'Petani', value: '4.120', subtitle: '318 menunggu verifikasi', isHero: true),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 190),
                child: const StatCard(label: 'Pembeli', value: '2.860', subtitle: 'Grosir & industri'),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 190),
                child: const StatCard(label: 'Pengamat', value: '5.500', subtitle: 'Belum berinvestasi'),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 190),
                child: const StatCard(label: 'Ditangguhkan', value: '37', subtitle: 'Perlu ditinjau'),
              ),
            ],
          ),
        ),

        // Table
        DataPanel(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Semua Pengguna',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  _RoleFilter(
                    value: ref.watch(_userRoleFilterProvider),
                    onChanged: (v) => ref.read(_userRoleFilterProvider.notifier).state = v,
                  ),
                  const SizedBox(width: 10),
                  _SearchBox(
                    onChanged: (v) => ref.read(_userSearchProvider.notifier).state = v,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              usersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Gagal memuat: $e'),
                data: (result) => _UsersTable(users: result.data, onDetail: (_) {}),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manajemen Pengguna',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                const SizedBox(height: 4),
                Text('Kelola seluruh akun petani, pembeli, dan pengamat.',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Ekspor data'),
          ),
        ],
      ),
    );
  }
}

class _RoleFilter extends StatelessWidget {
  const _RoleFilter({this.value, required this.onChanged});
  final UserRole? value;
  final ValueChanged<UserRole?> onChanged;

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
        child: DropdownButton<UserRole?>(
          value: value,
          hint: const Text('Semua peran', style: TextStyle(fontSize: 13)),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AdminColors.txDark : AdminColors.txLight,
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Semua peran')),
            DropdownMenuItem(value: UserRole.petani, child: Text('Petani')),
            DropdownMenuItem(value: UserRole.pembeli, child: Text('Pembeli')),
            DropdownMenuItem(value: UserRole.pengamat, child: Text('Pengamat')),
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

class _UsersTable extends StatelessWidget {
  const _UsersTable({required this.users, required this.onDetail});
  final List<AppUser> users;
  final ValueChanged<AppUser> onDetail;

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
    if (users.isEmpty) {
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
          DataColumn(label: Text('Nama')),
          DataColumn(label: Text('Peran')),
          DataColumn(label: Text('Wilayah')),
          DataColumn(label: Text('Bergabung')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('')),
        ],
        rows: users.map((u) => DataRow(cells: [
          DataCell(Row(children: [
            AvatarInitials(name: u.name, size: 30),
            const SizedBox(width: 10),
            Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          ])),
          DataCell(Text(u.roleLabel)),
          DataCell(Text(u.region)),
          DataCell(Text(u.joinedAt)),
          DataCell(StatusPill(label: _statusLabel(u.status), variant: _statusVariant(u.status))),
          DataCell(TextButton(onPressed: () => onDetail(u), child: const Text('Detail'))),
        ])).toList(),
      ),
    );
  }
}
