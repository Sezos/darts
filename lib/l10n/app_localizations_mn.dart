// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Mongolian (`mn`).
class AppLocalizationsMn extends AppLocalizations {
  AppLocalizationsMn([String locale = 'mn']) : super(locale);

  @override
  String get appName => 'Дартсны оноо';

  @override
  String get cancel => 'Болих';

  @override
  String get delete => 'Устгах';

  @override
  String get save => 'Хадгалах';

  @override
  String get close => 'Хаах';

  @override
  String get start => 'Эхлэх';

  @override
  String get history => 'Түүх';

  @override
  String get settings => 'Тохиргоо';

  @override
  String get miss => 'Алдсан';

  @override
  String get missLower => 'алдсан';

  @override
  String get nameLabel => 'Нэр';

  @override
  String get emptyAfterGame => 'Тоглолт дууссаны дараа энд харагдана';

  @override
  String defaultPlayerName(int number) {
    return 'Тоглогч $number';
  }

  @override
  String points(int points) {
    return '$points оноо';
  }

  @override
  String get turnSuffix => ', ээлж';

  @override
  String get homeTitle => 'ДАРТСНЫ ОНОО';

  @override
  String get homeSubtitle => 'Тоглолтын бүртгэл';

  @override
  String get played => 'Тоглосон';

  @override
  String get avgScore => 'Дундаж оноо';

  @override
  String get discardGameTitle => 'Тоглолтыг хаях уу?';

  @override
  String get discardGameMessage => 'Дуусаагүй тоглолтын оноо устана.';

  @override
  String get discard => 'Хаях';

  @override
  String get discardGame => 'Тоглолтыг хаях';

  @override
  String get newGame => 'Шинэ тоглолт';

  @override
  String get continueGame => 'Тоглолт үргэлжлүүлэх';

  @override
  String continueGameSemantics(String type, String players) {
    return 'Тоглолт үргэлжлүүлэх, $type, $players';
  }

  @override
  String get historyEmpty => 'Тоглолт байхгүй';

  @override
  String get deleteGameTitle => 'Тоглолтыг устгах уу?';

  @override
  String get deleteGameMessage =>
      'Энэ тоглолт түүх болон статистикаас бүрмөсөн устна.';

  @override
  String playerStatsSemantics(String name) {
    return '$name: статистик';
  }

  @override
  String get won => 'Ялсан';

  @override
  String lostTo(String winner) {
    return 'Ялагдсан — $winner яллаа';
  }

  @override
  String winnerIs(String winner) {
    return 'Ялагч: $winner';
  }

