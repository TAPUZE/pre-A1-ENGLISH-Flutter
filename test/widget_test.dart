import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:english_trip_app/main.dart';
import 'package:english_trip_app/providers/app_provider.dart';

void main() {
  group('English Trip App Tests', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Verify that the app builds without throwing exceptions
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Splash screen should be displayed initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Wait for the splash screen to be displayed
      await tester.pump();

      // Verify splash screen elements
      expect(find.text('English Trip'), findsOneWidget);
      expect(find.text('PRE A1 Learning Journey'), findsOneWidget);
    });

    test('AppProvider should initialize with default values', () {
      final appProvider = AppProvider();
      
      expect(appProvider.isHebrew, false);
      expect(appProvider.currentUserId, isNotNull);
      expect(appProvider.userProgress, isEmpty);
      expect(appProvider.userMistakes, isEmpty);
    });

    test('AppProvider should toggle language correctly', () {
      final appProvider = AppProvider();
      
      // Initially should be English
      expect(appProvider.isHebrew, false);
      
      // Toggle to Hebrew
      appProvider.toggleLanguage();
      expect(appProvider.isHebrew, true);
      
      // Toggle back to English
      appProvider.toggleLanguage();
      expect(appProvider.isHebrew, false);
    });

    test('AppProvider should log progress correctly', () {
      final appProvider = AppProvider();
      
      // Log some progress
      appProvider.logProgress('Section 1', 'exercise', {'score': 100});
      
      // Verify progress was logged
      expect(appProvider.userProgress.length, 1);
      expect(appProvider.userProgress.first.sectionTitle, 'Section 1');
      expect(appProvider.userProgress.first.activityType, 'exercise');
    });

    test('AppProvider should log mistakes correctly', () {
      final appProvider = AppProvider();
      
      // Log a mistake
      appProvider.logMistake('Section 1', 'What is hello?', 'hi', 'hello', false);
      
      // Verify mistake was logged
      expect(appProvider.userMistakes.length, 1);
      expect(appProvider.userMistakes.first.sectionTitle, 'Section 1');
      expect(appProvider.userMistakes.first.question, 'What is hello?');
      expect(appProvider.userMistakes.first.userAnswer, 'hi');
      expect(appProvider.userMistakes.first.correctAnswer, 'hello');
      expect(appProvider.userMistakes.first.isCorrect, false);
    });
  });
}
