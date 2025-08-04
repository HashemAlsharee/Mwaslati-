import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/widgets/main_navigation.dart';

class ConnectivityScreen extends StatefulWidget {
  const ConnectivityScreen({super.key});

  @override
  State<ConnectivityScreen> createState() => _ConnectivityScreenState();
}

class _ConnectivityScreenState extends State<ConnectivityScreen>
    with TickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isChecking = true;
  bool _isConnected = false;
  bool _hasCheckedOnce = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startConnectivityCheck();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Future<void> _startConnectivityCheck() async {
    // Start listening to connectivity changes
    _connectivityService.startListening();
    
    // Check initial connectivity
    final isConnected = await _connectivityService.checkConnectivity();
    
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
        _isChecking = false;
        _hasCheckedOnce = true;
      });

      if (isConnected) {
        // Add a small delay for smooth transition
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _navigateToMainApp();
        }
      }
    }
  }

  Future<void> _retryConnectivityCheck() async {
    setState(() {
      _isChecking = true;
    });

    final isConnected = await _connectivityService.checkConnectivity();
    
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
        _isChecking = false;
      });

      if (isConnected) {
        _navigateToMainApp();
      }
    }
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _exitApp() {
    SystemNavigator.pop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Match your app's theme
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo - using your existing logo
                        Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                          width: 120,
                        ),
                        const SizedBox(height: 48),
                        
                        // Status text
                        if (_isChecking)
                          Column(
                            children: [
                              const Text(
                                'جاري التحقق من الاتصال...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFC107),
                                ),
                              ),
                            ],
                          )
                        else if (!_isConnected && _hasCheckedOnce)
                          Column(
                            children: [
                              const Icon(
                                Icons.wifi_off,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'يرجى التحقق من اتصال الإنترنت',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'يحتاج التطبيق إلى اتصال بالإنترنت للعمل بشكل صحيح',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _retryConnectivityCheck,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('إعادة المحاولة'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFC107),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: _exitApp,
                                    icon: const Icon(Icons.exit_to_app),
                                    label: const Text('إغلاق التطبيق'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 