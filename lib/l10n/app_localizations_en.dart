// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hangman';

  @override
  String get homeTagline => 'Guess the word one letter at a time.';

  @override
  String get playButton => 'Play';

  @override
  String get continueButton => 'Continue game';

  @override
  String get infoButton => 'How to play';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageNorwegian => 'Norsk';

  @override
  String get alphabet => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  String get infoTitle => 'How to play';

  @override
  String get infoRules =>
      'The game picks a word and hides every letter. Tap a letter to guess it. A letter that is in the word is revealed everywhere it appears, and a letter that is not costs you one attempt.\n\nYou have six wrong guesses. The drawing gains one more part for each of them, and the game is over when it is finished. Guess every letter before that and you win.\n\nThe word comes from the list for the language the app is running in, so the Norwegian list uses the Norwegian alphabet.\n\nIf you leave in the middle of a round, it is kept and you can pick it up from the start screen.';

  @override
  String remainingGuesses(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString wrong guesses left',
      one: '1 wrong guess left',
      zero: 'No guesses left',
    );
    return '$_temp0';
  }

  @override
  String get wonTitle => 'You won';

  @override
  String wonMessage(String word, num wrong) {
    final intl.NumberFormat wrongNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String wrongString = wrongNumberFormat.format(wrong);

    String _temp0 = intl.Intl.pluralLogic(
      wrong,
      locale: localeName,
      other: '$wrongString wrong guesses',
      one: 'one wrong guess',
      zero: 'no wrong guesses',
    );
    return 'You guessed $word with $_temp0.';
  }

  @override
  String get lostTitle => 'You lost';

  @override
  String lostMessage(String word) {
    return 'The word was $word.';
  }

  @override
  String get playAgainButton => 'Play again';

  @override
  String get backToStartButton => 'Back to start';

  @override
  String guessLetterHint(String letter) {
    return 'Guess the letter $letter';
  }
}
