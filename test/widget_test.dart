import 'package:flutter_test/flutter_test.dart';
import 'package:color_by_number/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ColorByNumberApp());
    expect(find.text('Color by Number'), findsOneWidget);
  });
}
