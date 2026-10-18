import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

/// Injected so tests do not need the asset bundle.
typedef AssetLoader = Future<String> Function(String path);

class WordRepository {
  WordRepository({AssetLoader? loadAsset, Random? random})
    : _loadAsset = loadAsset ?? rootBundle.loadString,
      _random = random ?? Random();

  static const Set<String> supportedLanguages = {'en', 'nb'};
  static const String fallbackLanguage = 'en';

  final AssetLoader _loadAsset;
  final Random _random;
  final Map<String, List<String>> _cache = {};
  String? _previous;

  /// A word from the list for [languageCode], never the one handed out last.
  Future<String> randomWord(String languageCode) async {
    final words = await _wordsFor(languageCode);
    if (words.length == 1) return _previous = words.single;

    String word;
    do {
      word = words[_random.nextInt(words.length)];
    } while (word == _previous);
    return _previous = word;
  }

  Future<List<String>> _wordsFor(String languageCode) async {
    final language = supportedLanguages.contains(languageCode)
        ? languageCode
        : fallbackLanguage;
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
