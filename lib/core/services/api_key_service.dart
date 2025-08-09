import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeyService {
  static const String _fallbackGoogleMapsApiKey = 'AIzaSyCxy0b-BsXcBJNoZ7xjERUXar-OIWlNWZA';
  
  /// Get Google Maps API Key - throws error if .env not loaded
  static String get googleMapsApiKey {
    try {
      // Try to get from environment variables
      final envKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (envKey != null && envKey.isNotEmpty) {
        return envKey;
      } else {
        throw Exception('GOOGLE_MAPS_API_KEY not found in .env file');
      }
    } catch (e) {
      // If dotenv is not initialized or fails, throw clear error
      throw Exception('Failed to load API key from .env file: $e');
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