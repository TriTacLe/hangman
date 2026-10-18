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
  });

  group('HangmanGame serialisation', () {
    test('round-trips through json with the same state', () {
      final game = HangmanGame(word: 'thunder', maxWrongGuesses: 4)
        ..guess('t')
        ..guess('a')
        ..guess('e');

      final copy = HangmanGame.fromJson(game.toJson());

      expect(copy.maskedWord, game.maskedWord);
      expect(copy.wrongGuesses, game.wrongGuesses);
      expect(copy.remainingGuesses, game.remainingGuesses);
      expect(copy.guessedLetters, game.guessedLetters);
      expect(copy.status, game.status);
    });

    test('a finished round stays finished', () {
      final game = HangmanGame(word: 'ost', maxWrongGuesses: 1)..guess('q');

      expect(HangmanGame.fromJson(game.toJson()).status, GameStatus.lost);
    });
  });
}
