import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:busui/main.dart';
import 'package:busui/core/providers/theme_provider.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('App loads without crashing', (tester) async {
      // Start the app
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
      );

      // Verify the app loads without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App has proper RTL support', (tester) async {
      // Start the app
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
      );

      // Verify RTL direction is set
      final directionalities = tester.widgetList<Directionality>(find.byType(Directionality));
      expect(directionalities.any((d) => d.textDirection == TextDirection.rtl), isTrue);
    });

    testWidgets('App handles theme provider', (tester) async {
      // Start the app
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
      );

      // Verify theme provider is working
      expect(find.byType(Consumer<ThemeProvider>), findsOneWidget);
    });
  });
} 