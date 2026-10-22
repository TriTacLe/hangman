import 'dart:convert';

import 'package:hangman/game/hangman_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything that survives the app being killed: the chosen language and the
/// round in progress.
class GameStore {
  GameStore(this._prefs);

  static Future<GameStore> open() async =>
      GameStore(await SharedPreferences.getInstance());

  static const _localeKey = 'locale';
  static const _roundKey = 'round';

  final SharedPreferences _prefs;

  /// The language the player picked, or null to follow the device.
  String? get locale => _prefs.getString(_localeKey);

  Future<void> saveLocale(String? languageCode) => languageCode == null
      ? _prefs.remove(_localeKey)
      : _prefs.setString(_localeKey, languageCode);

  /// The round left mid-play, or null when there is none this version can read,
  /// since the start screen reads it while building and must not throw.
  SavedRound? get round {
    final raw = _prefs.getString(_roundKey);
    if (raw == null) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;

    return SavedRound.tryFrom(decoded);
  }

  Future<void> saveRound(SavedRound round) =>
      _prefs.setString(_roundKey, jsonEncode(round.toJson()));

  Future<void> clearRound() => _prefs.remove(_roundKey);
}

/// A round mid-play, with the language it was started in so the keyboard
/// matches when it is restored.
class SavedRound {
  const SavedRound({required this.language, required this.game});

  /// Bumped whenever the stored shape changes, so another version's payload is
  /// discarded rather than guessed at.
  static const int schemaVersion = 1;

  /// Null unless the payload is a round of [schemaVersion] with every field
  /// the shape it should be.
  static SavedRound? tryFrom(Map<String, dynamic> json) {
    if (json['version'] != schemaVersion) return null;

    final language = json['language'];
    final game = json['game'];
    if (language is! String || game is! Map<String, dynamic>) return null;

    final parsed = HangmanGame.tryFrom(game);
    return parsed == null ? null : SavedRound(language: language, game: parsed);
  }

  final String language;
  final HangmanGame game;

  Map<String, dynamic> toJson() => {
    'version': schemaVersion,
    'language': language,
    'game': game.toJson(),
  };
}
