import 'dart:math' as math;

import 'package:darts/core/game/cricket_engine.dart';
import 'package:darts/core/providers/game/game.provider.dart';

/// Skill ratings, graded the way darts leagues grade players: on how someone
/// throws, not on who they beat. x01 is rated by 3-dart average, Cricket by
/// marks per round (MPR). Wins and losses don't count; the stats screen's
/// head-to-head records cover those.
enum RatingMode {
  x01,
  cricket;

  static RatingMode of(Game game) => game.isCricket ? cricket : x01;
}

/// The eight tiers, lowest first. Each splits into divisions I, II and III.
enum Tier {
  rookie,
  pubThrower,
  ocheRegular,
  trebleHunter,
  checkoutPro,
  tonMachine,
  club180,
  nineDarter,
}

/// Where a rating sits: a [tier], a [division] from 1 (I) to 3 (III), and
/// how far through that division it is, 0–1.
class Rank {
  const Rank(this.tier, this.division, this.progress);
  final Tier tier;
  final int division;
  final double progress;

  /// 0 for Rookie I up to 23 for Nine-Darter III.
  int get step => tier.index * 3 + division - 1;

  bool isAbove(Rank other) => step > other.step;

  @override
  bool operator ==(Object other) =>
      other is Rank && other.tier == tier && other.division == division;

  @override
  int get hashCode => Object.hash(tier, division);

  @override
  String toString() => '${tier.name} $division';
}

/// Lower bound of each [Tier], in the mode's unit. The top tier is as wide as
/// the one below it; anything beyond counts as its top division.
const _x01Floors = [0.0, 20, 30, 40, 50, 60, 70, 80];
const _cricketFloors = [0.0, 0.8, 1.2, 1.6, 2.0, 2.5, 3.0, 3.5];

Rank rankFor(RatingMode mode, double rating) {
  final floors = mode == RatingMode.x01 ? _x01Floors : _cricketFloors;
  // Weighted averages land a hair off round numbers; 2.9999… is 3.0.
  final value = rating + 1e-9;
  final t = math.max(0, floors.lastIndexWhere((f) => value >= f));
  final lo = floors[t];
  final hi = t + 1 < floors.length
      ? floors[t + 1]
      : lo + (floors[t] - floors[t - 1]);
  if (value >= hi) return Rank(Tier.values[t], 3, 1);
  final within = (value - lo) / (hi - lo) * 3;
  return Rank(Tier.values[t], within.floor() + 1, within - within.floor());
}

/// Games a player needs in a mode before they get a rank.
const placementGames = 5;

/// Only the most recent games count, newest weighted most, so a rating
/// follows current form and one lucky game can't swing it.
const _window = 20;
const _decay = 0.85;

/// A player's rating in one mode, worked out from their saved games.
class SkillRating {
  const SkillRating({
    required this.mode,
    required this.games,
    this.value,
    this.previous,
    this.latest,
  });

  final RatingMode mode;

  /// Finished games in this mode the player threw in.
  final int games;

  /// 3-dart average (x01) or MPR (Cricket); null until [placementGames].
  final double? value;

  /// [value] before the player's latest game; null if that game was still
  /// part of placement.
  final double? previous;

  /// The player's latest game that counted. A game where they never threw
  /// (someone checked out first) doesn't count.
  final Game? latest;

  /// [game] moved this rating, so [change] and [rankedUp] are about it.
  bool countedIn(Game game) => identical(latest, game);

  bool get isPlacement => value == null;
  Rank? get rank => value == null ? null : rankFor(mode, value!);
  Rank? get previousRank => previous == null ? null : rankFor(mode, previous!);
  double? get change =>
      value == null || previous == null ? null : value! - previous!;

  /// The latest game finished placement and gave the player a rank.
  bool get justPlaced => value != null && previous == null;

  /// The latest game moved the player up at least one division.
  bool get rankedUp =>
      rank != null && previousRank != null && rank!.isAbove(previousRank!);
}

SkillRating skillRating(List<Game> history, int userId, RatingMode mode) {
  final counted = [
    for (final g in history)
      if (RatingMode.of(g) == mode)
        if (_sample(g, userId) case final s?) (game: g, sample: s),
  ];
  final samples = [for (final c in counted) c.sample];
  return SkillRating(
    mode: mode,
    games: samples.length,
    value: samples.length >= placementGames ? _weighted(samples) : null,
    previous: samples.length > placementGames
        ? _weighted(samples.sublist(0, samples.length - 1))
        : null,
    latest: counted.lastOrNull?.game,
  );
}

/// One player's showing in one game, and how many darts it's based on.
typedef _Sample = ({double value, double weight});

_Sample? _sample(Game game, int userId) =>
    game.isCricket ? _cricketSample(game, userId) : _x01Sample(game, userId);

_Sample? _x01Sample(Game game, int userId) {
  final checkout = game.rounds.isEmpty ? null : game.rounds.last;
  var points = 0;
  var darts = 0;
  for (final r in game.rounds) {
    if (r.user.id != userId) continue;
    points += r.total;
    // A visit costs 3 darts even when it went bust or ended early; only the
    // checkout visit can be shorter.
    darts += identical(r, checkout) ? r.dartsThrown : 3;
  }
  if (darts == 0) return null;
  return (value: points / darts * 3, weight: darts.toDouble());
}

_Sample? _cricketSample(Game game, int userId) {
  var marks = 0;
  var rounds = 0;
  for (final (id, m) in CricketEngine.countedMarksPerRound(game)) {
    if (id != userId) continue;
    marks += m;
    rounds++;
  }
  if (rounds == 0) return null;
  return (value: marks / rounds, weight: rounds * 3.0);
}

double _weighted(List<_Sample> samples) {
  final recent = samples.length > _window
      ? samples.sublist(samples.length - _window)
      : samples;
  var sum = 0.0;
  var total = 0.0;
  for (var i = 0; i < recent.length; i++) {
    final w = recent[i].weight * math.pow(_decay, recent.length - 1 - i);
    sum += w * recent[i].value;
    total += w;
  }
  return sum / total;
}
