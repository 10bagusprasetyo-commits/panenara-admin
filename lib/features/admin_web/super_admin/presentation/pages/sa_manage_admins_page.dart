// lib/features/admin_web/super_admin/presentation/pages/sa_manage_admins_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/presentation/widgets/status_pill.dart';
import '../../../shared/presentation/widgets/avatar_initials.dart';
import '../../../shared/presentation/widgets/confirm_dialog.dart';
import '../../../shared/presentation/theme/admin_theme.dart';
import '../../../shared/domain/entities/admin_user.dart';
import '../../data/repositories/super_admin_mock_repository.dart';
import '../../domain/entities/super_admin_entities.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final _searchProvider = StateProvider<String>((_) => '');

final _adminsProvider = FutureProvider.autoDispose<PaginatedResult<AdminAccount>>((ref) {
  final q = ref.watch(_searchProvider);
  return ref.watch(adminManagementRepositoryProvider).getAdmins(q: q.isEmpty ? null : q);
});

// ─── Page ────────────────────────────────────────────────────────────────────

class SaManageAdminsPage extends ConsumerWidget {
  const SaManageAdminsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsAsync = ref.watch(_adminsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeader(
          title: 'Manajemen Admin',
          subtitle: 'Akses berdasarkan peran. Setiap peran membuka menu dan fitur tertentu.',
          action: FilledButton.icon(
            onPressed: () => _showAddAdminDialog(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Admin'),
          ),
        ),

        // Role cards
        adminsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (result) => _RoleCards(admins: result.data),
        ),

        // Table
        DataPanel(
          child: Column(
            children: [
              // Tools row
              Row(
                children: [
                  const Expanded(
                    child: Text('Akun Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  _SearchField(
                    onChanged: (v) => ref.read(_searchProvider.notifier).state = v,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              adminsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Gagal memuat: $e', style: const TextStyle(color: Colors.red)),
                ),
                data: (result) => _AdminTable(
                  admins: result.data,
                  onManage: (admin) => _showManageAdminDialog(context, ref, admin),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAddAdminDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    var selectedRole = AdminRole.admin;
    var selectedAccess = 'Verifikasi & pengaduan';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Tambah Admin Baru'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama lengkap'),
                    validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passCtrl,
                    decoration: const InputDecoration(labelText: 'Kata sandi awal'),
                    obscureText: true,
                    validator: (v) =>
                        (v?.length ?? 0) < 8 ? 'Min. 8 karakter' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<AdminRole>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Peran'),
                    items: const [
                      DropdownMenuItem(value: AdminRole.admin, child: Text('Admin')),
                      DropdownMenuItem(value: AdminRole.superAdmin, child: Text('Super Admin')),
                    ],
                    onChanged: (v) => setState(() => selectedRole = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  await ref.read(adminManagementRepositoryProvider).createAdmin(
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    role: selectedRole,
                    accessLevel: selectedAccess,
                    password: passCtrl.text,
                  );
                  ref.invalidate(_adminsProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showManageAdminDialog(
      BuildContext context, WidgetRef ref, AdminAccount admin) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Kelola ${admin.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.toggle_off_outlined),
              title: Text(admin.status == UserStatus.active
                  ? 'Nonaktifkan akun'
                  : 'Aktifkan akun'),
              onTap: () => Navigator.pop(ctx, 'toggle_status'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (result == 'toggle_status' && context.mounted) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: admin.status == UserStatus.active
            ? 'Nonaktifkan Admin'
            : 'Aktifkan Admin',
        message:
            'Yakin ingin ${admin.status == UserStatus.active ? 'menonaktifkan' : 'mengaktifkan'} akun ${admin.name}?',
        confirmLabel: admin.status == UserStatus.active ? 'Nonaktifkan' : 'Aktifkan',
        variant: admin.status == UserStatus.active
            ? ConfirmVariant.danger
            : ConfirmVariant.primary,
      );
      if (confirmed != null) {
        final newStatus = admin.status == UserStatus.active
            ? UserStatus.inactive
            : UserStatus.active;
        await ref.read(adminManagementRepositoryProvider).setAdminStatus(
              id: admin.id,
              status: newStatus,
            );
        ref.invalidate(_adminsProvider);
      }
    }
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle, this.action});
  final String title;
  final String subtitle;
  final Widget? action;

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
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 16), action!],
        ],
      ),
    );
  }
}

class _RoleCards extends StatelessWidget {
  const _RoleCards({required this.admins});
  final List<AdminAccount> admins;

  @override
  Widget build(BuildContext context) {
    final superAdmins = admins.where((a) => a.role == AdminRole.superAdmin).toList();
    final regularAdmins = admins.where((a) => a.role == AdminRole.admin).toList();

    return DataPanel(
      title: 'Peran dan Akses',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _RoleGroup(title: 'Super Admin', admins: superAdmins)),
          const SizedBox(width: 16),
          Expanded(child: _RoleGroup(title: 'Admin', admins: regularAdmins)),
        ],
      ),
    );
  }
}

class _RoleGroup extends StatelessWidget {
  const _RoleGroup({required this.title, required this.admins});
  final String title;
  final List<AdminAccount> admins;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.bgDark : AdminColors.bgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          ...admins.map((a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    AvatarInitials(name: a.name, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                          Text(a.email,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    StatusPill(
                      label: a.status == UserStatus.active ? 'Aktif' : 'Nonaktif',
                      variant: a.status == UserStatus.active ? PillVariant.ok : PillVariant.muted,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      width: 240,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AdminColors.bgDark : AdminColors.bgLight,
        border: Border.all(color: isDark ? AdminColors.lineDark : AdminColors.lineLight),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(Icons.search, size: 16, color: isDark ? AdminColors.mutDark : AdminColors.mutLight),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                hintText: 'Cari...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: widget.onChanged,
            ),
          ),
          if (_ctrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                widget.onChanged('');
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminTable extends StatelessWidget {
  const _AdminTable({required this.admins, required this.onManage});
  final List<AdminAccount> admins;
  final ValueChanged<AdminAccount> onManage;

  @override
  Widget build(BuildContext context) {
    if (admins.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('Tidak ada data yang cocok.')),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 56,
        dataRowMaxHeight: 56,
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        columns: const [
          DataColumn(label: Text('Akun')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Peran')),
          DataColumn(label: Text('Akses')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('')),
        ],
        rows: admins.map((a) => DataRow(cells: [
          DataCell(Row(children: [
            AvatarInitials(name: a.name, size: 30),
            const SizedBox(width: 10),
            Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          ])),
          DataCell(Text(a.email)),
          DataCell(Text(a.role == AdminRole.superAdmin ? 'Super Admin' : 'Admin')),
          DataCell(Text(a.access)),
          DataCell(StatusPill(
            label: a.status == UserStatus.active ? 'Aktif' : 'Nonaktif',
            variant: a.status == UserStatus.active ? PillVariant.ok : PillVariant.muted,
          )),
          DataCell(TextButton(
            onPressed: () => onManage(a),
            child: const Text('Kelola'),
          )),
        ])).toList(),
      ),
    );
  }
}
