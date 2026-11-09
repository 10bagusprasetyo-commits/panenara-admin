// lib/features/admin_web/shared/presentation/widgets/stat_card.dart
// Kartu statistik — sesuai class .st dan .st.hero di HTML desain

import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    this.isHero = false,
  });

  final String label;
  final String value;
  final String subtitle;
  final bool isHero;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    if (isHero) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3aa768), AdminColors.g6],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _CardContent(
          label: label,
          value: value,
          subtitle: subtitle,
          labelColor: const Color(0xFFeaf6ea),
          valueColor: Colors.white,
          subtitleColor: const Color(0xFFeaf6ea),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.cardDark : AdminColors.cardLight,
        border: Border.all(
          color: isDark ? AdminColors.lineDark : AdminColors.lineLight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _CardContent(
        label: label,
        value: value,
        subtitle: subtitle,
        labelColor: isDark ? AdminColors.mutDark : AdminColors.mutLight,
        valueColor: isDark ? AdminColors.txDark : AdminColors.txLight,
        subtitleColor: isDark ? AdminColors.okTxDark : AdminColors.okTxLight,
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.labelColor,
    required this.valueColor,
    required this.subtitleColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color labelColor;
  final Color valueColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: labelColor)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }
}
