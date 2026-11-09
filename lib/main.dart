// lib/main.dart
// Entry point for Android / mobile users.
// Web is served via main_admin.dart (see web/index.html override).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'features/admin_web/shared/presentation/theme/admin_theme.dart';
import 'main_admin.dart' as admin;

void main() {
  // On web, always open admin panel.
  // On Android / iOS, this would launch the farmer/buyer/observer app.
  if (kIsWeb) {
    admin.main();
    return;
  }

  runApp(const PanenaraApp());
}

/// Placeholder mobile app — replace with your real user app.
class PanenaraApp extends StatelessWidget {
  const PanenaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panenara',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.light(),
      darkTheme: AdminTheme.dark(),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Panenara\nAplikasi Pertanian',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
