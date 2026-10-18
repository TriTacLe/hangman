import 'package:flutter/material.dart';

import 'package:hangman/l10n/app_localizations.dart';

/// Opens the rules over whatever is behind them, so a running round stays put.
Future<void> showInfoDialog(BuildContext context) {
  return showDialog<void>(context: context, builder: (_) => const InfoDialog());
}

/// The rules, a paragraph at a time so a screen reader can move through them.
class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final paragraphs = strings.infoRules.split('\n\n');

    return AlertDialog(
      title: Text(strings.infoTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final paragraph in paragraphs) ...[
              Text(
                paragraph,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(height: 1.5),
              ),
              if (paragraph != paragraphs.last) const SizedBox(height: 16),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          // The app's buttons are full width by default, which in a dialog
          // stretches the action across the whole thing.
          style: TextButton.styleFrom(
            minimumSize: const Size(88, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.closeButton),
        ),
      ],
    );
  }
}
