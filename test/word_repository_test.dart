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
        expect([
          'ost',
          'sykkel',
          'blabaer',
        ], contains(await repository.randomWord('nb')));
      }
    });

    test('the same seed gives the same sequence of words', () async {
      Future<List<String>> threeWords() async {
        final repository = WordRepository(
          loadAsset: (_) async => 'ost\nsykkel\nblabaer\n',
          random: Random(42),
        );
        return [
          await repository.randomWord('nb'),
          await repository.randomWord('nb'),
          await repository.randomWord('nb'),
        ];
      }

      final first = await threeWords();

      expect(await threeWords(), first);
      // Same seed, and the no-repeat rule still holds inside the sequence.
      expect(first[0], isNot(first[1]));
      expect(first[1], isNot(first[2]));
    });

    test('a list of identical words returns instead of spinning', () async {
      final repository = WordRepository(
        loadAsset: (_) async => 'ost\nost\nost\n',
        random: Random(1),
      );

      expect(await repository.randomWord('nb'), 'ost');
      expect(await repository.randomWord('nb'), 'ost');
    });

    test('the last word of one language does not block the other', () async {
      final repository = WordRepository(
        loadAsset: (path) async => path.contains('nb') ? 'ost' : 'cheese',
        random: Random(3),
      );

      expect(await repository.randomWord('nb'), 'ost');
      expect(await repository.randomWord('en'), 'cheese');
      expect(await repository.randomWord('nb'), 'ost');
    });

    test('never hands out the same word twice in a row', () async {
      final repository = WordRepository(
        loadAsset: (_) async => 'ost\nsykkel\nblabaer\n',
        random: Random(3),
      );

      var previous = await repository.randomWord('nb');
      for (var i = 0; i < 30; i++) {
        final next = await repository.randomWord('nb');
        expect(next, isNot(previous));
        previous = next;
      }
    });

    test('a one word list is the one word, every time', () async {
      final repository = WordRepository(
        loadAsset: (_) async => 'ost\n',
        random: Random(1),
      );

      expect(await repository.randomWord('nb'), 'ost');
      expect(await repository.randomWord('nb'), 'ost');
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
