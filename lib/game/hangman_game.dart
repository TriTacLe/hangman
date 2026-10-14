enum GameStatus { playing, won, lost }

enum GuessOutcome { correct, wrong, alreadyGuessed, gameOver }

/// The rules, kept free of Flutter imports so they run under test without
/// a device.
class HangmanGame {
  HangmanGame({required String word, this.maxWrongGuesses = 6})
    : assert(word.isNotEmpty, 'A round needs a word to guess'),
      assert(maxWrongGuesses > 0, 'A round needs at least one guess'),
      _word = word.toUpperCase(),
      _letters = word.toUpperCase().split('').toSet();

  /// Rebuilds a round from [toJson], replaying the guesses. Null for anything
  /// this version did not write, so a stale payload is dropped, not thrown on.
  static HangmanGame? tryFrom(Map<String, dynamic> json) {
    final word = json['word'];
    final maxWrongGuesses = json['maxWrongGuesses'];
    final guessed = json['guessed'];
    if (word is! String || word.isEmpty) return null;
    if (maxWrongGuesses is! int || maxWrongGuesses <= 0) return null;
    if (guessed is! List) return null;

    final letters = guessed.whereType<String>().toList();
    if (letters.length != guessed.length) return null;
    if (letters.any((letter) => letter.length != 1)) return null;

    final game = HangmanGame(word: word, maxWrongGuesses: maxWrongGuesses);
    letters.forEach(game.guess);
    return game;
  }

  static const String hiddenLetter = '_';

  final String _word;
  final Set<String> _letters;
  final int maxWrongGuesses;
  final Set<String> _guessed = <String>{};

  int _wrongGuesses = 0;

  int get wrongGuesses => _wrongGuesses;

  int get remainingGuesses => maxWrongGuesses - _wrongGuesses;

  Set<String> get guessedLetters => Set.unmodifiable(_guessed);

  /// Every letter shown, for the end of a lost game.
  String get revealedWord => _word;

  /// Running out of guesses loses the round even if the last guess completed
  /// the word, which cannot happen through [guess] but can through [tryFrom].
  GameStatus get status {
    if (_wrongGuesses >= maxWrongGuesses) return GameStatus.lost;
    if (_letters.every(_guessed.contains)) return GameStatus.won;
    return GameStatus.playing;
  }

  /// The word as the player sees it, with [hiddenLetter] for what is left.
  String get maskedWord => _word
      .split('')
      .map((letter) => _guessed.contains(letter) ? letter : hiddenLetter)
      .join();

  bool hasGuessed(String letter) => _guessed.contains(letter.toUpperCase());

  bool contains(String letter) => _letters.contains(letter.toUpperCase());

  GuessOutcome guess(String letter) {
    assert(letter.length == 1, 'A guess is one letter, not "$letter"');
    if (status != GameStatus.playing) return GuessOutcome.gameOver;

    final guessed = letter.toUpperCase();
    if (_guessed.contains(guessed)) return GuessOutcome.alreadyGuessed;

    _guessed.add(guessed);
    if (_letters.contains(guessed)) return GuessOutcome.correct;

    _wrongGuesses++;
    return GuessOutcome.wrong;
  }

  Map<String, dynamic> toJson() => {
    'word': _word,
    'maxWrongGuesses': maxWrongGuesses,
    'guessed': _guessed.toList(),
  };
}
