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
  String get play => 'Play';

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

  @override
  String get ranks => 'Ranks';

  @override
  String get tierRookie => 'Rookie';

  @override
  String get tierPubThrower => 'Pub Thrower';

  @override
  String get tierOcheRegular => 'Oche Regular';

  @override
  String get tierTrebleHunter => 'Treble Hunter';

  @override
  String get tierCheckoutPro => 'Checkout Pro';

  @override
  String get tierTonMachine => 'Ton Machine';

  @override
  String get tierClub180 => '180 Club';

  @override
  String get tierNineDarter => 'Nine-Darter';

  @override
  String placementProgress(int done, int total) {
    return 'Placement $done/$total';
  }

  @override
  String placementHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more games to get ranked',
      one: '1 more game to get ranked',
    );
    return '$_temp0';
  }

  @override
  String ratingAvg(String value) {
    return '$value avg';
  }

  @override
  String ratingMpr(String value) {
    return '$value MPR';
  }

  @override
  String get rankUp => 'Rank up!';

  @override
  String get rankPlaced => 'Ranked!';

  @override
  String nextRank(String rank) {
    return 'Next: $rank';
  }

  @override
  String get topRank => 'Top rank';

  @override
  String get ranksX01Hint =>
      'Rated on 3-dart average. Recent games count most.';

  @override
  String get ranksCricketHint =>
      'Rated on marks per round. Recent games count most.';

  @override
  String get unranked => 'Unranked';

  @override
  String get ranksEmpty => 'No ranks yet';

  @override
  String ranksEmptyHint(int count) {
    return 'Players get a rank after $count games.';
  }

  @override
  String get friends => 'Friends';

  @override
  String get yourCode => 'Your friend code';

  @override
  String get showQr => 'My QR';

  @override
  String get addFriend => 'Add friend';

  @override
  String get scanQr => 'Scan QR code';

  @override
  String get enterCode => 'Enter code';

  @override
  String get codeHint => 'e.g. 7K2-QXP';

  @override
  String get codeInvalid => 'That doesn\'t look like a friend code';

  @override
  String get codeNotFound => 'No player with that code';

  @override
  String get friendsEmpty => 'No friends yet';

  @override
  String get friendsEmptyHint => 'Show your QR to a friend, or scan theirs.';

  @override
  String get qrTitle => 'Scan to add me';

  @override
  String get qrHint =>
      'Friends scan this with their phone camera or in DartScore.';

  @override
  String get shareLink => 'Share link';

  @override
  String shareText(String link) {
    return 'Add me on DartScore: $link';
  }

  @override
  String get you => 'You';

  @override
  String get isYou => 'This is you';

  @override
  String friendAdded(String name) {
    return '$name added';
  }

  @override
  String get added => 'Added';

  @override
  String get removeFriend => 'Remove friend';

  @override
  String removeFriendTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeFriendMessage =>
      'You\'ll both disappear from each other\'s friends.';

  @override
  String get remove => 'Remove';

  @override
  String get onlineError =>
      'Couldn\'t connect. Check your internet and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get onlineUnavailable => 'Friends aren\'t available on this device.';

  @override
  String get cameraDenied =>
      'Camera access is off. Allow it in Settings to scan.';

  @override
  String get scanHint => 'Point at a friend\'s DartScore QR code';

  @override
  String get notDartScoreQr => 'That isn\'t a DartScore QR code';

  @override
  String get friendsLeaderboard => 'Friends leaderboard';

  @override
  String get saveProgressTitle => 'Save your progress';

  @override
  String get saveProgressHint =>
      'Sign in so your rank, friends and games survive a new phone.';

  @override
  String get signInApple => 'Sign in with Apple';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String signedInWith(String provider) {
    return 'Signed in with $provider';
  }

  @override
  String get signInFailed => 'Couldn\'t sign in. Try again.';

  @override
  String get accountRestored => 'Welcome back! Your games are restored.';

  @override
  String get onlineAccount => 'Online account';

  @override
  String get deleteAccount => 'Delete online account';

  @override
  String get deleteAccountHint => 'Removes your profile, friends and backups';

  @override
  String get deleteAccountTitle => 'Delete your online account?';

  @override
  String get deleteAccountMessage =>
      'Your profile, friends and backed-up games are removed for good. Games on this phone stay.';

  @override
  String get accountDeleted => 'Online account deleted';
}
