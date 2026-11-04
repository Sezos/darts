// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DartScore';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get start => 'Start';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get miss => 'Miss';

  @override
  String get missLower => 'miss';

  @override
  String get nameLabel => 'Name';

  @override
  String get emptyAfterGame => 'Shows up here once a game ends';

  @override
  String defaultPlayerName(int number) {
    return 'Player $number';
  }

  @override
  String points(int points) {
    return '$points pts';
  }

  @override
  String get turnSuffix => ', throwing';

  @override
  String get homeTitle => 'DARTSCORE';

  @override
  String get homeSubtitle => 'Score tracker';

  @override
  String get played => 'Played';

  @override
  String get avgScore => 'Avg score';

  @override
  String get discardGameTitle => 'Discard this game?';

  @override
  String get discardGameMessage =>
      'Scores from the unfinished game will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get discardGame => 'Discard game';

  @override
  String get newGame => 'New game';

  @override
  String get continueGame => 'Continue game';

  @override
  String continueGameSemantics(String type, String players) {
    return 'Continue game, $type, $players';
  }

  @override
  String get historyEmpty => 'No games yet';

  @override
  String get deleteGameTitle => 'Delete this game?';

  @override
  String get deleteGameMessage =>
      'This game will be removed from history and stats for good.';

  @override
  String playerStatsSemantics(String name) {
    return '$name: stats';
  }

  @override
  String get won => 'Won';

  @override
  String lostTo(String winner) {
    return 'Lost — $winner won';
  }

  @override
  String winnerIs(String winner) {
    return 'Winner: $winner';
  }

  @override
  String get statsEmpty => 'No stats yet';

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
    );
    return '$_temp0';
  }

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get winRate => 'Win %';

  @override
  String get avgPpr => 'Avg PPR';

  @override
  String get bestRound => 'Best round';

  @override
  String get totalDarts => 'Total darts';

  @override
  String get opponents => 'Opponents';

  @override
  String get x01Performance => 'Performance · x01';

  @override
  String get cricketPerformance => 'Performance · Cricket';

  @override
  String get avgMpr => 'Avg MPR';

  @override
  String get games => 'Games';

  @override
  String get gameOver => 'Game over';

  @override
  String playerWins(String name) {
    return '$name wins!';
  }

  @override
  String get finish => 'Finish';

  @override
  String get playAgain => 'Play again';

  @override
  String checkoutSemantics(String route) {
    return 'Checkout: $route';
  }

  @override
  String get exitGame => 'Exit game';

  @override
  String get undoLastDart => 'Undo last dart';

  @override
  String get nextPlayer => 'Next player';

  @override
  String get nextKey => 'NEXT';

  @override
  String scoreCardSemantics(String name, int remaining) {
    return '$name, $remaining left';
  }

  @override
  String dartOrdinal(int number) {
    return 'Dart $number';
  }

  @override
  String get dartUpNext => 'up next';

  @override
  String get dartNotThrown => 'not thrown';

  @override
  String cricketPlayerSemantics(String name, int points) {
    return '$name, $points points';
  }

  @override
  String get marksNone => 'no marks';

  @override
  String get marksClosed => 'closed';

  @override
  String marksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marks',
      one: '1 mark',
    );
    return '$_temp0';
  }

  @override
  String get closedByAll => 'closed by all';

  @override
  String get choosePlayers => 'Choose players';

  @override
  String get gameType => 'Game type';

  @override
  String get startScore => 'Starting score';

  @override
  String get throwOrder => 'Throw order';

  @override
  String get random => 'Random';

  @override
  String get selectPlayersHint => 'Pick players below';

  @override
  String get allPlayers => 'All players';

  @override
  String get addPlayer => 'Add player';

  @override
  String get add => 'Add';

  @override
  String get maxPlayers => 'Up to 5 players per game';

  @override
  String deletePlayerTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get deletePlayerMessage => 'Their past games stay in history.';

  @override
  String get editPlayer => 'Edit player';

  @override
  String editPlayerSemantics(String name) {
    return 'Edit $name';
  }

  @override
  String deletePlayerSemantics(String name) {
    return 'Delete $name';
  }

  @override
  String get nameExample => 'e.g. Alex';

  @override
  String get cricketRules =>
      'Close 15–20 and Bull with 3 marks each. Hitting a number you\'ve closed scores points, unless your opponents have closed it too. Close everything with the most points to win.';

  @override
  String get enterName => 'Enter your name';

  @override
  String get nameSaved => 'Name saved';

  @override
  String get profile => 'Profile';

  @override
  String get gameRules => 'Game rules';

  @override
  String get doubleOutRequired => 'Double-out required';

  @override
  String get doubleOutHint => 'You must finish on a double';

  @override
  String get soundAndHaptics => 'Sound & haptics';

  @override
  String get sound => 'Sound';

  @override
  String get soundHint => 'Hit and win sounds';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationHint => 'Vibrate on every tap';

  @override
  String get saveName => 'Save name';

  @override
  String get language => 'Language';

  @override
  String get languageAuto => 'Auto';
}
