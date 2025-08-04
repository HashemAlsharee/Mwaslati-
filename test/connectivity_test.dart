import 'package:flutter_test/flutter_test.dart';
import 'package:busui/core/services/connectivity_service.dart';

void main() {
  group('ConnectivityService Tests', () {
    test('should create singleton instance', () {
      final service1 = ConnectivityService();
      final service2 = ConnectivityService();
      expect(service1, equals(service2));
    });

    test('should have connectivity stream', () {
      final service = ConnectivityService();
      expect(service.connectivityStream, isNotNull);
    });

    test('should have checkConnectivity method', () {
      final service = ConnectivityService();
      expect(service.checkConnectivity, isNotNull);
    });
  });
} 