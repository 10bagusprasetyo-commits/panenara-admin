// lib/features/admin_web/shared/presentation/widgets/avatar_initials.dart

import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

class AvatarInitials extends StatelessWidget {
  const AvatarInitials({
    super.key,
    required this.name,
    this.size = 34,
  });

  final String name;
  final double size;

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final s = name.trim();
    return s.substring(0, s.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AdminColors.g2.withOpacity(0.3) : AdminColors.g2,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: TextStyle(
          color: isDark ? AdminColors.sbtDark : AdminColors.g9,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}
