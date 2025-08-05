import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeyService {
  static const String _fallbackGoogleMapsApiKey = 'AIzaSyCxy0b-BsXcBJNoZ7xjERUXar-OIWlNWZA';
  
  /// Get Google Maps API Key - throws error if .env not loaded
  static String get googleMapsApiKey {
    try {
      // Try to get from environment variables
      final envKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (envKey != null && envKey.isNotEmpty) {
        print('✅ Using API key from .env file: ${envKey.substring(0, 10)}...');
        return envKey;
      } else {
        throw Exception('GOOGLE_MAPS_API_KEY not found in .env file');
      }
    } catch (e) {
      // If dotenv is not initialized or fails, throw clear error
      print('❌ Failed to load API key from .env file: $e');
      throw Exception('''
🔑 API Key Error:
The .env file could not be loaded or the GOOGLE_MAPS_API_KEY is missing.

Please ensure:
1. The .env file exists in your project root
2. The .env file contains: GOOGLE_MAPS_API_KEY=your_api_key_here
3. The .env file is included in pubspec.yaml assets section
4. flutter_dotenv is properly initialized in main.dart

Error details: $e
''');
    }
  }
  
  /// Check if environment variables are loaded
  static bool get isEnvLoaded {
    try {
      return dotenv.env['GOOGLE_MAPS_API_KEY'] != null;
    } catch (e) {
      return false;
    }
  }
} 