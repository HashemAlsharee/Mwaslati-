import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:busui/core/providers/theme_provider.dart';
import 'package:busui/features/connectivity/connectivity_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BusUI Core Functionality Tests', () {
    testWidgets('App structure is correct', (tester) async {
      // Test the app structure without platform dependencies
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(
            home: ConnectivityScreen(),
            supportedLocales: [
              Locale('ar'),
              Locale('en'),
            ],
            locale: Locale('ar'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        ),
      );

      // Verify the app structure is correct
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(ConnectivityScreen), findsOneWidget);
    });

    testWidgets('Theme provider works correctly', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(
            home: ConnectivityScreen(),
          ),
        ),
      );

      // Verify theme provider is available
      expect(find.byType(ChangeNotifierProvider<ThemeProvider>), findsOneWidget);
    });

    testWidgets('Localization is properly configured', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(
            home: ConnectivityScreen(),
            supportedLocales: [
              Locale('ar'),
              Locale('en'),
            ],
            locale: Locale('ar'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        ),
      );

      // Verify localization is set up
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.supportedLocales, isNotNull);
      expect(materialApp.localizationsDelegates, isNotNull);
      expect(materialApp.supportedLocales, contains(const Locale('ar')));
    });
  });
} 