import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mn.dart';

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
    Locale('mn'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DartScore'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @miss.
  ///
  /// In en, this message translates to:
  /// **'Miss'**
  String get miss;

  /// No description provided for @missLower.
  ///
  /// In en, this message translates to:
  /// **'miss'**
  String get missLower;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @emptyAfterGame.
  ///
  /// In en, this message translates to:
  /// **'Shows up here once a game ends'**
  String get emptyAfterGame;

  /// No description provided for @defaultPlayerName.
  ///
  /// In en, this message translates to:
  /// **'Player {number}'**
  String defaultPlayerName(int number);

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String points(int points);

  /// No description provided for @turnSuffix.
  ///
  /// In en, this message translates to:
  /// **', throwing'**
  String get turnSuffix;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'DARTSCORE'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Score tracker'**
  String get homeSubtitle;

  /// No description provided for @played.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get played;

  /// No description provided for @avgScore.
  ///
  /// In en, this message translates to:
  /// **'Avg score'**
  String get avgScore;

  /// No description provided for @discardGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this game?'**
  String get discardGameTitle;

  /// No description provided for @discardGameMessage.
  ///
  /// In en, this message translates to:
  /// **'Scores from the unfinished game will be lost.'**
  String get discardGameMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @discardGame.
  ///
  /// In en, this message translates to:
  /// **'Discard game'**
  String get discardGame;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGame;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue game'**
  String get continueGame;

  /// No description provided for @continueGameSemantics.
  ///
  /// In en, this message translates to:
  /// **'Continue game, {type}, {players}'**
  String continueGameSemantics(String type, String players);

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No games yet'**
  String get historyEmpty;

  /// No description provided for @deleteGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this game?'**
  String get deleteGameTitle;

  /// No description provided for @deleteGameMessage.
  ///
  /// In en, this message translates to:
  /// **'This game will be removed from history and stats for good.'**
  String get deleteGameMessage;

  /// No description provided for @playerStatsSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}: stats'**
  String playerStatsSemantics(String name);

  /// No description provided for @won.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get won;

  /// No description provided for @lostTo.
  ///
  /// In en, this message translates to:
  /// **'Lost — {winner} won'**
  String lostTo(String winner);

  /// No description provided for @winnerIs.
  ///
  /// In en, this message translates to:
  /// **'Winner: {winner}'**
  String winnerIs(String winner);

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stats yet'**
  String get statsEmpty;

  /// No description provided for @gamesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 game} other{{count} games}}'**
  String gamesCount(int count);

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win %'**
  String get winRate;

  /// No description provided for @avgPpr.
  ///
  /// In en, this message translates to:
  /// **'Avg PPR'**
  String get avgPpr;

  /// No description provided for @bestRound.
  ///
  /// In en, this message translates to:
  /// **'Best round'**
  String get bestRound;

  /// No description provided for @totalDarts.
  ///
  /// In en, this message translates to:
  /// **'Total darts'**
  String get totalDarts;

  /// No description provided for @opponents.
  ///
  /// In en, this message translates to:
  /// **'Opponents'**
  String get opponents;

  /// No description provided for @x01Performance.
  ///
  /// In en, this message translates to:
  /// **'Performance · x01'**
  String get x01Performance;

  /// No description provided for @cricketPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance · Cricket'**
  String get cricketPerformance;

  /// No description provided for @avgMpr.
  ///
  /// In en, this message translates to:
  /// **'Avg MPR'**
  String get avgMpr;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game over'**
  String get gameOver;

  /// No description provided for @playerWins.
  ///
  /// In en, this message translates to:
  /// **'{name} wins!'**
  String playerWins(String name);

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @checkoutSemantics.
  ///
  /// In en, this message translates to:
  /// **'Checkout: {route}'**
  String checkoutSemantics(String route);

  /// No description provided for @exitGame.
  ///
  /// In en, this message translates to:
  /// **'Exit game'**
  String get exitGame;

  /// No description provided for @undoLastDart.
  ///
  /// In en, this message translates to:
  /// **'Undo last dart'**
  String get undoLastDart;

  /// No description provided for @nextPlayer.
  ///
  /// In en, this message translates to:
  /// **'Next player'**
  String get nextPlayer;

  /// No description provided for @nextKey.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get nextKey;

  /// No description provided for @scoreCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {remaining} left'**
  String scoreCardSemantics(String name, int remaining);

  /// No description provided for @dartOrdinal.
  ///
  /// In en, this message translates to:
  /// **'Dart {number}'**
  String dartOrdinal(int number);

  /// No description provided for @dartUpNext.
  ///
  /// In en, this message translates to:
  /// **'up next'**
  String get dartUpNext;

  /// No description provided for @dartNotThrown.
  ///
  /// In en, this message translates to:
  /// **'not thrown'**
  String get dartNotThrown;

  /// No description provided for @cricketPlayerSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {points} points'**
  String cricketPlayerSemantics(String name, int points);

  /// No description provided for @marksNone.
  ///
  /// In en, this message translates to:
  /// **'no marks'**
  String get marksNone;

  /// No description provided for @marksClosed.
  ///
  /// In en, this message translates to:
  /// **'closed'**
  String get marksClosed;

  /// No description provided for @marksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mark} other{{count} marks}}'**
  String marksCount(int count);

  /// No description provided for @closedByAll.
  ///
  /// In en, this message translates to:
  /// **'closed by all'**
  String get closedByAll;

  /// No description provided for @choosePlayers.
  ///
  /// In en, this message translates to:
  /// **'Choose players'**
  String get choosePlayers;

  /// No description provided for @gameType.
  ///
  /// In en, this message translates to:
  /// **'Game type'**
  String get gameType;

  /// No description provided for @startScore.
  ///
  /// In en, this message translates to:
  /// **'Starting score'**
  String get startScore;

  /// No description provided for @throwOrder.
  ///
  /// In en, this message translates to:
  /// **'Throw order'**
  String get throwOrder;

  /// No description provided for @random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// No description provided for @selectPlayersHint.
  ///
  /// In en, this message translates to:
  /// **'Pick players below'**
  String get selectPlayersHint;

  /// No description provided for @allPlayers.
  ///
  /// In en, this message translates to:
  /// **'All players'**
  String get allPlayers;

  /// No description provided for @addPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add player'**
  String get addPlayer;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @maxPlayers.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 players per game'**
  String get maxPlayers;

  /// No description provided for @deletePlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deletePlayerTitle(String name);

  /// No description provided for @deletePlayerMessage.
  ///
  /// In en, this message translates to:
  /// **'Their past games stay in history.'**
  String get deletePlayerMessage;

  /// No description provided for @editPlayer.
  ///
  /// In en, this message translates to:
  /// **'Edit player'**
  String get editPlayer;

  /// No description provided for @editPlayerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editPlayerSemantics(String name);

  /// No description provided for @deletePlayerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deletePlayerSemantics(String name);

  /// No description provided for @nameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Alex'**
  String get nameExample;

  /// No description provided for @cricketRules.
  ///
  /// In en, this message translates to:
  /// **'Close 15–20 and Bull with 3 marks each. Hitting a number you\'ve closed scores points, unless your opponents have closed it too. Close everything with the most points to win.'**
  String get cricketRules;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @nameSaved.
  ///
  /// In en, this message translates to:
  /// **'Name saved'**
  String get nameSaved;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @gameRules.
  ///
  /// In en, this message translates to:
  /// **'Game rules'**
  String get gameRules;

  /// No description provided for @doubleOutRequired.
  ///
  /// In en, this message translates to:
  /// **'Double-out required'**
  String get doubleOutRequired;

  /// No description provided for @doubleOutHint.
  ///
  /// In en, this message translates to:
  /// **'You must finish on a double'**
  String get doubleOutHint;

  /// No description provided for @soundAndHaptics.
  ///
  /// In en, this message translates to:
  /// **'Sound & haptics'**
  String get soundAndHaptics;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundHint.
  ///
  /// In en, this message translates to:
  /// **'Hit and win sounds'**
  String get soundHint;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationHint.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on every tap'**
  String get vibrationHint;

  /// No description provided for @saveName.
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get saveName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get languageAuto;
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
      <String>['en', 'mn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'mn':
      return AppLocalizationsMn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
