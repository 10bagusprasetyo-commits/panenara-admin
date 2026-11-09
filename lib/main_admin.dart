// lib/main_admin.dart
// Dedicated entry point for the Admin Web Panel.
// Run with:
//   flutter run -d chrome --dart-define=USE_MOCK=true
//   flutter run -d chrome --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.panenara.id/v1

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/admin_web/shared/presentation/theme/admin_theme.dart';
import 'features/admin_web/shared/presentation/router/admin_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PanenaraAdminApp(),
    ),
  );
}

class PanenaraAdminApp extends ConsumerWidget {
  const PanenaraAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);
    return MaterialApp.router(
      title: 'Panenara Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.light(),
      darkTheme: AdminTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) => child ?? const SizedBox.shrink(),
    );
  }
}
