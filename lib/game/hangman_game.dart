/// Where a game stands.
enum GameStatus { playing, won, lost }

/// What a single call to [HangmanGame.guess] did.
enum GuessOutcome { correct, wrong, alreadyGuessed, gameOver }

/// The rules of Hangman, with no dependency on Flutter so they can be tested
/// without a device.
class HangmanGame {
  HangmanGame({required String word, this.maxWrongGuesses = 6})
      : _word = word.toUpperCase();

  static const String hiddenLetter = '_';

  final String _word;
  final int maxWrongGuesses;
  final Set<String> _guessed = <String>{};

  int _wrongGuesses = 0;

  int get wrongGuesses => _wrongGuesses;

  int get remainingGuesses => maxWrongGuesses - _wrongGuesses;

  Set<String> get guessedLetters => Set.unmodifiable(_guessed);

  /// The word with every letter shown, for the end of a lost game.
  String get revealedWord => _word;

  GameStatus get status {
    if (_wrongGuesses >= maxWrongGuesses) return GameStatus.lost;
    if (_letters.every(_guessed.contains)) return GameStatus.won;
    return GameStatus.playing;
  }

  /// The word as the player sees it, unguessed letters replaced by [hiddenLetter].
  String get maskedWord => _word
      .split('')
      .map((letter) => _guessed.contains(letter) ? letter : hiddenLetter)
      .join();

  bool hasGuessed(String letter) => _guessed.contains(letter.toUpperCase());

  GuessOutcome guess(String letter) {
    if (status != GameStatus.playing) return GuessOutcome.gameOver;

    final guessed = letter.toUpperCase();
    if (_guessed.contains(guessed)) return GuessOutcome.alreadyGuessed;

    _guessed.add(guessed);
    if (_word.contains(guessed)) return GuessOutcome.correct;

    _wrongGuesses++;
    return GuessOutcome.wrong;
  }

  Set<String> get _letters => _word.split('').toSet();
}
