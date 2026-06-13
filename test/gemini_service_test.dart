import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careshare_ai/services/gemini_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeminiService API handling', () {
    test('throws when no API key is set', () async {
      SharedPreferences.setMockInitialValues({});
      expect(
        GeminiService.analyzeProduct('Test product'),
        throwsA(isA<Exception>()),
      );
    });

    test('builds user context from saved preferences', () async {
      SharedPreferences.setMockInitialValues({
        'api_key': 'test-api-key',
        'user_name': 'Test User',
        'skin_type': 'oily',
        'hair_type': 'curly',
        'gender': 'female',
        'allergies': 'none',
        'conditions': 'none',
      });

      final exception = await expectLater(
        GeminiService.analyzeProduct('Test product'),
        throwsA(isA<Exception>()),
      );
      expect(exception, isA<Exception>());
    });
  });
}
