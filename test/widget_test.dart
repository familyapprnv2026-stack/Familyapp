import 'package:flutter_test/flutter_test.dart';

import 'package:family_app/main.dart';

void main() {
  testWidgets('App starts on splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyApp());
    await tester.pump();

    expect(find.text('FamilyApp'), findsOneWidget);
    expect(find.text('Organiza tu familia con amor'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
