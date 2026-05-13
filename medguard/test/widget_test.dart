import 'package:flutter_test/flutter_test.dart';

import 'package:medguard/main.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MedGuardApp());
    await tester.pump();
    expect(find.text('MedGuard'), findsOneWidget);
    expect(find.text('Secure Medical Logistics'), findsOneWidget);
  });
}
