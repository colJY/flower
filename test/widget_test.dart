// FlowerCup app widget tests
//
// This file contains basic widget tests for the FlowerCup app.
// It tests the main app initialization and splash screen functionality.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flower_app/main.dart';
import 'package:flower_app/screens/splash_screen.dart';

void main() {
  group('FlowerCup App Tests', () {
    testWidgets('App should start with splash screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const FlowerCupApp());

      // Verify that the splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Verify that the app title is displayed
      expect(find.text('꽃받침'), findsOneWidget);
      expect(find.text('FlowerCup'), findsOneWidget);
      
      // Verify that the flower icon is displayed
      expect(find.byIcon(Icons.local_florist), findsOneWidget);
    });

    testWidgets('App should have proper localization setup', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const FlowerCupApp());

      // Find the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify localization delegates are set up
      expect(materialApp.localizationsDelegates, isNotNull);
      expect(materialApp.localizationsDelegates!.length, greaterThan(0));
      
      // Verify supported locales
      expect(materialApp.supportedLocales, contains(const Locale('ko')));
      expect(materialApp.supportedLocales, contains(const Locale('en')));
    });

    testWidgets('Splash screen should display correctly', (WidgetTester tester) async {
      // Build just the splash screen
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko'),
            Locale('en'),
          ],
        ),
      );

      // Verify splash screen elements
      expect(find.byIcon(Icons.local_florist), findsOneWidget);
      expect(find.text('꽃받침'), findsOneWidget);
      expect(find.text('FlowerCup'), findsOneWidget);
      
      // Verify background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF8F4F0));
    });
  });
}
