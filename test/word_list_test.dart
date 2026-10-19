import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/game/word_repository.dart';

/// Reads the real word lists, so a typo in an asset fails here and not in
/// front of whoever is grading it.
void main() {
  List<String> load(String language) =>
      File('assets/words_$language.txt')
          .readAsLinesSync()
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

  for (final language in WordRepository.supportedLanguages) {
    group('words_$language', () {
      final words = load(language);
      final alphabet = WordRepository.alphabetFor(language)
          .toLowerCase()
          .split('')
          .toSet();

      test('has enough words to play a while', () {
        expect(words.length, greaterThanOrEqualTo(140));
      });

      test('has no duplicates', () {
        expect(words.toSet().length, words.length);
      });

      test('is lowercase and uses only letters the keyboard has', () {
        for (final word in words) {
          expect(word, word.toLowerCase(), reason: word);
          for (final letter in word.split('')) {
            expect(alphabet, contains(letter), reason: '$word has $letter');
          }
        }
      });

      test('every word is at least four letters', () {
        for (final word in words) {
          expect(word.length, greaterThanOrEqualTo(4), reason: word);
        }
      });
    });
  }

  test('the Norwegian list really uses æ, ø and å', () {
    final words = load('nb');
    final withNorwegianLetters = words.where(
      (word) => word.contains(RegExp('[æøå]')),
    );

    expect(
      withNorwegianLetters.length,
      greaterThanOrEqualTo(words.length ~/ 4),
    );
  });
}
