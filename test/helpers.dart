import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/game/game_store.dart';
import 'package:hangman/game/word_repository.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/ui/word_display.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The shell every widget test needs: the localisation delegates, the
/// supported locales and a home. [textScale] drives the large-font tests.
Widget appUnderTest(
  Widget home, {
  ThemeData? theme,
  Locale? locale,
  double textScale = 1,
}) {
  return MaterialApp(
    theme: theme,
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  );
}

/// Always hands out the same word, so the assertions can name letters.
WordRepository fixedWord(String word) =>
    WordRepository(loadAsset: (_) async => word, random: Random(0));

/// A repository whose word list cannot be read, for the failure path.
WordRepository brokenWordList() =>
    WordRepository(loadAsset: (_) async => throw StateError('no word list'));

/// A key on the on-screen keyboard, as opposed to the same letter standing in
/// the word above it.
Finder key(String letter) => find.widgetWithText(InkWell, letter);

/// A letter shown in the word itself.
Finder letterInWord(String letter) =>
    find.descendant(of: find.byType(WordDisplay), matching: find.text(letter));

Future<GameStore> openStore([Map<String, Object> seed = const {}]) async {
  SharedPreferences.setMockInitialValues(seed);
  return GameStore(await SharedPreferences.getInstance());
}
