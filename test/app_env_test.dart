import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:busui/core/services/api_key_service.dart';

void main() {
  group('App Environment Tests', () {
    test('should load .env file and access API key successfully', () async {
      try {
        // Simulate app startup - load .env file
        await dotenv.load(fileName: ".env");
        print('✅ .env file loaded successfully');
        
        // Verify API key is accessible
        final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
        expect(apiKey, isNotNull);
        expect(apiKey, isNotEmpty);
        expect(apiKey, startsWith('AIzaSy'));
        print('🔑 API Key loaded: ${apiKey!.substring(0, 10)}...');
        
        // Test ApiKeyService access
        final serviceApiKey = ApiKeyService.googleMapsApiKey;
        expect(serviceApiKey, equals(apiKey));
        print('✅ ApiKeyService returns correct key');
        
        // Test environment loading status
        final isLoaded = ApiKeyService.isEnvLoaded;
        expect(isLoaded, isTrue);
        print('✅ Environment loading status: $isLoaded');
        
      } catch (e) {
        print('❌ Environment loading failed: $e');
        rethrow;
      }
    });
  });
} 