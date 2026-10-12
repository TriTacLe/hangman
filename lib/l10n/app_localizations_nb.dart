// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Hangman';

  @override
  String get homeTagline => 'Gjett ordet, én bokstav om gangen.';

  @override
  String get playButton => 'Spill';

  @override
  String get infoButton => 'Slik spiller du';

  @override
  String get languageLabel => 'Språk';

  @override
  String get languageSystem => 'Språket på enheten';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageNorwegian => 'Norsk';

  @override
  String get alphabet => 'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅ';

  @override
  String get infoTitle => 'Slik spiller du';

  @override
  String get infoRules =>
      'Spillet velger et ord og skjuler alle bokstavene. Trykk på en bokstav for å gjette. En bokstav som finnes i ordet, vises alle stedene den står, og en bokstav som ikke finnes, koster deg ett forsøk.\n\nDu har seks bom. Tegningen får én del til for hver av dem, og spillet er slutt når den er ferdig. Gjetter du alle bokstavene før det, har du vunnet.\n\nOrdet hentes fra lista for språket appen kjører på, så den norske lista bruker det norske alfabetet.';

  @override
  String remainingGuesses(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString bom igjen',
      one: '1 bom igjen',
      zero: 'Ingen forsøk igjen',
    );
    return '$_temp0';
  }

  @override
  String get wonTitle => 'Du vant';

  @override
  String wonMessage(String word, num wrong) {
    final intl.NumberFormat wrongNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String wrongString = wrongNumberFormat.format(wrong);

    String _temp0 = intl.Intl.pluralLogic(
      wrong,
      locale: localeName,
      other: '$wrongString bom',
      one: 'én bom',
      zero: 'ingen bom',
    );
    return 'Du gjettet $word med $_temp0.';
  }

  @override
  String get lostTitle => 'Du tapte';

  @override
  String lostMessage(String word) {
    return 'Ordet var $word.';
  }

  @override
  String get playAgainButton => 'Spill igjen';

  @override
  String get backToStartButton => 'Tilbake til start';

  @override
  String guessLetterHint(String letter) {
    return 'Gjett bokstaven $letter';
  }
}
