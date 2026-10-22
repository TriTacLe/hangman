import 'package:flutter/material.dart';

import 'package:hangman/game/hangman_game.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/ui/theme.dart';

/// One bordered box per letter. The boxes are drawn, so the semantics come from
/// a label instead of the glyphs.
class WordDisplay extends StatelessWidget {
  const WordDisplay({
    required this.word,
    required this.revealed,
    this.revealedColor,
    super.key,
  });

  /// Masked while the game runs, the whole word once it is over.
  final String word;

  /// True once the game is finished and every letter is shown.
  final bool revealed;

  /// Colour for the revealed word: green on a win, red on a loss.
  final Color? revealedColor;

  static const double _slotWidth = 34;
  static const double _slotHeight = 44;
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final letters = word.split('');
    final hidden = letters
        .where((letter) => letter == HangmanGame.hiddenLetter)
        .length;
    final spoken = letters
        .map(
          (letter) =>
              letter == HangmanGame.hiddenLetter ? strings.blankLetter : letter,
        )
        .join(', ');
    final scale = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 2);
    final slotWidth = scale.scale(_slotWidth);
    final slotHeight = scale.scale(_slotHeight);

    return Semantics(
      label: '$spoken. ${strings.wordProgress(hidden)}',
      // Every guess changes this, which is the one thing a player cannot see.
      liveRegion: true,
      excludeSemantics: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: _gap,
        runSpacing: 14,
        children: [
          for (final letter in letters)
            Container(
              width: slotWidth,
              height: slotHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: HangmanShapes.key,
                border: Border.all(
                  color: theme.colorScheme.onSurface,
                  width: HangmanShapes.border,
                ),
              ),
              child: Text(
                letter == HangmanGame.hiddenLetter ? '' : letter,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: revealed
                      ? (revealedColor ?? theme.colorScheme.onSurface)
                      : theme.colorScheme.onSurface,
                  decoration: revealed && revealedColor != null
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: revealedColor,
                  decorationThickness: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
