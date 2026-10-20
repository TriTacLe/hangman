import 'package:flutter/material.dart';

import 'package:hangman/game/game_store.dart';
import 'package:hangman/game/hangman_game.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/ui/game_screen.dart';
import 'package:hangman/ui/info_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final heading = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          strings.appTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          strings.homeTagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
            onPressed: () => _open(context, savedRound: saved),
            child: Text(strings.continueButton),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _open(context),
            child: Text(strings.playButton),
          ),
        ] else
          FilledButton(
            onPressed: () => _open(context),
            child: Text(strings.playButton),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const InfoScreen())),
          child: Text(strings.infoButton),
        ),
        const SizedBox(height: 32),
        _LanguagePicker(
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

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: sideBySide ? 820 : 420),
                  child: sideBySide
                      ? Row(
                          children: [
                            Expanded(child: heading),
                            const SizedBox(width: 32),
                            Expanded(child: controls),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            heading,
                            const SizedBox(height: 40),
                            controls,
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

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({
    required this.selectedLocale,
    required this.onLocaleSelected,
  });

  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleSelected;

  static const String _systemValue = 'system';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.languageLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          // Without this the Norwegian label runs past the field on a phone.
          isExpanded: true,
          initialValue: selectedLocale?.languageCode ?? _systemValue,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            DropdownMenuItem(
              value: _systemValue,
              child: Text(strings.languageSystem),
            ),
            DropdownMenuItem(
              value: 'nb',
              child: Text(strings.languageNorwegian),
            ),
            DropdownMenuItem(value: 'en', child: Text(strings.languageEnglish)),
          ],
          onChanged: (value) => onLocaleSelected(
            value == null || value == _systemValue ? null : Locale(value),
          ),
        ),
      ],
    );
  }
}
