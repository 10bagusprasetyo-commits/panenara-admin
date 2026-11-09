// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:panenara/main.dart';

void main() {
  testWidgets('PanenaraApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PanenaraApp());
    expect(find.textContaining('Panenara'), findsWidgets);
  });
}
