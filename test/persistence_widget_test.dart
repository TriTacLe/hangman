import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/game/game_store.dart';
import 'package:hangman/game/hangman_game.dart';
import 'package:hangman/main.dart';
import 'package:hangman/ui/game_screen.dart';
import 'package:hangman/ui/home_screen.dart';

import 'helpers.dart';

void main() {
  group('language survives a restart', () {
    testWidgets('a saved language is used before the device one', (
      tester,
    ) async {
      final store = await openStore({'locale': 'nb'});
      tester.platformDispatcher.localesTestValue = [const Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(HangmanApp(store: store));
      await tester.pumpAndSettle();

      expect(find.text('Spill'), findsOneWidget);
    });

    testWidgets('picking a language writes it to the store', (tester) async {
      final store = await openStore();
      await tester.pumpWidget(HangmanApp(store: store));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Norsk'));
      await tester.pumpAndSettle();

      expect(store.locale, 'nb');
      expect(find.text('Spill'), findsOneWidget);
    });
  });

  group('a round survives the process', () {
    testWidgets('every guess is written to the store', (tester) async {
      final store = await openStore();
      await tester.pumpWidget(
        appUnderTest(
          GameScreen(wordRepository: fixedWord('ost'), store: store),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(key('O'));
      await tester.pumpAndSettle();

      expect(store.round, isNotNull);
      expect(store.round!.game.maskedWord, 'O__');
      expect(store.round!.language, 'en');
    });

    testWidgets('a finished round is cleared from the store', (tester) async {
      final store = await openStore();
      await tester.pumpWidget(
        appUnderTest(
          GameScreen(wordRepository: fixedWord('ost'), store: store),
        ),
      );
      await tester.pumpAndSettle();

      for (final letter in ['O', 'S', 'T']) {
        await tester.tap(key(letter));
        await tester.pumpAndSettle();
      }

      expect(find.text('You won'), findsOneWidget);
      expect(store.round, isNull);
    });

    testWidgets('the start screen offers to continue a saved round', (
      tester,
    ) async {
      final store = await openStore();
      await store.saveRound(
        SavedRound(
          language: 'en',
          game: HangmanGame(word: 'ost')..guess('o'),
        ),
      );

      await tester.pumpWidget(
        appUnderTest(
          HomeScreen(
            selectedLocale: const Locale('en'),
            onLocaleSelected: (_) {},
            store: store,
          ),
        ),
      );

      expect(find.text('Continue game'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);

      await tester.tap(find.text('Continue game'));
      await tester.pumpAndSettle();

      expect(letterInWord('O'), findsOneWidget);
      expect(find.text('6 wrong guesses left'), findsOneWidget);
    });

    testWidgets('a finished saved round is not offered', (tester) async {
      final store = await openStore();
      await store.saveRound(
        SavedRound(
          language: 'en',
          game: HangmanGame(word: 'ost', maxWrongGuesses: 1)..guess('q'),
        ),
      );

      await tester.pumpWidget(
        appUnderTest(
          HomeScreen(
            selectedLocale: const Locale('en'),
            onLocaleSelected: (_) {},
            store: store,
          ),
        ),
      );

      expect(find.text('Continue game'), findsNothing);
    });

    testWidgets('a round saved in the other language starts fresh', (
      tester,
    ) async {
      final store = await openStore();
      final saved = SavedRound(
        language: 'nb',
        game: HangmanGame(word: 'blåbær')..guess('å'),
      );

      await tester.pumpWidget(
        appUnderTest(
          GameScreen(
            wordRepository: fixedWord('ost'),
            store: store,
            savedRound: saved,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(letterInWord('Å'), findsNothing);
      expect(find.text('6 wrong guesses left'), findsOneWidget);
    });
  });

  group('hardware keyboard', () {
    testWidgets('typed letters count as guesses', (tester) async {
      await tester.pumpWidget(
        appUnderTest(GameScreen(wordRepository: fixedWord('ost'))),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.keyO, character: 'o');
      await tester.pumpAndSettle();
      expect(letterInWord('O'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ, character: 'z');
      await tester.pumpAndSettle();
      expect(find.text('5 wrong guesses left'), findsOneWidget);
    });

    testWidgets('a repeated or non-letter key changes nothing', (tester) async {
      await tester.pumpWidget(
        appUnderTest(GameScreen(wordRepository: fixedWord('ost'))),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ, character: 'z');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ, character: 'z');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1, character: '1');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space, character: ' ');
      await tester.pumpAndSettle();

      expect(find.text('5 wrong guesses left'), findsOneWidget);
    });

    testWidgets('Norwegian letters work from the keyboard too', (tester) async {
      await tester.pumpWidget(
        appUnderTest(
          GameScreen(wordRepository: fixedWord('blåbær')),
          locale: const Locale('nb'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA, character: 'å');
      await tester.pumpAndSettle();

      expect(letterInWord('Å'), findsOneWidget);
    });
  });
  group('starting a new game', () {
    testWidgets('asks before dropping the saved round, and cancelling keeps '
        'it', (tester) async {
      final store = await openStore();
      await store.saveRound(
        SavedRound(
          language: 'en',
          game: HangmanGame(word: 'ost')..guess('o'),
        ),
      );

      await tester.pumpWidget(
        appUnderTest(
          HomeScreen(
            selectedLocale: const Locale('en'),
            onLocaleSelected: (_) {},
            store: store,
          ),
          locale: const Locale('en'),
        ),
      );

      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
      expect(find.text('Start a new game?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(GameScreen), findsNothing);
      expect(store.round!.game.guessedLetters, {'O'});
    });

    testWidgets('confirming starts a fresh round', (tester) async {
      final store = await openStore();
      await store.saveRound(
        SavedRound(
          language: 'en',
          game: HangmanGame(word: 'ost')..guess('o'),
        ),
      );

      await tester.pumpWidget(
        appUnderTest(
          HomeScreen(
            selectedLocale: const Locale('en'),
            onLocaleSelected: (_) {},
            store: store,
          ),
          locale: const Locale('en'),
        ),
      );

      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start new'));
      await tester.pumpAndSettle();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(store.round!.game.guessedLetters, isEmpty);
    });
  });

  group('the language changing mid-round', () {
    testWidgets('restarts the round and saves it under the new language', (
      tester,
    ) async {
      final store = await openStore();

      await tester.pumpWidget(
        appUnderTest(
          GameScreen(wordRepository: fixedWord('ost'), store: store),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(key('O'));
      await tester.pumpAndSettle();
      expect(store.round!.language, 'en');

      // Same widget, new locale: this is the live language change.
      await tester.pumpWidget(
        appUnderTest(
          GameScreen(wordRepository: fixedWord('ost'), store: store),
          locale: const Locale('nb'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('6 forsøk igjen'), findsOneWidget);
      expect(letterInWord('O'), findsNothing);
      expect(key('Æ'), findsOneWidget);
      // The round must not be tagged with the language it was started in.
      expect(store.round!.language, 'nb');
      expect(store.round!.game.guessedLetters, isEmpty);
    });
  });

  group('finishing a round', () {
    testWidgets('takes the continue button off the start screen', (
      tester,
    ) async {
      final store = await openStore();
      await store.saveRound(
        SavedRound(
          language: 'en',
          game: HangmanGame(word: 'ost'),
        ),
      );

      await tester.pumpWidget(
        appUnderTest(
          HomeScreen(
            selectedLocale: const Locale('en'),
            onLocaleSelected: (_) {},
            store: store,
          ),
          locale: const Locale('en'),
        ),
      );
      expect(find.text('Continue game'), findsOneWidget);

      await tester.tap(find.text('Continue game'));
      await tester.pumpAndSettle();
      for (final letter in ['B', 'C', 'D', 'F', 'G', 'H']) {
        await tester.tap(key(letter));
        await tester.pump();
      }
      await tester.tap(find.text('Back to start'));
      await tester.pumpAndSettle();

      expect(find.text('Continue game'), findsNothing);
      expect(store.round, isNull);
    });
  });
  group('coming back from the info page', () {
    testWidgets('leaves the hardware keyboard working', (tester) async {
      await tester.pumpWidget(
        appUnderTest(
          GameScreen(wordRepository: fixedWord('ost')),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.keyO, character: 'o');
      await tester.pumpAndSettle();
      expect(letterInWord('O'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Without the focus being asked for again, this key goes nowhere.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS, character: 's');
      await tester.pumpAndSettle();

      expect(letterInWord('S'), findsOneWidget);
    });
  });

  group('a saved round that is already over', () {
    testWidgets('is not resumed, and is cleared from the store', (
      tester,
    ) async {
      final store = await openStore();
      final finished = HangmanGame(word: 'ost', maxWrongGuesses: 1)..guess('q');
      await store.saveRound(SavedRound(language: 'en', game: finished));

      await tester.pumpWidget(
        appUnderTest(
          GameScreen(
            wordRepository: fixedWord('ost'),
            store: store,
            savedRound: SavedRound(language: 'en', game: finished),
          ),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('You lost'), findsNothing);
      expect(find.text('6 wrong guesses left'), findsOneWidget);
    });
  });
}
