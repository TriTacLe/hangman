import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/game/word_repository.dart';
import 'package:hangman/ui/game_screen.dart';
import 'package:hangman/ui/home_screen.dart';
import 'package:hangman/ui/word_display.dart';

import 'helpers.dart';

void main() {
  testWidgets('the start screen is in English when the locale is English', (
    tester,
  ) async {
    await tester.pumpWidget(
      appUnderTest(
        HomeScreen(
          selectedLocale: const Locale('en'),
          onLocaleSelected: (_) {},
        ),
        locale: const Locale('en'),
      ),
    );

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('How to play'), findsOneWidget);
  });

  testWidgets('the start screen is in Norwegian when the locale is Norwegian', (
    tester,
  ) async {
    await tester.pumpWidget(
      appUnderTest(
        HomeScreen(
          selectedLocale: const Locale('nb'),
          onLocaleSelected: (_) {},
        ),
        locale: const Locale('nb'),
      ),
    );

    expect(find.text('Spill'), findsOneWidget);
    expect(find.text('Slik spiller du'), findsOneWidget);
  });

  testWidgets('the info page opens from the start screen', (tester) async {
    await tester.pumpWidget(
      appUnderTest(
        HomeScreen(
          selectedLocale: const Locale('en'),
          onLocaleSelected: (_) {},
        ),
        locale: const Locale('en'),
      ),
    );

    await tester.tap(find.text('How to play'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tap a letter to guess it'), findsOneWidget);
  });

  testWidgets('the keyboard carries the Norwegian letters', (tester) async {
    await tester.pumpWidget(
      appUnderTest(
        GameScreen(wordRepository: fixedWord('blabaer')),
        locale: const Locale('nb'),
      ),
    );
    await tester.pumpAndSettle();

    for (final letter in ['Æ', 'Ø', 'Å']) {
      expect(key(letter), findsOneWidget);
    }
  });

  testWidgets('the keyboard carries only A to Z in English', (tester) async {
    await tester.pumpWidget(
      appUnderTest(
        GameScreen(wordRepository: fixedWord('anchor')),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(key('Z'), findsOneWidget);
    expect(key('Æ'), findsNothing);
  });

  testWidgets(
    'a correct guess reveals the letter and a wrong one costs a guess',
    (tester) async {
      await tester.pumpWidget(
        appUnderTest(
          GameScreen(wordRepository: fixedWord('ost')),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WordDisplay), findsOneWidget);
      expect(letterInWord('O'), findsNothing);
      expect(find.text('6 wrong guesses left'), findsOneWidget);

      await tester.tap(key('O'));
      await tester.pump();
      expect(letterInWord('O'), findsOneWidget);

      await tester.tap(key('B'));
      await tester.pump();
      expect(find.text('5 wrong guesses left'), findsOneWidget);
    },
  );

  testWidgets('guessing the whole word wins the game', (tester) async {
    await tester.pumpWidget(
      appUnderTest(
        GameScreen(wordRepository: fixedWord('ost')),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    for (final letter in ['O', 'S', 'T']) {
      await tester.tap(key(letter));
      await tester.pump();
    }

    expect(find.text('You won'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
  });

  testWidgets('six wrong guesses lose the game and show the word', (
    tester,
  ) async {
    await tester.pumpWidget(
      appUnderTest(
        GameScreen(wordRepository: fixedWord('ost')),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    for (final letter in ['B', 'C', 'D', 'F', 'G', 'H']) {
      await tester.tap(key(letter));
      await tester.pump();
    }

    expect(find.text('You lost'), findsOneWidget);
    expect(find.text('The word was OST.'), findsOneWidget);
    expect(letterInWord('S'), findsOneWidget);
  });

  testWidgets('the info page opens from inside a running game', (tester) async {
    await tester.pumpWidget(
      appUnderTest(
        GameScreen(wordRepository: fixedWord('ost')),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tap a letter to guess it'), findsOneWidget);
  });
  testWidgets('play again draws a new word and clears the board', (
    tester,
  ) async {
    // The repository hands out a different word the second time, which is how
    // the test can tell the round was replaced rather than reset.
    final words = ['ost', 'anchor'];
    var served = 0;
    final repository = WordRepository(
      loadAsset: (_) async => words[served++ % words.length],
    );

    await tester.pumpWidget(
      appUnderTest(
        GameScreen(wordRepository: repository),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    for (final letter in ['O', 'S', 'T']) {
      await tester.tap(key(letter));
      await tester.pump();
    }
    expect(find.text('You won'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();

    expect(find.text('You won'), findsNothing);
    expect(find.text('6 wrong guesses left'), findsOneWidget);
    expect(key('O'), findsOneWidget);
    expect(letterInWord('O'), findsNothing);
  });

  testWidgets('back to start leaves the game', (tester) async {
    // Pushed from a stand-in start screen so the word is fixed: HomeScreen
    // builds its own repository and would hand out a random one.
    await tester.pumpWidget(
      appUnderTest(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GameScreen(wordRepository: fixedWord('ost')),
                ),
              ),
              child: const Text('Play'),
            ),
          ),
        ),
        locale: const Locale('en'),
      ),
    );

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);

    // Lose on purpose, which is the only route to the two result buttons.
    for (final letter in ['B', 'C', 'D', 'F', 'G', 'H']) {
      await tester.tap(key(letter));
      await tester.pump();
    }
    await tester.tap(find.text('Back to start'));
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsNothing);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('a word list that cannot be read offers a retry', (tester) async {
    var fail = true;
    final repository = WordRepository(
      loadAsset: (_) async => fail ? throw StateError('no list') : 'ost',
    );

    await tester.pumpWidget(
      appUnderTest(
        GameScreen(wordRepository: repository),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('The word list could not be read.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('6 wrong guesses left'), findsOneWidget);
  });
}
