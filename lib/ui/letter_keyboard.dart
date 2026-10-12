import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// The letters of the active language, laid out so every key clears the 44 by 44
/// minimum for a touch target.
class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({
    super.key,
    required this.letters,
    required this.isUsed,
    required this.onLetter,
  });

  final List<String> letters;
  final bool Function(String letter) isUsed;
  final ValueChanged<String> onLetter;

  static const double _keySize = 48;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final letter in letters)
          SizedBox(
            width: _keySize,
            height: _keySize,
            child: Tooltip(
              message: strings.guessLetterHint(letter),
              child: OutlinedButton(
                onPressed: isUsed(letter) ? null : () => onLetter(letter),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
                child: Text(letter),
              ),
            ),
          ),
      ],
    );
  }
}
