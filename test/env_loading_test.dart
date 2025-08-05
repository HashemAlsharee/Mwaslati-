import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Environment Loading Tests', () {
    test('should load .env file successfully', () async {
      try {
        await dotenv.load(fileName: ".env");
        
        final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
        expect(apiKey, isNotNull);
        expect(apiKey, isNotEmpty);
        expect(apiKey, startsWith('AIzaSy'));
        
        print('✅ .env file loaded successfully');
        print('🔑 API Key found: ${apiKey!.substring(0, 10)}...');
      } catch (e) {
        print('❌ Failed to load .env file: $e');
        rethrow;
      }
    });
  });
} 