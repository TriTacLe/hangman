enum GameStatus { playing, won, lost }

enum GuessOutcome { correct, wrong, alreadyGuessed, gameOver }

/// The rules, kept free of Flutter imports so they run under test without
/// a device.
class HangmanGame {
  HangmanGame({required String word, this.maxWrongGuesses = 6})
    : _word = word.toUpperCase(),
      _letters = word.toUpperCase().split('').toSet();

  /// Rebuilds a round from what [toJson] wrote, replaying the guesses so the
  /// wrong count comes out the same.
  factory HangmanGame.fromJson(Map<String, dynamic> json) {
    final game = HangmanGame(
      word: json['word'] as String,
      maxWrongGuesses: json['maxWrongGuesses'] as int,
    );
    (json['guessed'] as List<dynamic>).cast<String>().forEach(game.guess);
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
    if (status != GameStatus.playing) return GuessOutcome.gameOver;

    final guessed = letter.toUpperCase();
    if (_guessed.contains(guessed)) return GuessOutcome.alreadyGuessed;

    _guessed.add(guessed);
    if (_word.contains(guessed)) return GuessOutcome.correct;

    _wrongGuesses++;
    return GuessOutcome.wrong;
  }

  Map<String, dynamic> toJson() => {
    'word': _word,
    'maxWrongGuesses': maxWrongGuesses,
    'guessed': _guessed.toList(),
  };
}