  @override
  String get statsEmpty => 'Статистик байхгүй';

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тоглолт',
    );
    return '$_temp0';
  }

  @override
  String get wins => 'Ялалт';

  @override
  String get losses => 'Ялагдал';

  @override
  String get winRate => 'Ялалтын %';

  @override
  String get avgPpr => 'Дундаж PPR';

  @override
  String get bestRound => 'Шилдэг раунд';

  @override
  String get totalDarts => 'Нийт дарт';

  @override
  String get opponents => 'Өрсөлдөгчид';

  @override
  String get x01Performance => 'Гүйцэтгэл · x01';

  @override
  String get cricketPerformance => 'Гүйцэтгэл · Cricket';

  @override
  String get avgMpr => 'Дундаж MPR';

  @override
  String get games => 'Тоглолт';

  @override
  String get gameOver => 'Тоглолт дууслаа';

  @override
  String playerWins(String name) {
    return '$name яллаа!';
  }

  @override
  String get finish => 'Дуусгах';

  @override
  String get playAgain => 'Дахин тоглох';

  @override
  String checkoutSemantics(String route) {
    return 'Дуусгах санал: $route';
  }

  @override
  String get exitGame => 'Тоглолтоос гарах';

  @override
  String get undoLastDart => 'Сүүлийн шидэлтийг буцаах';

  @override
  String get nextPlayer => 'Дараагийн тоглогч';

  @override
  String get nextKey => 'ДАРААХ';

  @override
  String scoreCardSemantics(String name, int remaining) {
    return '$name, $remaining оноо үлдсэн';
  }

  @override
  String dartOrdinal(int number) {
    return '$number-р сум';
  }

  @override
  String get dartUpNext => 'дараагийнх';

  @override
  String get dartNotThrown => 'шидээгүй';

  @override
  String cricketPlayerSemantics(String name, int points) {
    return '$name, $points оноо';
  }

  @override
  String get marksNone => 'тэмдэггүй';

  @override
  String get marksClosed => 'хаасан';

  @override
  String marksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тэмдэг',
    );
    return '$_temp0';
  }

  @override
  String get closedByAll => 'бүгд хаасан';

  @override
  String get choosePlayers => 'Тоглогч сонгох';

  @override
  String get gameType => 'Тоглоомын төрөл';

  @override
  String get startScore => 'Эхлэх оноо';

  @override
  String get throwOrder => 'Эрэмбэ';

  @override
  String get random => 'Санамсаргүй';

  @override
  String get selectPlayersHint => 'Тоглогч сонгоно уу';

  @override
  String get allPlayers => 'Бүх тоглогчид';

  @override
  String get addPlayer => 'Тоглогч нэмэх';

  @override
  String get add => 'Нэмэх';

  @override
  String get maxPlayers => 'Нэг тоглолтод 5 хүртэл тоглогч оролцоно';

  @override
  String deletePlayerTitle(String name) {
    return '«$name»-г устгах уу?';
  }

  @override
  String get deletePlayerMessage => 'Түүхэн дэх тоглолтууд хэвээр үлдэнэ.';

  @override
  String get editPlayer => 'Тоглогч засах';

  @override
  String editPlayerSemantics(String name) {
    return '$name-г засах';
  }

  @override
  String deletePlayerSemantics(String name) {
    return '$name-г устгах';
  }

  @override
  String get nameExample => 'Жишээ нь: Бат';

  @override
  String get cricketRules =>
      '15–20 болон Bull тус бүрийг 3 тэмдгээр хаана. Хаасан тоогоо дахин онох бүрт оноо нэмэгдэнэ (өрсөлдөгч хаагаагүй бол). Бүгдийг хааж, оноогоор тэргүүлсэн нь ялна.';

  @override
  String get enterName => 'Нэрээ оруулна уу';

  @override
  String get nameSaved => 'Нэр хадгалагдлаа';

  @override
  String get profile => 'Профайл';

  @override
  String get gameRules => 'Тоглоомын дүрэм';

  @override
  String get doubleOutRequired => 'Double-out шаардлагатай';

  @override
  String get doubleOutHint => 'Дуусгахдаа double цохих ёстой';

  @override
  String get soundAndHaptics => 'Дуу & Мэдрэмж';

  @override
  String get sound => 'Дуу';

  @override
  String get soundHint => 'Цохилтын болон ялалтын дуу';

  @override
  String get vibration => 'Чичиргээ';

  @override
  String get vibrationHint => 'Товч дарах бүрт чичирнэ';

  @override
  String get saveName => 'Нэр хадгалах';

  @override
  String get language => 'Хэл';

  @override
  String get languageAuto => 'Автомат';

  @override
  String get ranks => 'Зэрэглэл';

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
    return 'Зэрэглэл тогтоох $done/$total';
  }

  @override
  String placementHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Зэрэглэл авахад $count тоглолт дутуу',
    );
    return '$_temp0';
  }

  @override
  String ratingAvg(String value) {
    return '$value дундаж';
  }

  @override
  String ratingMpr(String value) {
    return '$value MPR';
  }

  @override
  String get rankUp => 'Зэрэглэл ахилаа!';

  @override
  String get rankPlaced => 'Зэрэглэл авлаа!';

  @override
  String nextRank(String rank) {
    return 'Дараагийнх: $rank';
  }

  @override
  String get topRank => 'Хамгийн дээд зэрэглэл';

  @override
  String get ranksX01Hint =>
      '3 сумны дунджаар тооцно. Сүүлийн тоглолтууд илүү нөлөөтэй.';

  @override
  String get ranksCricketHint =>
      'Раунд тутмын тэмдгээр (MPR) тооцно. Сүүлийн тоглолтууд илүү нөлөөтэй.';

  @override
  String get unranked => 'Зэрэглэлгүй';

  @override
  String get ranksEmpty => 'Зэрэглэл алга';

  @override
  String ranksEmptyHint(int count) {
    return '$count тоглолтын дараа зэрэглэл авна.';
  }

  @override
  String get friends => 'Найзууд';

  @override
  String get yourCode => 'Таны найзын код';

  @override
  String get showQr => 'Миний QR';

  @override
  String get addFriend => 'Найз нэмэх';

  @override
  String get scanQr => 'QR код уншуулах';

  @override
  String get enterCode => 'Код оруулах';

  @override
  String get codeHint => 'Жишээ нь: 7K2-QXP';

  @override
  String get codeInvalid => 'Найзын код буруу байна';

  @override
  String get codeNotFound => 'Ийм кодтой тоглогч алга';

  @override
  String get friendsEmpty => 'Найз алга';

  @override
  String get friendsEmptyHint =>
      'Найздаа QR-ээ үзүүл, эсвэл түүнийхийг уншуул.';

  @override
  String get qrTitle => 'Намайг нэмэхийн тулд уншуул';

  @override
  String get qrHint =>
      'Найзууд чинь утасныхаа камер эсвэл DartScore-оор уншуулна.';

  @override
  String get shareLink => 'Холбоос хуваалцах';

  @override
  String shareText(String link) {
    return 'DartScore дээр намайг нэмээрэй: $link';
  }

  @override
  String get you => 'Та';

  @override
  String get isYou => 'Энэ бол та';

  @override
  String friendAdded(String name) {
    return '$name нэмэгдлээ';
  }

  @override
  String get added => 'Нэмсэн';

  @override
  String get removeFriend => 'Найзаас хасах';

  @override
  String removeFriendTitle(String name) {
    return '$name-г хасах уу?';
  }

  @override
  String get removeFriendMessage =>
      'Та хоёр бие биеийнхээ найзын жагсаалтаас хасагдана.';

  @override
  String get remove => 'Хасах';

  @override
  String get onlineError =>
      'Холбогдож чадсангүй. Интернетээ шалгаад дахин оролдоно уу.';

  @override
  String get retry => 'Дахин оролдох';

  @override
  String get onlineUnavailable => 'Энэ төхөөрөмж дээр найзын хэсэг ажиллахгүй.';

  @override
  String get cameraDenied =>
      'Камерын зөвшөөрөл хаалттай. Уншуулахын тулд Тохиргооноос зөвшөөрнө үү.';

  @override
  String get scanHint => 'Найзынхаа DartScore QR код руу чиглүүл';

  @override
  String get notDartScoreQr => 'Энэ DartScore-ын QR код биш байна';

  @override
  String get friendsLeaderboard => 'Найзуудын зэрэглэл';
}
