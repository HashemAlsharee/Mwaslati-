import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static const String _googleMapsApiKey = 'GOOGLE_MAPS_API_KEY';
  
  static String? get googleMapsApiKey {
    return dotenv.env[_googleMapsApiKey];
  }
  
  static bool get isProduction {
    const bool.fromEnvironment('dart.vm.product');
    return const bool.fromEnvironment('dart.vm.product');
  }
  
  static void validateConfig() {
    if (googleMapsApiKey == null || googleMapsApiKey!.isEmpty) {
      throw Exception('Google Maps API key not found in environment variables');
    }
  }
} 