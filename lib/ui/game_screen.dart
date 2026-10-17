import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hangman/game/game_store.dart';
import 'package:hangman/game/hangman_game.dart';
import 'package:hangman/game/word_repository.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/ui/gallows_painter.dart';
import 'package:hangman/ui/info_dialog.dart';
import 'package:hangman/ui/letter_keyboard.dart';
import 'package:hangman/ui/theme.dart';
import 'package:hangman/ui/word_display.dart';

/// One round of Hangman. The word follows the language the app is running in,
/// so changing language and starting a new game changes the word list too.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.wordRepository,
    this.store,
    this.savedRound,
  });

  /// Injectable so widget tests do not depend on the asset bundle.
  final WordRepository? wordRepository;

  /// Where the round is kept between guesses. Null means it is not kept.
  final GameStore? store;

  /// A round to pick up instead of drawing a new word.
  final SavedRound? savedRound;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final WordRepository _words = widget.wordRepository ?? WordRepository();

  HangmanGame? _game;

  /// The language the round on screen belongs to.
  String? _language;

  /// The round handed in to be resumed, cleared once it has been, so a later
  /// language change cannot bring an abandoned round back.
  SavedRound? _restorable;

  /// Persistence runs one write at a time, so a save cannot land after the
  /// clear that ended the round.
  Future<void> _writes = Future<void>.value();

  bool _loadFailed = false;

  /// Held rather than left to [Focus.autofocus] alone, so the hardware
  /// keyboard still works after the info page has been on top of the game.
  final FocusNode _keyboardFocus = FocusNode(debugLabel: 'hangman keyboard');

  @override
  void initState() {
    super.initState();
    _restorable = widget.savedRound;
  }

  @override
  void dispose() {
    _keyboardFocus.dispose();
    super.dispose();
  }

  Future<void> _openInfo() async {
    await showInfoDialog(context);
    if (mounted) _keyboardFocus.requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (language == _language) return;
    _language = language;

    final restorable = _restorable;
    _restorable = null;
    // A round that is already won or lost is not worth picking up, even
    // though the start screen normally filters those out before we get here.
    final resumable =
        _game == null &&
        restorable != null &&
        restorable.language == language &&
        restorable.game.status == GameStatus.playing;
    if (resumable) {
      _game = restorable.game;
    } else {
      unawaited(_startGame(language));
    }
  }

  Future<void> _startGame(String language) async {
    try {
      final word = await _words.randomWord(language);
      // A language change while the word was in flight wins over this load.
      if (!mounted || language != _language) return;
      setState(() {
        _game = HangmanGame(word: word);
        _loadFailed = false;
      });
      _persist(language);
    } on Object {
      // A missing or empty word list is the player's problem to see, not an
      // endless spinner.
      if (!mounted || language != _language) return;
      setState(() {
        _game = null;
        _loadFailed = true;
      });
    }
  }

  void _guess(String letter) {
    final game = _game;
    final language = _language;
    if (game == null || language == null) return;
    setState(() => game.guess(letter));
    _persist(language);
  }

  /// Saves after every change and drops a finished round. [language] is the one
  /// the round started in, not whatever is on screen when the write runs.
  void _persist(String language) {
    final store = widget.store;
    final game = _game;
    if (store == null || game == null) return;

    _writes = _writes
        .then(
          (_) => game.status == GameStatus.playing
              ? store.saveRound(SavedRound(language: language, game: game))
              : store.clearRound(),
        )
        .catchError((Object _) {});
  }

  /// Letters typed on a hardware keyboard count as guesses, which is how most
  /// people will play on an emulator.
  KeyEventResult _onKey(FocusNode node, KeyEvent event, String alphabet) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final typed = event.character?.toUpperCase();
    if (typed == null || typed.length != 1 || !alphabet.contains(typed)) {
      return KeyEventResult.ignored;
    }
    final game = _game;
    if (game == null || game.status != GameStatus.playing) {
      return KeyEventResult.ignored;
    }
    if (!game.hasGuessed(typed)) _guess(typed);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final game = _game;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: strings.infoButton,
            onPressed: () => unawaited(_openInfo()),
          ),
        ],
      ),
      body: SafeArea(
        child: switch ((game, _loadFailed)) {
          (_, true) => _LoadFailed(
            onRetry: () => unawaited(
              _startGame(_language ?? WordRepository.fallbackLanguage),
            ),
          ),
          (null, _) => Semantics(
            label: strings.loadingWord,
            liveRegion: true,
            child: const Center(child: CircularProgressIndicator()),
          ),
          (final HangmanGame started, _) => Focus(
            focusNode: _keyboardFocus,
            autofocus: true,
            onKeyEvent: (node, event) => _onKey(
              node,
              event,
              WordRepository.alphabetFor(
                _language ?? WordRepository.fallbackLanguage,
              ),
            ),
            child: _GameBody(
              game: started,
              onGuess: _guess,
              onPlayAgain: _playAgain,
            ),
          ),
        },
      ),
    );
  }

  void _playAgain() {
    final language = _language ?? WordRepository.fallbackLanguage;
    setState(() {
      _game = null;
      _loadFailed = false;
    });
    unawaited(_startGame(language));
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.loadFailedTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(strings.retryButton)),
          ],
        ),
      ),
    );
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

  static const double _portraitDrawingHeight = 220;
  static const double _landscapeDrawingHeight = 170;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Side by side in landscape, else the keyboard falls below the fold.
        final sideBySide = constraints.maxWidth > constraints.maxHeight;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: HangmanShapes.gap,
            vertical: HangmanShapes.snug,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sideBySide ? 900 : 520),
              child: sideBySide
                  ? Row(
                      children: [
                        // The keyboard needs the wider half: given an even
                        // split, the last Norwegian row falls below the fold.
                        Expanded(
                          flex: 2,
                          child: _Drawing(
                            game: game,
                            height: _landscapeDrawingHeight,
                          ),
                        ),
                        const SizedBox(width: HangmanShapes.loose),
                        Expanded(
                          flex: 3,
                          child: _Play(
                            game: game,
                            onGuess: onGuess,
                            onPlayAgain: onPlayAgain,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Drawing(game: game, height: _portraitDrawingHeight),
                        const SizedBox(height: HangmanShapes.gap),
                        _Play(
                          game: game,
                          onGuess: onGuess,
                          onPlayAgain: onPlayAgain,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _Drawing extends StatelessWidget {
  const _Drawing({required this.game, required this.height});

  final HangmanGame game;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The drawing says the same thing as the count below it, so it is
        // left out of the semantics tree rather than described twice.
        ExcludeSemantics(
          child: SizedBox(
            height: height,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: GallowsPainter(
                  wrongGuesses: game.wrongGuesses,
                  frameColor: theme.colorScheme.onSurface,
                  figureColor: theme.colorScheme.error,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: HangmanShapes.snug),
        Semantics(
          liveRegion: true,
          child: Text(
            AppLocalizations.of(context)
                .remainingGuesses(game.remainingGuesses),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Play extends StatelessWidget {
  const _Play({
    required this.game,
    required this.onGuess,
    required this.onPlayAgain,
  });

  final HangmanGame game;
  final ValueChanged<String> onGuess;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final finished = game.status != GameStatus.playing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        WordDisplay(
          word: finished ? game.revealedWord : game.maskedWord,
          revealed: finished,
          revealedColor: game.status == GameStatus.won
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: HangmanShapes.loose),
        if (finished)
          _Result(game: game, onPlayAgain: onPlayAgain)
        else
          LetterKeyboard(
            letters: WordRepository.alphabetFor(
              Localizations.localeOf(context).languageCode,
            ).split(''),
            stateOf: (letter) => _stateOf(game, letter),
            onLetter: onGuess,
          ),
      ],
    );
  }

  static LetterState _stateOf(HangmanGame game, String letter) {
    if (!game.hasGuessed(letter)) return LetterState.untouched;
    return game.contains(letter) ? LetterState.correct : LetterState.wrong;
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.game, required this.onPlayAgain});

  final HangmanGame game;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final won = game.status == GameStatus.won;

    final accent = won ? theme.colorScheme.secondary : theme.colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          headingLevel: 1,
          child: Text(
            won ? strings.wonTitle : strings.lostTitle,
            style: theme.textTheme.headlineSmall?.copyWith(color: accent),
          ),
        ),
        const SizedBox(height: HangmanShapes.snug),
        Container(height: HangmanShapes.borderHeavy, width: 72, color: accent),
        const SizedBox(height: HangmanShapes.gap),
        Text(
          won
              ? strings.wonMessage(game.revealedWord, game.wrongGuesses)
              : strings.lostMessage(game.revealedWord),
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: HangmanShapes.loose),
        FilledButton(
          onPressed: onPlayAgain,
          child: Text(strings.playAgainButton),
        ),
        const SizedBox(height: HangmanShapes.tight),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.backToStartButton),
        ),
      ],
    );
  }
}
