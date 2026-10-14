import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nb.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nb'),
  ];

  /// Name of the app, shown on the start screen and in the app bar
  ///
  /// In en, this message translates to:
  /// **'Hangman'**
  String get appTitle;

  /// Starts a new game
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playButton;

  /// Resumes the round that was left unfinished
  ///
  /// In en, this message translates to:
  /// **'Continue game'**
  String get continueButton;

  /// Opens the info page, from the start screen and from a running game
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get infoButton;

  /// Language option, written in the language it selects
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option, written in the language it selects
  ///
  /// In en, this message translates to:
  /// **'Norsk'**
  String get languageNorwegian;

  /// Title of the info page
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get infoTitle;

  /// The rules, shown on the info page
  ///
  /// In en, this message translates to:
  /// **'The game picks a word and hides every letter. Tap a letter to guess it. A letter that is in the word is revealed everywhere it appears, and a letter that is not costs you one attempt.\n\nYou have six wrong guesses. The drawing gains one more part for each of them, and the game is over when it is finished. Guess every letter before that and you win.\n\nThe word comes from the list for the language the app is running in, so the Norwegian list uses the Norwegian alphabet.\n\nIf you leave in the middle of a round, it is kept and you can pick it up from the start screen.'**
  String get infoRules;

  /// How many wrong guesses the player has left
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No guesses left} =1{1 wrong guess left} other{{count} wrong guesses left}}'**
  String remainingGuesses(num count);

  /// Shown when every letter has been guessed
  ///
  /// In en, this message translates to:
  /// **'You won'**
  String get wonTitle;

  /// Result line after a win
  ///
  /// In en, this message translates to:
  /// **'You guessed {word} with {wrong, plural, =0{no wrong guesses} =1{one wrong guess} other{{wrong} wrong guesses}}.'**
  String wonMessage(String word, num wrong);

  /// Shown when the wrong guesses run out
  ///
  /// In en, this message translates to:
  /// **'You lost'**
  String get lostTitle;

  /// Result line after a loss
  ///
  /// In en, this message translates to:
  /// **'The word was {word}.'**
  String lostMessage(String word);

  /// Starts another game with a new word
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgainButton;

  /// Leaves the game and returns to the start screen
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get backToStartButton;

  /// Screen reader label on a keyboard key
  ///
  /// In en, this message translates to:
  /// **'Guess the letter {letter}'**
  String guessLetterHint(String letter);

  /// Screen reader label while the word list is being read
  ///
  /// In en, this message translates to:
  /// **'Picking a word'**
  String get loadingWord;

  /// Shown when the word list is missing or empty
  ///
  /// In en, this message translates to:
  /// **'The word list could not be read.'**
  String get loadFailedTitle;

  /// Reads the word list again after it failed
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryButton;

  /// How a screen reader reads a letter that is still hidden
  ///
  /// In en, this message translates to:
  /// **'blank'**
  String get blankLetter;

  /// Screen reader summary of how much of the word is left
  ///
  /// In en, this message translates to:
  /// **'{hidden, plural, =0{Every letter revealed} =1{One letter still hidden} other{{hidden} letters still hidden}}'**
  String wordProgress(num hidden);

  /// Asked when a new game would drop the round in progress
  ///
  /// In en, this message translates to:
  /// **'Start a new game?'**
  String get newGameTitle;

  /// Explains what starting a new game costs
  ///
  /// In en, this message translates to:
  /// **'The round you left unfinished will be dropped.'**
  String get newGameMessage;

  /// Confirms dropping the saved round
  ///
  /// In en, this message translates to:
  /// **'Start new'**
  String get newGameConfirm;

  /// Dismisses the rules dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// Dismisses a dialog without doing anything
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nb'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nb':
      return AppLocalizationsNb();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
