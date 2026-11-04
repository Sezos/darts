import 'package:darts/core/game/skill_rating.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:flutter_test/flutter_test.dart';

final a = User(id: 1, name: 'A');
final b = User(id: 2, name: 'B');

Round visit(User u, int d1, int d2, int d3, {bool bust = false}) =>
    Round(user: u, dart1: d1, dart2: d2, dart3: d3, bust: bust);

/// An x01 game where [a] averages [perVisit] a visit over [visits] visits
/// and [b] throws nothing but misses. The last visit is [a]'s checkout.
Game x01Game(int perVisit, {int visits = 4}) => Game(
  date: DateTime(2026),
  startFrom: 501,
  users: [a, b],
  rounds: [
    for (var i = 0; i < visits; i++) ...[
      visit(a, perVisit, 0, 0),
      if (i < visits - 1) visit(b, 0, 0, 0),
    ],
  ],
);

List<Game> games(int count, int perVisit) => [
  for (var i = 0; i < count; i++) x01Game(perVisit),
];

void main() {
  group('rankFor', () {
    test('x01 tiers follow 3-dart average bands', () {
      expect(rankFor(RatingMode.x01, 0).tier, Tier.rookie);
      expect(rankFor(RatingMode.x01, 19.9).tier, Tier.rookie);
      expect(rankFor(RatingMode.x01, 20).tier, Tier.pubThrower);
      expect(rankFor(RatingMode.x01, 45).tier, Tier.trebleHunter);
      expect(rankFor(RatingMode.x01, 79.9).tier, Tier.club180);
      expect(rankFor(RatingMode.x01, 80).tier, Tier.nineDarter);
    });

    test('each tier splits into divisions I–III', () {
      expect(rankFor(RatingMode.x01, 40), const Rank(Tier.trebleHunter, 1, 0));
      expect(rankFor(RatingMode.x01, 44).division, 2);
      expect(rankFor(RatingMode.x01, 47).division, 3);
      expect(rankFor(RatingMode.x01, 45).progress, closeTo(0.5, 1e-9));
    });

    test('anything past the top tier is Nine-Darter III', () {
      final r = rankFor(RatingMode.x01, 120);
      expect(r, const Rank(Tier.nineDarter, 3, 1));
      expect(r.step, 23);
    });

    test('Cricket tiers follow MPR bands', () {
      expect(rankFor(RatingMode.cricket, 0.5).tier, Tier.rookie);
      expect(rankFor(RatingMode.cricket, 1.7).tier, Tier.trebleHunter);
      expect(rankFor(RatingMode.cricket, 3.6).tier, Tier.nineDarter);
    });
  });

  group('x01 rating', () {
    test('no rank until $placementGames games', () {
      final r = skillRating(
        games(placementGames - 1, 45),
        a.id,
        RatingMode.x01,
      );
      expect(r.isPlacement, isTrue);
      expect(r.games, placementGames - 1);
      expect(r.rank, isNull);
    });

    test('the placement game gives a rank, with no change yet', () {
      final r = skillRating(games(placementGames, 45), a.id, RatingMode.x01);
      expect(r.justPlaced, isTrue);
      expect(r.value, closeTo(45, 1e-9));
      expect(r.change, isNull);
      expect(r.rank!.tier, Tier.trebleHunter);
    });

    test('a bust visit still costs 3 darts', () {
      final g = Game(
        date: DateTime(2026),
        startFrom: 501,
        users: [a],
        rounds: [
          visit(a, 60, 60, 60),
          visit(a, 60, 60, 0, bust: true),
          visit(a, 60, 0, 0),
        ],
      );
      // 180 + 0 + 60 over 9 darts.
      final r = skillRating(
        List.filled(placementGames, g),
        a.id,
        RatingMode.x01,
      );
      expect(r.value, closeTo(80, 1e-9));
    });

    test('a short checkout visit counts only the darts thrown', () {
      final g = Game(
        date: DateTime(2026),
        startFrom: 101,
        users: [a],
        rounds: [
          visit(a, 60, 1, 0),
          Round(user: a, dart1: 40),
        ],
      );
      // 101 points over 4 darts.
      final r = skillRating(
        List.filled(placementGames, g),
        a.id,
        RatingMode.x01,
      );
      expect(r.value, closeTo(101 / 4 * 3, 1e-9));
    });

    test('recent games count more than old ones', () {
      final improving = [...games(10, 30), ...games(3, 60)];
      final r = skillRating(improving, a.id, RatingMode.x01);
      // Plain average of these 13 games would be ~36.9.
      expect(r.value!, greaterThan(40));
      expect(r.value!, lessThan(60));
    });

    test('only the last 20 games count', () {
      final r = skillRating(
        [...games(30, 20), ...games(20, 50)],
        a.id,
        RatingMode.x01,
      );
      expect(r.value, closeTo(50, 1e-9));
    });

    test('a better game raises the rating and can rank up', () {
      final history = [...games(8, 39), x01Game(100)];
      final r = skillRating(history, a.id, RatingMode.x01);
      expect(r.change!, greaterThan(0));
      expect(r.previousRank!.tier, Tier.ocheRegular);
      expect(r.rankedUp, isTrue);
    });

    test("other players' visits and Cricket games don't count", () {
      final cricket = Game(
        date: DateTime(2026),
        startFrom: 0,
        mode: GameMode.cricket,
        users: [a, b],
        rounds: [visit(a, 20, 20, 20)],
      );
      final r = skillRating([...games(5, 45), cricket], a.id, RatingMode.x01);
      expect(r.games, 5);
      expect(skillRating(games(5, 45), b.id, RatingMode.x01).value, 0);
    });
  });

  test("a game the player never threw in doesn't count for them", () {
    // [a] checks out in their first visit before [b] throws.
    final quick = Game(
      date: DateTime(2026),
      startFrom: 101,
      users: [a, b],
      rounds: [visit(a, 60, 1, 40)],
    );
    final before = [...games(6, 45)];
    final rb = skillRating([...before, quick], b.id, RatingMode.x01);
    expect(rb.games, 6);
    expect(rb.countedIn(quick), isFalse);
    final ra = skillRating([...before, quick], a.id, RatingMode.x01);
    expect(ra.countedIn(quick), isTrue);
  });

  group('Cricket rating', () {
    test('rates marks per round', () {
      // Every round [a] hits a triple 20 and [b] misses everything.
      final g = Game(
        date: DateTime(2026),
        startFrom: 0,
        mode: GameMode.cricket,
        users: [a, b],
        rounds: [
          for (var i = 0; i < 4; i++) ...[
            Round(user: a, dart1: 20, mult1: 3, dart2: 0, dart3: 0),
            visit(b, 0, 0, 0),
          ],
        ],
      );
      final r = skillRating(
        List.filled(placementGames, g),
        a.id,
        RatingMode.cricket,
      );
      // The first triple closes 20; the rest score because [b] never
      // closes it. Every one counts: 3 marks a round.
      expect(r.value, closeTo(3, 1e-9));
      expect(r.rank!.tier, Tier.club180);
      expect(skillRating(List.filled(5, g), b.id, RatingMode.cricket).value, 0);
    });
  });
}
