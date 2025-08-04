import 'package:flutter/material.dart';
import 'features/connectivity/connectivity_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/config_service.dart';
import 'core/services/logger_service.dart';
// If you add a custom font, import it here (e.g., Cairo or Tajawal)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    ConfigService.validateConfig();
    LoggerService.info('Environment variables loaded successfully');
  } catch (e) {
    LoggerService.error('Failed to load environment variables', e);
    // Continue with app initialization even if env loading fails
  }
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    LoggerService.info('Firebase initialized successfully');
  } catch (e) {
    LoggerService.error('Firebase initialization failed', e);
    // Still run the app even if Firebase fails
  }

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggerService.critical('Uncaught Flutter error', details.exception, details.stack);
  };

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Mwasalat Misr Clone',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const ConnectivityScreen(),
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          locale: const Locale('ar'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}


