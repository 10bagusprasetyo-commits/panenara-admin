// lib/features/admin_web/shared/presentation/theme/admin_theme.dart
// Panenara Admin Panel Theme
// Warna mengikuti desain HTML:
//   Sidebar mint: #e9f3e6 → #d3e6d0 (terang), #143523 → #1d4a30 (gelap)
//   Hijau utama: #25834f | Hijau terang: #2f9a5c | Hijau tua: #1d4a30
//   Krem latar: #f4f5ee | Kartu: #ffffff | Oranye bulir: #e8a33d

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AdminColors {
  // Greens
  static const g9 = Color(0xFF143523);
  static const g8 = Color(0xFF1d4a30);
  static const g6 = Color(0xFF25834f);
  static const g5 = Color(0xFF2f9a5c);
  static const g2 = Color(0xFFc8dec8);
  static const g1 = Color(0xFFe6f0e4);

  // Backgrounds (light)
  static const bgLight = Color(0xFFf4f5ee);
  static const cardLight = Color(0xFFffffff);
  static const txLight = Color(0xFF183323);
  static const mutLight = Color(0xFF5f7466);
  static const lineLight = Color(0xFFdfe6db);

  // Sidebar (light)
  static const sb1Light = Color(0xFFe9f3e6);
  static const sb2Light = Color(0xFFd3e6d0);
  static const sbtLight = Color(0xFF1d4a30);

  // Sidebar (dark)
  static const sb1Dark = Color(0xFF143523);
  static const sb2Dark = Color(0xFF1d4a30);
  static const sbtDark = Color(0xFFeaf3e8);

  // Backgrounds (dark)
  static const bgDark = Color(0xFF0f1f16);
  static const cardDark = Color(0xFF162b1f);
  static const txDark = Color(0xFFe6f0e4);
  static const mutDark = Color(0xFF9bb3a2);
  static const lineDark = Color(0xFF26402f);

  // Status: OK / green
  static const okBgLight = Color(0xFFdcefdc);
  static const okTxLight = Color(0xFF1f6b3f);
  static const okBgDark = Color(0xFF21452f);
  static const okTxDark = Color(0xFF8fdcab);

  // Status: Warning / yellow
  static const wnBgLight = Color(0xFFfff1d6);
  static const wnTxLight = Color(0xFF8a5a00);
  static const wnBgDark = Color(0xFF4a3a12);
  static const wnTxDark = Color(0xFFf2c96b);

  // Status: Bad / red
  static const bdBgLight = Color(0xFFfde4e1);
  static const bdTxLight = Color(0xFFa3281c);
  static const bdBgDark = Color(0xFF4d2420);
  static const bdTxDark = Color(0xFFf5a79e);

  // Status: Muted / gray
  static const mtBgLight = Color(0xFFeceee8);
  static const mtTxLight = Color(0xFF6b786f);
  static const mtBgDark = Color(0xFF243a2d);
  static const mtTxDark = Color(0xFF9bb3a2);

  // Accent
  static const amber = Color(0xFFe8a33d);
}

abstract final class AdminTheme {
  static TextTheme _textTheme() => GoogleFonts.plusJakartaSansTextTheme();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AdminColors.g6,
        onPrimary: Colors.white,
        secondary: AdminColors.g5,
        onSecondary: Colors.white,
        surface: AdminColors.cardLight,
        onSurface: AdminColors.txLight,
        error: AdminColors.bdTxLight,
        outline: AdminColors.lineLight,
      ),
      scaffoldBackgroundColor: AdminColors.bgLight,
      cardColor: AdminColors.cardLight,
      dividerColor: AdminColors.lineLight,
      textTheme: _textTheme().apply(
        bodyColor: AdminColors.txLight,
        displayColor: AdminColors.txLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.g6,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.bgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AdminColors.lineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AdminColors.lineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AdminColors.g6, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AdminColors.g5,
        onPrimary: Colors.white,
        secondary: AdminColors.g6,
        onSecondary: Colors.white,
        surface: AdminColors.cardDark,
        onSurface: AdminColors.txDark,
        error: AdminColors.bdTxDark,
        outline: AdminColors.lineDark,
      ),
      scaffoldBackgroundColor: AdminColors.bgDark,
      cardColor: AdminColors.cardDark,
      dividerColor: AdminColors.lineDark,
      textTheme: _textTheme().apply(
        bodyColor: AdminColors.txDark,
        displayColor: AdminColors.txDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.g5,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AdminColors.lineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AdminColors.lineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AdminColors.g5, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

/// Extension helpers for reading admin-specific colors from context
extension AdminColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get adminBg =>
      isDark ? AdminColors.bgDark : AdminColors.bgLight;
  Color get adminCard =>
      isDark ? AdminColors.cardDark : AdminColors.cardLight;
  Color get adminLine =>
      isDark ? AdminColors.lineDark : AdminColors.lineLight;
  Color get adminMuted =>
      isDark ? AdminColors.mutDark : AdminColors.mutLight;
  Color get adminTx =>
      isDark ? AdminColors.txDark : AdminColors.txLight;
  Color get sidebarStart =>
      isDark ? AdminColors.sb1Dark : AdminColors.sb1Light;
  Color get sidebarEnd =>
      isDark ? AdminColors.sb2Dark : AdminColors.sb2Light;
  Color get sidebarText =>
      isDark ? AdminColors.sbtDark : AdminColors.sbtLight;
}
