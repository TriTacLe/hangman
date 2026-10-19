import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:hangman/game/game_store.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/ui/home_screen.dart';
import 'package:hangman/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HangmanApp(store: await GameStore.open()));
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
    if (saved != null) _locale = Locale(saved);
  }

  void _selectLocale(Locale? locale) {
    setState(() => _locale = locale);
    unawaited(widget.store?.saveLocale(locale?.languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Android reports Norwegian as nb, nn or no depending on the device.
      localeResolutionCallback: _resolveLocale,
      theme: hangmanLightTheme(),
      darkTheme: hangmanDarkTheme(),
      home: HomeScreen(
        selectedLocale: _locale,
        onLocaleSelected: _selectLocale,
        store: widget.store,
      ),
    );
  }

  Locale _resolveLocale(Locale? wanted, Iterable<Locale> supported) {
    const norwegian = ['nb', 'nn', 'no'];
    if (wanted == null) return supported.first;
    if (norwegian.contains(wanted.languageCode)) return const Locale('nb');

    return supported.firstWhere(
      (locale) => locale.languageCode == wanted.languageCode,
      orElse: () => const Locale('en'),
    );
  }
}
