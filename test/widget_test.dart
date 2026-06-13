import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careshare_ai/main.dart';

void main() {
  testWidgets('App launches and shows splash text', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'is_logged_in': false});

    await tester.pumpWidget(const CareShareApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('CareShare AI'), findsOneWidget);
    expect(find.text('Premium skincare intelligence'), findsOneWidget);
  });
}
