// lib/features/admin_web/shared/presentation/widgets/data_panel.dart
// Panel kartu putih dengan border radius — kelas .pn di HTML

import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

class DataPanel extends StatelessWidget {
  const DataPanel({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.cardDark : AdminColors.cardLight,
        border: Border.all(
          color: isDark ? AdminColors.lineDark : AdminColors.lineLight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || trailing != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}
