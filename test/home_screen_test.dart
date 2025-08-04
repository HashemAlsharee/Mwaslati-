import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:busui/features/home/home_screen.dart';
import 'package:busui/core/providers/theme_provider.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen shows loading initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify loading indicator is shown initially
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('HomeScreen has correct RTL direction', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify RTL direction is set
      final directionalities = tester.widgetList<Directionality>(find.byType(Directionality));
      expect(directionalities.any((d) => d.textDirection == TextDirection.rtl), isTrue);
    });

    testWidgets('HomeScreen has proper structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });
  });
} 