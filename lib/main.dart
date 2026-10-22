import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:hangman/game/game_store.dart';
import 'package:hangman/game/word_repository.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/ui/home_screen.dart';
import 'package:hangman/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GameStore? store;
  try {
    store = await GameStore.open();
  } on Object {
    // The game is playable without anything remembered between launches, so a
    // broken preferences store must not stop the app from starting.
    store = null;
  }

  runApp(HangmanApp(store: store));
}

class HangmanApp extends StatefulWidget {
  const HangmanApp({super.key, this.store});

  /// Null means nothing is remembered between launches, which the tests use.
  final GameStore? store;

  @override
  State<HangmanApp> createState() => _HangmanAppState();
}

class _HangmanAppState extends State<HangmanApp> {
  /// Null means follow the language the device is set to.
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    final saved = widget.store?.locale;
    // Ignore a stored language this build no longer ships.
    final shipped = AppLocalizations.supportedLocales.any(
      (locale) => locale.languageCode == saved,
    );
    if (saved != null && shipped) _locale = Locale(saved);
  }

  void _selectLocale(Locale? locale) {
    setState(() => _locale = locale);
    unawaited(widget.store?.saveLocale(locale?.languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: _resolveLocale,
      theme: hangmanLightTheme(),
      darkTheme: hangmanDarkTheme(),
      home: HomeScreen(
        selectedLocale: _locale,
        onLocaleSelected: _selectLocale,
        store: widget.store,
      ),
    );
  }

  /// First of the device's preferences that the app ships. Android reports
  /// Norwegian as nb, nn or no depending on the device.
  Locale _resolveLocale(List<Locale>? wanted, Iterable<Locale> supported) {
    const norwegian = {'nb', 'nn', 'no'};

    for (final locale in wanted ?? const <Locale>[]) {
      if (norwegian.contains(locale.languageCode)) return const Locale('nb');
      for (final candidate in supported) {
        if (candidate.languageCode == locale.languageCode) return candidate;
      }
    }

    return const Locale(WordRepository.fallbackLanguage);
  }
}
