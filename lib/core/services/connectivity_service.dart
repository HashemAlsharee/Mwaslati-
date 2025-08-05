import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isConnected = result != ConnectivityResult.none;
      _connectivityController.add(isConnected);
      return isConnected;
    } catch (e) {
      print('Error checking connectivity: $e');
      _connectivityController.add(false);
      return false;
    }
  }

  /// Start listening to connectivity changes
  void startListening() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      final isConnected = result != ConnectivityResult.none;
      _connectivityController.add(isConnected);
    });
  }

  /// Stop listening to connectivity changes
  void stopListening() {
    _connectivityController.close();
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
} 