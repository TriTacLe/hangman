import 'package:flutter/material.dart';

import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/ui/theme.dart';

/// How a key looks once it has been used.
enum LetterState { untouched, correct, wrong }

/// Keys are 48 by 48 and grow with the text scale. A hit thickens the border, a
/// miss strikes the letter through, so the state survives without colour.
class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({
    required this.letters,
    required this.stateOf,
    required this.onLetter,
    super.key,
  });

  final List<String> letters;
  final LetterState Function(String letter) stateOf;
  final ValueChanged<String> onLetter;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final letter in letters)
          _Key(
            letter: letter,
            state: stateOf(letter),
            label: strings.guessLetterHint(letter),
            onPressed: () => onLetter(letter),
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.letter,
    required this.state,
    required this.label,
    required this.onPressed,
  });

  final String letter;
  final LetterState state;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final used = state != LetterState.untouched;
    final size = MediaQuery.textScalerOf(context)
        .clamp(maxScaleFactor: 2)
        .scale(HangmanShapes.keySize);

    // Three states that do not rely on colour alone: a key waiting is a ruled
    // box, a hit is filled, a miss loses its box and gets struck through.
    final foreground = switch (state) {
      LetterState.untouched => colors.onSurface,
      LetterState.correct => colors.onSurface,
      LetterState.wrong => colors.onSurfaceVariant,
    };
    final border = switch (state) {
      LetterState.untouched => Border.all(
        color: colors.outline,
        width: HangmanShapes.border,
      ),
      LetterState.correct => Border.all(
        color: colors.secondary,
        width: HangmanShapes.borderHeavy,
      ),
      LetterState.wrong => Border.all(
        color: colors.error,
        width: HangmanShapes.border,
      ),
    };

    return Semantics(
      label: label,
      button: true,
      enabled: !used,
      // Without this the key's own letter is read after the label.
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: Colors.transparent,
          borderRadius: HangmanShapes.key,
          child: InkWell(
            borderRadius: HangmanShapes.key,
            onTap: used ? null : onPressed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: HangmanShapes.key,
                border: border,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: foreground,
                    fontWeight: state == LetterState.untouched
                        ? FontWeight.w600
                        : FontWeight.w700,
                    decoration: state == LetterState.wrong
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
