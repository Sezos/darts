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

  /// No description provided for @ranks.
  ///
  /// In en, this message translates to:
  /// **'Ranks'**
  String get ranks;

  /// No description provided for @tierRookie.
  ///
  /// In en, this message translates to:
  /// **'Rookie'**
  String get tierRookie;

  /// No description provided for @tierPubThrower.
  ///
  /// In en, this message translates to:
  /// **'Pub Thrower'**
  String get tierPubThrower;

  /// No description provided for @tierOcheRegular.
  ///
  /// In en, this message translates to:
  /// **'Oche Regular'**
  String get tierOcheRegular;

  /// No description provided for @tierTrebleHunter.
  ///
  /// In en, this message translates to:
  /// **'Treble Hunter'**
  String get tierTrebleHunter;

  /// No description provided for @tierCheckoutPro.
  ///
  /// In en, this message translates to:
  /// **'Checkout Pro'**
  String get tierCheckoutPro;

  /// No description provided for @tierTonMachine.
  ///
  /// In en, this message translates to:
  /// **'Ton Machine'**
  String get tierTonMachine;

  /// No description provided for @tierClub180.
  ///
  /// In en, this message translates to:
  /// **'180 Club'**
  String get tierClub180;

  /// No description provided for @tierNineDarter.
  ///
  /// In en, this message translates to:
  /// **'Nine-Darter'**
  String get tierNineDarter;

  /// No description provided for @placementProgress.
  ///
  /// In en, this message translates to:
  /// **'Placement {done}/{total}'**
  String placementProgress(int done, int total);

  /// No description provided for @placementHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more game to get ranked} other{{count} more games to get ranked}}'**
  String placementHint(int count);

  /// No description provided for @ratingAvg.
  ///
  /// In en, this message translates to:
  /// **'{value} avg'**
  String ratingAvg(String value);

  /// No description provided for @ratingMpr.
  ///
  /// In en, this message translates to:
  /// **'{value} MPR'**
  String ratingMpr(String value);

  /// No description provided for @rankUp.
  ///
  /// In en, this message translates to:
  /// **'Rank up!'**
  String get rankUp;

  /// No description provided for @rankPlaced.
  ///
  /// In en, this message translates to:
  /// **'Ranked!'**
  String get rankPlaced;

  /// No description provided for @nextRank.
  ///
  /// In en, this message translates to:
  /// **'Next: {rank}'**
  String nextRank(String rank);

  /// No description provided for @topRank.
  ///
  /// In en, this message translates to:
  /// **'Top rank'**
  String get topRank;

  /// No description provided for @ranksX01Hint.
  ///
  /// In en, this message translates to:
  /// **'Rated on 3-dart average. Recent games count most.'**
  String get ranksX01Hint;

  /// No description provided for @ranksCricketHint.
  ///
  /// In en, this message translates to:
  /// **'Rated on marks per round. Recent games count most.'**
  String get ranksCricketHint;

  /// No description provided for @unranked.
  ///
  /// In en, this message translates to:
  /// **'Unranked'**
  String get unranked;

  /// No description provided for @ranksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No ranks yet'**
  String get ranksEmpty;

  /// No description provided for @ranksEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Players get a rank after {count} games.'**
  String ranksEmptyHint(int count);

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @yourCode.
  ///
  /// In en, this message translates to:
  /// **'Your friend code'**
  String get yourCode;

  /// No description provided for @showQr.
  ///
  /// In en, this message translates to:
  /// **'My QR'**
  String get showQr;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get addFriend;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQr;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterCode;

  /// No description provided for @codeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 7K2-QXP'**
  String get codeHint;

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a friend code'**
  String get codeInvalid;

  /// No description provided for @codeNotFound.
  ///
  /// In en, this message translates to:
  /// **'No player with that code'**
  String get codeNotFound;

  /// No description provided for @friendsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get friendsEmpty;

  /// No description provided for @friendsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Show your QR to a friend, or scan theirs.'**
  String get friendsEmptyHint;

  /// No description provided for @qrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to add me'**
  String get qrTitle;

  /// No description provided for @qrHint.
  ///
  /// In en, this message translates to:
  /// **'Friends scan this with their phone camera or in DartScore.'**
  String get qrHint;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get shareLink;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Add me on DartScore: {link}'**
  String shareText(String link);

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @isYou.
  ///
  /// In en, this message translates to:
  /// **'This is you'**
  String get isYou;

  /// No description provided for @friendAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String friendAdded(String name);

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get removeFriend;

  /// No description provided for @removeFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeFriendTitle(String name);

  /// No description provided for @removeFriendMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll both disappear from each other\'s friends.'**
  String get removeFriendMessage;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @onlineError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect. Check your internet and try again.'**
  String get onlineError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @onlineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Friends aren\'t available on this device.'**
  String get onlineUnavailable;

  /// No description provided for @cameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off. Allow it in Settings to scan.'**
  String get cameraDenied;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point at a friend\'s DartScore QR code'**
  String get scanHint;

  /// No description provided for @notDartScoreQr.
  ///
  /// In en, this message translates to:
  /// **'That isn\'t a DartScore QR code'**
  String get notDartScoreQr;

  /// No description provided for @friendsLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Friends leaderboard'**
  String get friendsLeaderboard;

  /// No description provided for @saveProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your progress'**
  String get saveProgressTitle;

  /// No description provided for @saveProgressHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in so your rank, friends and games survive a new phone.'**
  String get saveProgressHint;

  /// No description provided for @signInApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInApple;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogle;

  /// No description provided for @signedInWith.
  ///
  /// In en, this message translates to:
  /// **'Signed in with {provider}'**
  String signedInWith(String provider);

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in. Try again.'**
  String get signInFailed;

  /// No description provided for @accountRestored.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Your games are restored.'**
  String get accountRestored;

  /// No description provided for @onlineAccount.
  ///
  /// In en, this message translates to:
  /// **'Online account'**
  String get onlineAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete online account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Removes your profile, friends and backups'**
  String get deleteAccountHint;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your online account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Your profile, friends and backed-up games are removed for good. Games on this phone stay.'**
  String get deleteAccountMessage;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Online account deleted'**
  String get accountDeleted;
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
