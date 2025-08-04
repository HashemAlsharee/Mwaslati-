import 'package:flutter/foundation.dart';
import 'config_service.dart';

class LoggerService {
  static void debug(String message) {
    if (!ConfigService.isProduction) {
      debugPrint('[DEBUG] $message');
    }
  }
  
  static void info(String message) {
    if (!ConfigService.isProduction) {
      debugPrint('[INFO] $message');
    }
  }
  
  static void warning(String message) {
    if (!ConfigService.isProduction) {
      debugPrint('[WARNING] $message');
    }
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!ConfigService.isProduction) {
      debugPrint('[ERROR] $message');
      if (error != null) {
        debugPrint('[ERROR] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[ERROR] Stack trace: $stackTrace');
      }
    }
  }
  
  static void critical(String message, [dynamic error, StackTrace? stackTrace]) {
    // Always log critical errors, even in production
    debugPrint('[CRITICAL] $message');
    if (error != null) {
      debugPrint('[CRITICAL] Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('[CRITICAL] Stack trace: $stackTrace');
    }
  }
} 