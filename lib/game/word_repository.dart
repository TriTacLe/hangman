import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

/// Injected so tests do not need the asset bundle.
typedef AssetLoader = Future<String> Function(String path);

class WordRepository {
  WordRepository({AssetLoader? loadAsset, Random? random})
    : _loadAsset = loadAsset ?? rootBundle.loadString,
      _random = random ?? Random();

  static const String fallbackLanguage = 'en';

  /// The letters a round can use, per language, which drive the hardware-key
  /// filter as well as the keyboard.
  static const Map<String, String> alphabets = {
    'en': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'nb': 'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅ',
  };

  static Set<String> get supportedLanguages => alphabets.keys.toSet();

  /// The alphabet for [languageCode], or the fallback language's for one that
  /// is not shipped.
  static String alphabetFor(String languageCode) =>
      alphabets[languageCode] ?? alphabets[fallbackLanguage]!;

  final AssetLoader _loadAsset;
  final Random _random;
  final Map<String, List<String>> _cache = {};

  /// Per language, so switching language cannot be blocked by the word the
  /// other list handed out.
  final Map<String, String> _previous = {};

  /// A word for [languageCode], avoiding the one handed out last and giving up
  /// after a few tries rather than spinning on identical entries.
  Future<String> randomWord(String languageCode) async {
    final words = await _wordsFor(languageCode);
    final language = _resolve(languageCode);
    final previous = _previous[language];

    var word = words[_random.nextInt(words.length)];
    for (var attempt = 0; attempt < 10 && word == previous; attempt++) {
      word = words[_random.nextInt(words.length)];
    }

    return _previous[language] = word;
  }

  static String _resolve(String languageCode) =>
      alphabets.containsKey(languageCode) ? languageCode : fallbackLanguage;

  Future<List<String>> _wordsFor(String languageCode) async {
    final language = _resolve(languageCode);
    final cached = _cache[language];
    if (cached != null) return cached;

    final contents = await _loadAsset('assets/words_$language.txt');
    final words = contents
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      throw StateError('The word list for $language is empty');
    }
    return _cache[language] = words;
  }
}
