import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'game_screen.dart';
import 'info_screen.dart';

/// Start screen: play, the rules, and the language choice.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.selectedLocale,
    required this.onLocaleSelected,
  });

  /// Null means the app follows the device language.
  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleSelected;

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
          style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          strings.homeTagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );

    final controls = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GameScreen()),
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            textStyle: theme.textTheme.titleMedium,
          ),
          child: Text(strings.playButton),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const InfoScreen()),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            textStyle: theme.textTheme.titleMedium,
          ),
          child: Text(strings.infoButton),
        ),
        const SizedBox(height: 32),
        _LanguagePicker(
          selectedLocale: selectedLocale,
          onLocaleSelected: onLocaleSelected,
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Side by side in landscape, otherwise the language choice falls
            // below the fold on a phone held sideways.
            final sideBySide = constraints.maxWidth > constraints.maxHeight;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: sideBySide ? 820 : 420),
                  child: sideBySide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
        Text(strings.languageLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedLocale?.languageCode ?? _systemValue,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            DropdownMenuItem(value: _systemValue, child: Text(strings.languageSystem)),
            DropdownMenuItem(value: 'nb', child: Text(strings.languageNorwegian)),
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
