import 'package:flutter_test/flutter_test.dart';

import 'package:hoora_task/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('All Services'), findsOneWidget);
  });
}
