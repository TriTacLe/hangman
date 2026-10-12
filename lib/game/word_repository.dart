import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

/// Reads an asset as text. Injected so tests do not need the asset bundle.
typedef AssetLoader = Future<String> Function(String path);

/// Picks the word to guess from the list belonging to a language.
class WordRepository {
  WordRepository({AssetLoader? loadAsset, Random? random})
      : _loadAsset = loadAsset ?? rootBundle.loadString,
        _random = random ?? Random();

  static const Set<String> supportedLanguages = {'en', 'nb'};
  static const String fallbackLanguage = 'en';

  final AssetLoader _loadAsset;
  final Random _random;

  Future<String> randomWord(String languageCode) async {
    final language = supportedLanguages.contains(languageCode)
        ? languageCode
        : fallbackLanguage;

    final contents = await _loadAsset('assets/words_$language.txt');
    final words = contents
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      throw StateError('The word list for $language is empty');
    }

    return words[_random.nextInt(words.length)];
  }
}
