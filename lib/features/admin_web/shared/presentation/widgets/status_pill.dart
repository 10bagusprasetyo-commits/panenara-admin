// lib/features/admin_web/shared/presentation/widgets/status_pill.dart
// Badge status berwarna sesuai desain HTML:
//   .p.ok → hijau  |  .p.wn → kuning  |  .p.bd → merah  |  .p.mt → abu

import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

enum PillVariant { ok, warning, bad, muted }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.variant,
  });

  final String label;
  final PillVariant variant;

  static StatusPill fromString(String label, String variantStr) {
    final v = switch (variantStr) {
      'ok' => PillVariant.ok,
      'wn' => PillVariant.warning,
      'bd' => PillVariant.bad,
      _ => PillVariant.muted,
    };
    return StatusPill(label: label, variant: v);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final (bg, fg) = switch (variant) {
      PillVariant.ok => isDark
          ? (AdminColors.okBgDark, AdminColors.okTxDark)
          : (AdminColors.okBgLight, AdminColors.okTxLight),
      PillVariant.warning => isDark
          ? (AdminColors.wnBgDark, AdminColors.wnTxDark)
          : (AdminColors.wnBgLight, AdminColors.wnTxLight),
      PillVariant.bad => isDark
          ? (AdminColors.bdBgDark, AdminColors.bdTxDark)
          : (AdminColors.bdBgLight, AdminColors.bdTxLight),
      PillVariant.muted => isDark
          ? (AdminColors.mtBgDark, AdminColors.mtTxDark)
          : (AdminColors.mtBgLight, AdminColors.mtTxLight),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
