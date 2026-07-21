import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:golquiz/main.dart';

void main() {
  testWidgets('usuario demo puede entrar al home', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final demoButton = find.text('Entrar como demo');
    expect(demoButton, findsOneWidget);
    await tester.ensureVisible(demoButton);
    await tester.pumpAndSettle();
    await tester.tap(demoButton);
    await tester.pumpAndSettle();
    expect(find.text('¡Hola!'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
  });
}
