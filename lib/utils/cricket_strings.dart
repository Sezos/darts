import 'package:darts/core/game/engine.dart';
import 'package:darts/core/providers/game/game.provider.dart';

/// UI text added with the Cricket mode, kept together so the English pass
/// can lift it out in one place. Darts jargon (x01, Cricket, Bull, MPR)
/// stays in English, as elsewhere in the app.
abstract final class CricketText {
  // ── Mode names ───────────────────────────────────────────────────────────
  static const x01 = 'x01';
  static const cricket = 'Cricket';
  static const x01Detail = '101 · 301 · 501 · 701';
  static const cricketDetail = '15–20 · Bull';

  // ── New-game flow ────────────────────────────────────────────────────────
  static const startScore = 'Эхлэх оноо';
  static const rules =
      '15–20 болон Bull тус бүрийг 3 тэмдгээр хаана. Хаасан тоогоо дахин '
      'онох бүрт оноо нэмэгдэнэ (өрсөлдөгч хаагаагүй бол). Бүгдийг хааж, '
      'оноогоор тэргүүлсэн нь ялна.';

  // ── Scoreboard ───────────────────────────────────────────────────────────
  static const bull = 'Bull';
  static const doubleBull = 'D-Bull';
  static String mpr(String value) => 'MPR $value';
  static String points(int points) => '$points оноо';
  static String targetLabel(int target) => target == 25 ? bull : '$target';

  /// Screen-reader text for one player's header.
  static String playerSemantics(
    String name,
    int points, {
    required bool turn,
  }) => '$name, $points оноо${turn ? ', ээлж' : ''}';

  /// Screen-reader text for one player's marks on one number.
  static String marksSemantics(String name, int target, int marks) =>
      '$name, ${targetLabel(target)}: ${switch (marks) {
        0 => 'тэмдэггүй',
        >= 3 => 'хаасан',
        _ => '$marks тэмдэг',
      }}';

  /// Screen-reader text for a number every player has closed.
  static String deadSemantics(int target) =>
      '${targetLabel(target)}, бүгд хаасан';

  /// A thrown dart as shown in the throw strip: "T20", "D19", "15", "Bull".
  static String dartLabel(int number, int? mult) => switch ((number, mult)) {
    (25, 2) => doubleBull,
    (25, _) => bull,
    (_, 3) => 'T$number',
    (_, 2) => 'D$number',
    _ => '$number',
  };

  static String bullKeyLabel(DartType type) =>
      type == DartType.d ? doubleBull : bull;

  // ── Stats ────────────────────────────────────────────────────────────────
  static const x01Performance = 'Гүйцэтгэл · x01';
  static const cricketPerformance = 'Гүйцэтгэл · Cricket';
  static const avgMpr = 'Дундаж MPR';
  static const bestMarks = 'Шилдэг раунд';
  static const games = 'Тоглолт';
}

extension GameTypeLabel on Game {
  /// "501" for x01 games, "Cricket" for Cricket.
  String get typeLabel => isCricket ? CricketText.cricket : '$startFrom';
}
