// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:busui/main.dart';
import 'package:busui/core/providers/theme_provider.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('App loads successfully', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
      );

      // Verify that the app loads without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App has proper structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
      );

      // Verify the app has proper structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Consumer<ThemeProvider>), findsOneWidget);
    });

    testWidgets('App supports Arabic locale', (WidgetTester tester) async {
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
  });
}
