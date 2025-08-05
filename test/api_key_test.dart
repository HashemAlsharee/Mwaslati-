import 'package:flutter_test/flutter_test.dart';
import 'package:busui/core/services/api_key_service.dart';

void main() {
  group('ApiKeyService Tests', () {
    test('should throw error when environment not loaded', () {
      expect(() => ApiKeyService.googleMapsApiKey, throwsException);
    });

    test('should handle environment loading status', () {
      final isLoaded = ApiKeyService.isEnvLoaded;
      expect(isLoaded, isA<bool>());
      print('✅ Environment loading status: $isLoaded');
    });
  });
} 