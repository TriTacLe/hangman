import 'dart:async';

import 'package:flutter/material.dart';

import 'package:hangman/game/game_store.dart';
import 'package:hangman/game/hangman_game.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/ui/game_screen.dart';
import 'package:hangman/ui/info_dialog.dart';
import 'package:hangman/ui/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.selectedLocale,
    required this.onLocaleSelected,
    this.store,
    super.key,
  });

  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleSelected;
  final GameStore? store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Dialog actions sit side by side, so they keep a comfortable tap target
/// without taking the full width the rest of the app's buttons do.
final ButtonStyle _dialogAction = TextButton.styleFrom(
  minimumSize: const Size(88, 48),
  padding: const EdgeInsets.symmetric(horizontal: 20),
);

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _open(BuildContext context, {SavedRound? savedRound}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(store: widget.store, savedRound: savedRound),
      ),
    );
    // Coming back from a round changes whether there is one to continue.
    if (mounted) setState(() {});
  }

  /// Starting a new game throws the saved round away, so it asks first.
  Future<void> _playInsteadOfContinuing() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.newGameTitle),
        content: Text(strings.newGameMessage),
        actions: [
          TextButton(
            // The app's buttons are full width by default, which in a dialog
            // stacks the two actions down the middle.
            style: _dialogAction,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancelButton),
          ),
          TextButton(
            style: _dialogAction,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.newGameConfirm),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    await _open(context);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final banner = Container(
      width: double.infinity,
      color: theme.colorScheme.onSurface,
      padding: const EdgeInsets.symmetric(vertical: HangmanShapes.gap),
      child: Text(
        strings.appTitle,
        textAlign: TextAlign.center,
        style: theme.textTheme.displaySmall?.copyWith(
          color: theme.colorScheme.surface,
        ),
      ),
    );

    final saved = widget.store?.round;
    // A round left mid-play is only worth resuming if it is still playable.
    final canContinue =
        saved != null && saved.game.status == GameStatus.playing;

    final controls = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canContinue) ...[
          FilledButton(
            onPressed: () => unawaited(_open(context, savedRound: saved)),
            child: Text(strings.continueButton),
          ),
          const SizedBox(height: HangmanShapes.tight),
          OutlinedButton(
            onPressed: () => unawaited(_playInsteadOfContinuing()),
            child: Text(strings.playButton),
          ),
        ] else
          FilledButton(
            onPressed: () => unawaited(_open(context)),
            child: Text(strings.playButton),
          ),
        const SizedBox(height: HangmanShapes.tight),
        TextButton(
          onPressed: () => unawaited(showInfoDialog(context)),
          child: Text(strings.infoButton),
        ),
        const SizedBox(height: HangmanShapes.loose),
        _LanguageToggle(
          selectedLocale: widget.selectedLocale,
          onLocaleSelected: widget.onLocaleSelected,
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sideBySide = constraints.maxWidth > constraints.maxHeight;

            if (sideBySide) {
              return Row(
                children: [
                  Expanded(child: Align(child: banner)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(HangmanShapes.gap),
                      child: controls,
                    ),
                  ),
                ],
              );
            }

            // Portrait: title high against the margin, controls low, the air
            // between them rather than wrapped evenly around everything.
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                // Bounded height, so the spacer below can resolve while the
                // whole thing still scrolls at a large font size.
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      banner,
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          HangmanShapes.loose,
                          HangmanShapes.gap,
                          HangmanShapes.loose,
                          HangmanShapes.gap,
                        ),
                        child: controls,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Two languages with the filled one in use, so there is nothing to read and
/// nothing to open.
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({
    required this.selectedLocale,
    required this.onLocaleSelected,
  });

  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    // Before anything is picked the app follows the device, so the toggle
    // shows whichever language that turned out to be.
    final current =
        selectedLocale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Row(
      children: [
        Expanded(
          child: _LanguageButton(
            label: strings.languageNorwegian,
            selected: current == 'nb',
            onTap: () => onLocaleSelected(const Locale('nb')),
          ),
        ),
        const SizedBox(width: HangmanShapes.tight),
        Expanded(
          child: _LanguageButton(
            label: strings.languageEnglish,
            selected: current == 'en',
            onTap: () => onLocaleSelected(const Locale('en')),
          ),
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: selected
          ? FilledButton(onPressed: onTap, child: Text(label))
          : OutlinedButton(onPressed: onTap, child: Text(label)),
    );
  }
}
