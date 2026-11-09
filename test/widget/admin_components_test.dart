// test/widget/admin_components_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panenara/features/admin_web/shared/presentation/widgets/status_pill.dart';
import 'package:panenara/features/admin_web/shared/presentation/widgets/stat_card.dart';
import 'package:panenara/features/admin_web/shared/presentation/widgets/panenara_logo.dart';
import 'package:panenara/features/admin_web/shared/presentation/widgets/data_panel.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  testWidgets('StatusPill renders correctly with label', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWidget(
      const StatusPill(label: 'Terverifikasi', variant: PillVariant.ok),
    ));
    expect(find.text('Terverifikasi'), findsOneWidget);

    await tester.pumpWidget(wrapWidget(
      StatusPill.fromString('Menunggu', 'wn'),
    ));
    expect(find.text('Menunggu'), findsOneWidget);
  });

  testWidgets('StatCard renders label, value, and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWidget(
      const StatCard(
        label: 'Total Petani',
        value: '4.120',
        subtitle: '+12% bulan ini',
      ),
    ));
    expect(find.text('Total Petani'), findsOneWidget);
    expect(find.text('4.120'), findsOneWidget);
    expect(find.text('+12% bulan ini'), findsOneWidget);
  });

  testWidgets('StatCard hero variant renders', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWidget(
      const StatCard(
        label: 'Nilai Transaksi',
        value: 'Rp 4,82 M',
        subtitle: 'Target tercapai',
        isHero: true,
      ),
    ));
    expect(find.text('Nilai Transaksi'), findsOneWidget);
    expect(find.text('Rp 4,82 M'), findsOneWidget);
  });

  testWidgets('PanenaraLogo renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWidget(
      const PanenaraLogo(width: 32, height: 48),
    ));
    expect(find.byType(PanenaraLogo), findsOneWidget);
  });

  testWidgets('DataPanel renders title and child widget', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWidget(
      const DataPanel(
        title: 'Panel Ringkasan',
        child: Text('Konten data panel'),
      ),
    ));
    expect(find.text('Panel Ringkasan'), findsOneWidget);
    expect(find.text('Konten data panel'), findsOneWidget);
  });
}
