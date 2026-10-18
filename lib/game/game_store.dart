import 'dart:convert';

import 'package:hangman/game/hangman_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What survives the app being killed: the chosen language and the round in
/// progress. Everything that touches SharedPreferences goes through here.
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

  SavedRound? get round {
    final raw = _prefs.getString(_roundKey);
    if (raw == null) return null;
    try {
      return SavedRound.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  Future<void> saveRound(SavedRound round) =>
      _prefs.setString(_roundKey, jsonEncode(round.toJson()));

  Future<void> clearRound() => _prefs.remove(_roundKey);
}

/// A round mid-play, with the language it was started in so the keyboard
/// matches when it is restored.
class SavedRound {
  const SavedRound({required this.language, required this.game});

  factory SavedRound.fromJson(Map<String, dynamic> json) => SavedRound(
    language: json['language'] as String,
    game: HangmanGame.fromJson(json['game'] as Map<String, dynamic>),
  );

  final String language;
  final HangmanGame game;

  Map<String, dynamic> toJson() => {
    'language': language,
    'game': game.toJson(),
  };
}
