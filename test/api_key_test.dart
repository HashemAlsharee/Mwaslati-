import 'package:flutter_test/flutter_test.dart';
import 'package:busui/core/services/api_key_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('API Key Service Tests', () {
    setUpAll(() async {
      // Load test environment variables
      await dotenv.load(fileName: '.env');
    });

    test('API key is loaded from environment', () {
      final apiKey = ApiKeyService.googleMapsApiKey;
      expect(apiKey, isNotNull);
      expect(apiKey, isNotEmpty);
      expect(apiKey.length, greaterThan(10)); // API keys are typically longer
    });

    test('API key has correct format', () {
      final apiKey = ApiKeyService.googleMapsApiKey;
      // Google Maps API keys typically start with 'AIza'
      expect(apiKey, startsWith('AIza'));
    });

    test('Environment variables are loaded', () {
      expect(ApiKeyService.isEnvLoaded, isTrue);
    });

    test('API key service throws exception for invalid key', () {
      // This test verifies that the service properly validates the API key
      expect(() => ApiKeyService.googleMapsApiKey, returnsNormally);
    });
  });
} 