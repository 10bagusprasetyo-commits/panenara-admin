// lib/features/admin_web/shared/presentation/pages/forbidden_page.dart

import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.adminBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.block,
              size: 72,
              color: context.isDark
                  ? AdminColors.bdTxDark
                  : AdminColors.bdTxLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Akses Ditolak',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message ??
                  'Anda tidak memiliki izin untuk membuka halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.adminMuted,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
