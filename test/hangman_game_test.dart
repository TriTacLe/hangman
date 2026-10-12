import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/game/hangman_game.dart';

void main() {
  group('HangmanGame', () {
    test('starts with every letter hidden', () {
      final game = HangmanGame(word: 'sykkel');

      expect(game.maskedWord, '______');
      expect(game.status, GameStatus.playing);
      expect(game.wrongGuesses, 0);
    });

    test('a correct guess reveals every occurrence of the letter', () {
      final game = HangmanGame(word: 'sykkel');

      expect(game.guess('k'), GuessOutcome.correct);
      expect(game.maskedWord, '__KK__');
      expect(game.wrongGuesses, 0);
    });

    test('guessing is case insensitive', () {
      final game = HangmanGame(word: 'sykkel');

      expect(game.guess('S'), GuessOutcome.correct);
      expect(game.maskedWord, 'S_____');
    });

    test('a wrong guess costs one attempt', () {
      final game = HangmanGame(word: 'sykkel');

      expect(game.guess('a'), GuessOutcome.wrong);
      expect(game.wrongGuesses, 1);
      expect(game.guessedLetters, {'A'});
    });

    test('repeating a guess changes nothing', () {
      final game = HangmanGame(word: 'sykkel');

      game.guess('a');
      expect(game.guess('a'), GuessOutcome.alreadyGuessed);
      expect(game.wrongGuesses, 1);
    });

    test('the game is won when the last letter is revealed', () {
      final game = HangmanGame(word: 'ost');

      game.guess('o');
      game.guess('s');
      expect(game.status, GameStatus.playing);
      game.guess('t');

      expect(game.status, GameStatus.won);
      expect(game.maskedWord, 'OST');
    });

    test('the game is lost when the wrong guesses reach the cap', () {
      final game = HangmanGame(word: 'ost', maxWrongGuesses: 2);

      game.guess('a');
      expect(game.status, GameStatus.playing);
      game.guess('b');

      expect(game.status, GameStatus.lost);
      expect(game.remainingGuesses, 0);
    });

    test('a finished game refuses further guesses', () {
      final game = HangmanGame(word: 'ost', maxWrongGuesses: 1);
      game.guess('a');

      expect(game.status, GameStatus.lost);
      expect(game.guess('o'), GuessOutcome.gameOver);
      expect(game.maskedWord, '___');
    });

    test('Norwegian letters are handled like any other letter', () {
      final game = HangmanGame(word: 'blåbær');

      expect(game.guess('å'), GuessOutcome.correct);
      expect(game.guess('æ'), GuessOutcome.correct);
      expect(game.maskedWord, '__Å_Æ_');
    });

    test('the revealed word is shown in full once the game is lost', () {
      final game = HangmanGame(word: 'ost', maxWrongGuesses: 1);
      game.guess('a');

      expect(game.revealedWord, 'OST');
    });
  });
}
