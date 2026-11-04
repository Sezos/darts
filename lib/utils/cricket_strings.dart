import 'package:darts/core/game/engine.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/l10n/l10n.dart';

/// Cricket labels that are the same in every language. Darts jargon (x01,
/// Cricket, Bull, MPR) stays in English; translated text lives in the ARB
/// files under lib/l10n.
abstract final class CricketText {
  // ── Mode names ───────────────────────────────────────────────────────────
  static const x01 = 'x01';
  static const cricket = 'Cricket';
  static const x01Detail = '101 · 301 · 501 · 701';
  static const cricketDetail = '15–20 · Bull';

  // ── Scoreboard ───────────────────────────────────────────────────────────
  static const bull = 'Bull';
  static const doubleBull = 'D-Bull';
  static String mpr(String value) => 'MPR $value';
  static String targetLabel(int target) => target == 25 ? bull : '$target';

  /// Screen-reader text for one player's marks on one number.
  static String marksSemantics(
    AppLocalizations l10n,
    String name,
    int target,
    int marks,
  ) =>
      '$name, ${targetLabel(target)}: ${switch (marks) {
        0 => l10n.marksNone,
        >= 3 => l10n.marksClosed,
        _ => l10n.marksCount(marks),
      }}';

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
}

extension GameTypeLabel on Game {
  /// "501" for x01 games, "Cricket" for Cricket.
  String get typeLabel => isCricket ? CricketText.cricket : '$startFrom';
}
