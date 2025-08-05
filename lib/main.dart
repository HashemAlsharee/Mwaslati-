import 'package:flutter/material.dart';
import 'features/connectivity/connectivity_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// If you add a custom font, import it here (e.g., Cairo or Tajawal)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables first
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
    
    // Verify the API key was loaded
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      print('🔑 API Key loaded: ${apiKey.substring(0, 10)}...');
    } else {
      throw Exception('GOOGLE_MAPS_API_KEY is empty or missing in .env file');
    }
  } catch (e) {
    print('❌ CRITICAL ERROR: Could not load .env file: $e');
    print('''
🔧 Troubleshooting Steps:
1. Check if .env file exists in project root
2. Verify .env file contains: GOOGLE_MAPS_API_KEY=your_api_key_here
3. Ensure .env is included in pubspec.yaml assets section
4. Run: flutter clean && flutter pub get
5. Restart the app

The app will now throw an error instead of using outdated fallback keys.
''');
    // Don't continue - let the error propagate
    rethrow;
  }
  
  // Initialize Firebase after environment variables
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    // Still run the app even if Firebase fails
  }

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


