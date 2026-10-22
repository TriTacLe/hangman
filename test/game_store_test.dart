import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/game/game_store.dart';
import 'package:hangman/game/hangman_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<GameStore> openStore([Map<String, Object> seed = const {}]) async {
    SharedPreferences.setMockInitialValues(seed);
    return GameStore(await SharedPreferences.getInstance());
  }

  group('GameStore', () {
    test('starts with no language and no round', () async {
      final store = await openStore();

      expect(store.locale, isNull);
      expect(store.round, isNull);
    });

    test('remembers the language and forgets it again', () async {
      final store = await openStore();

      await store.saveLocale('nb');
      expect(store.locale, 'nb');

      await store.saveLocale(null);
      expect(store.locale, isNull);
    });

    test('a saved round comes back with its guesses and language', () async {
      final store = await openStore();
      final game = HangmanGame(word: 'blåbær')
        ..guess('å')
        ..guess('x');

      await store.saveRound(SavedRound(language: 'nb', game: game));
      final restored = store.round;

      expect(restored, isNotNull);
      expect(restored!.language, 'nb');
      expect(restored.game.maskedWord, '__Å___');
      expect(restored.game.wrongGuesses, 1);
      expect(restored.game.status, GameStatus.playing);
    });

    test('clearing the round leaves the language alone', () async {
      final store = await openStore();
      await store.saveLocale('en');
      await store.saveRound(
        SavedRound(
          language: 'en',
          game: HangmanGame(word: 'ost'),
        ),
      );

      await store.clearRound();

      expect(store.round, isNull);
      expect(store.locale, 'en');
    });

    test('garbage in the round slot reads as no round', () async {
      final store = await openStore({'round': 'not json'});

      expect(store.round, isNull);
    });

    test('json of the wrong shape reads as no round', () async {
      // Reaching the start screen matters more than resuming: this used to
      // throw past the getter and red-screen the app on every launch.
      final payloads = <Object>[
        {'version': 1, 'language': 'nb'},
        {'version': 1, 'language': 7, 'game': <String, Object>{}},
        {
          'version': 1,
          'language': 'nb',
          'game': {'word': 'ost'},
        },
        {
          'version': 1,
          'language': 'nb',
          'game': {'word': '', 'maxWrongGuesses': 6, 'guessed': <String>[]},
        },
        {
          'version': 1,
          'language': 'nb',
          'game': {'word': 'ost', 'maxWrongGuesses': 0, 'guessed': <String>[]},
        },
        {
          'version': 1,
          'language': 'nb',
          'game': {
            'word': 'ost',
            'maxWrongGuesses': 6,
            'guessed': [1, 2],
          },
        },
        {
          'version': 1,
          'language': 'nb',
          'game': {
            'word': 'ost',
            'maxWrongGuesses': 6,
            'guessed': ['os'],
          },
        },
        [1, 2, 3],
      ];

      for (final payload in payloads) {
        final raw = jsonEncode(payload);
        final store = await openStore({'round': raw});

        expect(store.round, isNull, reason: raw);
      }
    });

    test('a round from another schema version reads as no round', () async {
      final store = await openStore({
        'round': jsonEncode({
          'language': 'nb',
          'game': {'word': 'ost', 'maxWrongGuesses': 6, 'guessed': <String>[]},
        }),
      });

      expect(store.round, isNull);
    });
  });

  group('HangmanGame serialisation', () {
    test('round-trips through json with the same state', () {
      final game = HangmanGame(word: 'thunder', maxWrongGuesses: 4)
        ..guess('t')
        ..guess('a')
        ..guess('e');

      final copy = HangmanGame.tryFrom(game.toJson())!;

      expect(copy.maskedWord, game.maskedWord);
      expect(copy.wrongGuesses, game.wrongGuesses);
      expect(copy.remainingGuesses, game.remainingGuesses);
      expect(copy.guessedLetters, game.guessedLetters);
      expect(copy.status, game.status);
    });

    test('a finished round stays finished', () {
      final game = HangmanGame(word: 'ost', maxWrongGuesses: 1)..guess('q');

      expect(HangmanGame.tryFrom(game.toJson())!.status, GameStatus.lost);
    });
  });
}
