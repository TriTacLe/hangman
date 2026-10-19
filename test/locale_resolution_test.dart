import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/main.dart';

void main() {
  group('locale resolution', () {
    Future<void> pumpWithDeviceLocale(
      WidgetTester tester,
      Locale locale,
    ) async {
      tester.platformDispatcher.localesTestValue = [locale];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(const HangmanApp());
      await tester.pumpAndSettle();
    }

    testWidgets('a device set to nb gets Norwegian', (tester) async {
      await pumpWithDeviceLocale(tester, const Locale('nb', 'NO'));

      expect(find.text('Spill'), findsOneWidget);
    });

    testWidgets('a device set to no gets Norwegian', (tester) async {
      await pumpWithDeviceLocale(tester, const Locale('no', 'NO'));

      expect(find.text('Spill'), findsOneWidget);
    });

    testWidgets('a device set to nn gets Norwegian', (tester) async {
      await pumpWithDeviceLocale(tester, const Locale('nn', 'NO'));

      expect(find.text('Spill'), findsOneWidget);
    });

    testWidgets('a language with no translation falls back to English', (
      tester,
    ) async {
      await pumpWithDeviceLocale(tester, const Locale('de', 'DE'));

      expect(find.text('Play'), findsOneWidget);
    });
  });
}
