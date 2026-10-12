import 'package:flutter/material.dart';

import '../game/hangman_game.dart';
import '../game/word_repository.dart';
import '../l10n/app_localizations.dart';
import 'gallows_painter.dart';
import 'info_screen.dart';
import 'letter_keyboard.dart';

/// One round of Hangman. The word follows the language the app is running in,
/// so changing language and starting a new game changes the word list too.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.wordRepository});

  /// Injectable so widget tests do not depend on the asset bundle.
  final WordRepository? wordRepository;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final WordRepository _words = widget.wordRepository ?? WordRepository();

  HangmanGame? _game;
  String? _loadedForLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (language != _loadedForLanguage) {
      _loadedForLanguage = language;
      _startGame(language);
    }
  }

  Future<void> _startGame(String language) async {
    final word = await _words.randomWord(language);
    if (!mounted) return;
    setState(() => _game = HangmanGame(word: word));
  }

  void _guess(String letter) {
    final game = _game;
    if (game == null) return;
    setState(() => game.guess(letter));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final game = _game;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: strings.infoButton,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InfoScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: game == null
            ? const Center(child: CircularProgressIndicator())
            : _GameBody(game: game, onGuess: _guess, onPlayAgain: _playAgain),
      ),
    );
  }

  void _playAgain() {
    setState(() => _game = null);
    _startGame(_loadedForLanguage ?? 'en');
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({
    required this.game,
    required this.onGuess,
    required this.onPlayAgain,
  });

  final HangmanGame game;
  final ValueChanged<String> onGuess;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final finished = game.status != GameStatus.playing;

    Widget drawing(double height) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: GallowsPainter(
              wrongGuesses: game.wrongGuesses,
              frameColor: theme.colorScheme.onSurfaceVariant,
              figureColor: theme.colorScheme.primary,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.remainingGuesses(game.remainingGuesses),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );

    final play = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _spaced(finished ? game.revealedWord : game.maskedWord),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 24),
        if (finished)
          _Result(game: game, onPlayAgain: onPlayAgain)
        else
          LetterKeyboard(
            letters: strings.alphabet.split(''),
            isUsed: game.hasGuessed,
            onLetter: onGuess,
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Side by side in landscape, otherwise the keyboard falls below the fold.
        final sideBySide = constraints.maxWidth > constraints.maxHeight;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sideBySide ? 900 : 520),
              child: sideBySide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: drawing(180)),
                        const SizedBox(width: 24),
                        Expanded(child: play),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        drawing(220),
                        const SizedBox(height: 20),
                        play,
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  /// Spaces the letters out so the blanks are countable.
  static String _spaced(String word) => word.split('').join(' ');
}

class _Result extends StatelessWidget {
  const _Result({required this.game, required this.onPlayAgain});

  final HangmanGame game;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final won = game.status == GameStatus.won;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          won ? strings.wonTitle : strings.lostTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: won ? theme.colorScheme.primary : theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          won
              ? strings.wonMessage(game.revealedWord, game.wrongGuesses)
              : strings.lostMessage(game.revealedWord),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onPlayAgain,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          child: Text(strings.playAgainButton),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          child: Text(strings.backToStartButton),
        ),
      ],
    );
  }
}
