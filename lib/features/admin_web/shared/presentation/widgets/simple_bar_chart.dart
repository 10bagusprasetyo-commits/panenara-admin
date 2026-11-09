// lib/features/admin_web/shared/presentation/widgets/simple_bar_chart.dart
// Grafik batang sederhana — kelas .chart dan .bar di HTML

import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

class BarChartData {
  const BarChartData({required this.label, required this.value});
  final String label;
  final double value;
}

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.data,
    this.height = 210,
    this.formatValue,
  });

  final List<BarChartData> data;
  final double height;
  final String Function(double)? formatValue;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final maxVal = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          final isLast = i == data.length - 1;
          final heightPercent = maxVal == 0 ? 0.0 : d.value / maxVal;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    formatValue != null
                        ? formatValue!(d.value)
                        : d.value.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AdminColors.txDark : AdminColors.txLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: heightPercent.clamp(0.02, 1.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 64),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                            bottom: Radius.circular(4),
                          ),
                          gradient: isLast
                              ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [AdminColors.g5, AdminColors.g6],
                                )
                              : null,
                          color: isLast
                              ? null
                              : (isDark ? AdminColors.g2.withOpacity(0.3) : AdminColors.g2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AdminColors.mutDark : AdminColors.mutLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
