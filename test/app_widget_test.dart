import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/game/word_repository.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/ui/game_screen.dart';
import 'package:hangman/ui/home_screen.dart';

/// Always hands out the same word, so the assertions can name letters.
WordRepository _fixedWord(String word) => WordRepository(
      loadAsset: (_) async => word,
      random: Random(0),
    );

Widget _wrap(Widget child, {Locale? locale}) => MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  testWidgets('the start screen is in English when the locale is English', (tester) async {
    await tester.pumpWidget(_wrap(
      HomeScreen(selectedLocale: const Locale('en'), onLocaleSelected: (_) {}),
      locale: const Locale('en'),
    ));

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('How to play'), findsOneWidget);
  });

  testWidgets('the start screen is in Norwegian when the locale is Norwegian', (tester) async {
    await tester.pumpWidget(_wrap(
      HomeScreen(selectedLocale: const Locale('nb'), onLocaleSelected: (_) {}),
      locale: const Locale('nb'),
    ));

    expect(find.text('Spill'), findsOneWidget);
    expect(find.text('Slik spiller du'), findsOneWidget);
  });

  testWidgets('the info page opens from the start screen', (tester) async {
    await tester.pumpWidget(_wrap(
      HomeScreen(selectedLocale: const Locale('en'), onLocaleSelected: (_) {}),
      locale: const Locale('en'),
    ));

    await tester.tap(find.text('How to play'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tap a letter to guess it'), findsOneWidget);
  });

  testWidgets('the keyboard carries the Norwegian letters', (tester) async {
    await tester.pumpWidget(_wrap(
      GameScreen(wordRepository: _fixedWord('blabaer')),
      locale: const Locale('nb'),
    ));
    await tester.pumpAndSettle();

    for (final letter in ['Æ', 'Ø', 'Å']) {
      expect(find.widgetWithText(SizedBox, letter), findsOneWidget);
    }
  });

  testWidgets('the keyboard carries only A to Z in English', (tester) async {
    await tester.pumpWidget(_wrap(
      GameScreen(wordRepository: _fixedWord('anchor')),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SizedBox, 'Z'), findsOneWidget);
    expect(find.widgetWithText(SizedBox, 'Æ'), findsNothing);
  });

  testWidgets('a correct guess reveals the letter and a wrong one costs a guess', (tester) async {
    await tester.pumpWidget(_wrap(
      GameScreen(wordRepository: _fixedWord('ost')),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('_ _ _'), findsOneWidget);
    expect(find.text('6 wrong guesses left'), findsOneWidget);

    await tester.tap(find.widgetWithText(SizedBox, 'O'));
    await tester.pump();
    expect(find.text('O _ _'), findsOneWidget);

    await tester.tap(find.widgetWithText(SizedBox, 'B'));
    await tester.pump();
    expect(find.text('5 wrong guesses left'), findsOneWidget);
  });

  testWidgets('guessing the whole word wins the game', (tester) async {
    await tester.pumpWidget(_wrap(
      GameScreen(wordRepository: _fixedWord('ost')),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    for (final letter in ['O', 'S', 'T']) {
      await tester.tap(find.widgetWithText(SizedBox, letter));
      await tester.pump();
    }

    expect(find.text('You won'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
  });

  testWidgets('six wrong guesses lose the game and show the word', (tester) async {
    await tester.pumpWidget(_wrap(
      GameScreen(wordRepository: _fixedWord('ost')),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    for (final letter in ['B', 'C', 'D', 'F', 'G', 'H']) {
      await tester.tap(find.widgetWithText(SizedBox, letter));
      await tester.pump();
    }

    expect(find.text('You lost'), findsOneWidget);
    expect(find.text('The word was OST.'), findsOneWidget);
  });

  testWidgets('the info page opens from inside a running game', (tester) async {
    await tester.pumpWidget(_wrap(
      GameScreen(wordRepository: _fixedWord('ost')),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tap a letter to guess it'), findsOneWidget);
  });
}
