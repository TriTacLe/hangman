import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/game/word_repository.dart';

void main() {
  group('WordRepository', () {
    test('reads the list for the language it is asked for', () async {
      final loaded = <String>[];
      final repository = WordRepository(
        loadAsset: (path) async {
          loaded.add(path);
          return 'ost\nsykkel\n';
        },
        random: Random(1),
      );

      await repository.randomWord('nb');
      await repository.randomWord('en');

      expect(loaded, ['assets/words_nb.txt', 'assets/words_en.txt']);
    });

    test('picks a word from the list and nothing else', () async {
      final repository = WordRepository(
        loadAsset: (_) async => 'ost\nsykkel\nblabaer\n',
        random: Random(7),
      );

      for (var i = 0; i < 20; i++) {
        expect(['ost', 'sykkel', 'blabaer'], contains(await repository.randomWord('nb')));
      }
    });

    test('the same seed gives the same word', () async {
      Future<String> pick() => WordRepository(
            loadAsset: (_) async => 'ost\nsykkel\nblabaer\n',
            random: Random(42),
          ).randomWord('nb');

      expect(await pick(), await pick());
    });

    test('blank lines and stray whitespace are ignored', () async {
      final repository = WordRepository(
        loadAsset: (_) async => '\n  ost  \n\n',
        random: Random(1),
      );

      expect(await repository.randomWord('nb'), 'ost');
    });

    test('an unknown language falls back to English', () async {
      final loaded = <String>[];
      final repository = WordRepository(
        loadAsset: (path) async {
          loaded.add(path);
          return 'anchor\n';
        },
        random: Random(1),
      );

      await repository.randomWord('de');

      expect(loaded, ['assets/words_en.txt']);
    });

    test('an empty list is an error, not an empty word', () async {
      final repository = WordRepository(
        loadAsset: (_) async => '\n\n',
        random: Random(1),
      );

      expect(() => repository.randomWord('nb'), throwsStateError);
    });
  });
}
