// lib/features/admin_web/super_admin/presentation/pages/sa_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/widgets/data_panel.dart';
import '../../../shared/presentation/widgets/setting_toggle.dart';
import '../../../shared/presentation/widgets/confirm_dialog.dart';
import '../../../shared/presentation/theme/admin_theme.dart';
import '../../data/repositories/super_admin_mock_repository.dart';
import '../../domain/entities/super_admin_entities.dart';

final _settingsProvider = FutureProvider.autoDispose<List<SystemSetting>>(
    (ref) => ref.watch(settingsRepositoryProvider).getSettings());

// Local state for in-flight edits before saving
final _pendingChangesProvider =
    StateProvider<Map<String, dynamic>>((_) => {});

class SaSettingsPage extends ConsumerWidget {
  const SaSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(_settingsProvider);
    final pending = ref.watch(_pendingChangesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pengaturan Sistem',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text('Atur kebijakan platform, keamanan, dan parameter lelang.',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ]),
              ),
              if (pending.isNotEmpty)
                FilledButton(
                  onPressed: () => _saveSettings(context, ref, pending),
                  child: const Text('Simpan perubahan'),
                ),
            ],
          ),
        ),

        settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Gagal memuat: $e'),
          data: (settings) {
            final toggles = settings.where((s) => s.isBool).toList();
            final params = settings.where((s) => !s.isBool).toList();

            return Column(
              children: [
                DataPanel(
                  title: 'Keamanan dan Fitur',
                  child: Column(
                    children: toggles.map((s) {
                      final currentVal = pending.containsKey(s.key)
                          ? pending[s.key] as bool
                          : s.asBool;
                      return SettingToggle(
                        title: s.label,
                        subtitle: s.description,
                        value: currentVal,
                        onChanged: (v) {
                          final updated = Map<String, dynamic>.from(pending);
                          updated[s.key] = v;
                          ref.read(_pendingChangesProvider.notifier).state = updated;
                        },
                      );
                    }).toList(),
                  ),
                ),
                DataPanel(
                  title: 'Parameter Lelang',
                  child: Column(
                    children: params.map((s) {
                      final currentVal = pending[s.key]?.toString() ?? s.asString;
                      return _ParameterRow(
                        label: s.label,
                        value: currentVal,
                        onChanged: (v) {
                          final updated = Map<String, dynamic>.from(pending);
                          updated[s.key] = v;
                          ref.read(_pendingChangesProvider.notifier).state = updated;
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _saveSettings(
      BuildContext context, WidgetRef ref, Map<String, dynamic> pending) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Simpan Perubahan',
      message: 'Perubahan pengaturan sistem akan langsung berlaku. Lanjutkan?',
      confirmLabel: 'Simpan',
    );
    if (confirmed != null) {
      await ref.read(settingsRepositoryProvider).updateSettings(pending);
      ref.invalidate(_settingsProvider);
      ref.read(_pendingChangesProvider.notifier).state = {};
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan berhasil disimpan.')),
        );
      }
    }
  }
}

class _ParameterRow extends StatefulWidget {
  const _ParameterRow({required this.label, required this.value, required this.onChanged});
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_ParameterRow> createState() => _ParameterRowState();
}

class _ParameterRowState extends State<_ParameterRow> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final lineColor = isDark ? AdminColors.lineDark : AdminColors.lineLight;
    final mutedColor = isDark ? AdminColors.mutDark : AdminColors.mutLight;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: lineColor))),
      child: Row(
        children: [
          Expanded(
            child: Text(widget.label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 180,
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                filled: true,
                fillColor: isDark ? AdminColors.bgDark : AdminColors.bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: lineColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: lineColor),
                ),
                hintStyle: TextStyle(color: mutedColor),
              ),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
