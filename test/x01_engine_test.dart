import 'package:darts/core/game/x01_engine.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:flutter_test/flutter_test.dart';

final a = User(id: 1, name: 'A');
final b = User(id: 2, name: 'B');
final c = User(id: 3, name: 'C');

X01Engine engine(int startFrom, {bool doubleOut = true, List<User>? users}) =>
    X01Engine(
      Game(date: DateTime(2026), startFrom: startFrom, users: users ?? [a, b]),
      doubleOut: doubleOut,
    );

void main() {
  group('scoring', () {
    test('three darts score and pass play to the next player', () {
      final e = engine(501);
      expect(e.throwDart(20, DartType.t), ThrowResult.scored);
      expect(e.throwDart(20, DartType.t), ThrowResult.scored);
      expect(e.throwDart(20, DartType.s), ThrowResult.turnOver);
      expect(e.remaining(a), 501 - 140);
      expect(e.player.id, b.id);
    });

    test('a miss is zero whatever ring is selected', () {
      final e = engine(301);
      e.throwDart(0, DartType.t);
      expect(e.remaining(a), 301);
      expect(e.current.dart1, 0);
    });

    test('ending a turn early counts the unthrown darts as misses', () {
      final e = engine(301);
      e.throwDart(19, DartType.s);
      e.endTurn();
      expect(e.game.rounds.single.darts, [19, 0, 0]);
      expect(e.player.id, b.id);
    });

    test('play wraps from the last player back to the first', () {
      final e = engine(301, users: [a, b, c]);
      e.endTurn();
      e.endTurn();
      e.endTurn();
      expect(e.player.id, a.id);
    });
  });

  group('double-out', () {
    test('finishing on a double wins', () {
      final e = engine(40);
      expect(e.throwDart(20, DartType.d), ThrowResult.win);
      expect(e.isFinished, isTrue);
      expect(e.game.winner?.id, a.id);
      expect(e.remaining(a), 0);
    });

    test('bull 50 counts as a double finish', () {
      final e = engine(50);
      expect(e.throwDart(25, DartType.d), ThrowResult.win);
    });

    test('reaching zero on a single is a bust', () {
      final e = engine(20);
      expect(e.throwDart(20, DartType.s), ThrowResult.bust);
      expect(e.remaining(a), 20);
    });

    test('leaving 1 is a bust', () {
      final e = engine(21);
      expect(e.throwDart(20, DartType.s), ThrowResult.bust);
    });

    test('going under zero is a bust and the round scores nothing', () {
      final e = engine(60);
      e.throwDart(20, DartType.s);
      expect(e.throwDart(20, DartType.t), ThrowResult.bust);
      expect(e.remaining(a), 60);
      e.endTurn();
      expect(e.game.rounds.single.total, 0);
      expect(e.player.id, b.id);
    });
  });

  group('straight-out', () {
    test('any dart that reaches zero wins', () {
      final e = engine(20, doubleOut: false);
      expect(e.throwDart(20, DartType.s), ThrowResult.win);
    });

    test('leaving 1 is allowed', () {
      final e = engine(21, doubleOut: false);
      expect(e.throwDart(20, DartType.s), ThrowResult.scored);
      expect(e.remaining(a), 1);
      expect(e.throwDart(1, DartType.s), ThrowResult.win);
    });

    test('going under zero is still a bust', () {
      final e = engine(10, doubleOut: false);
      expect(e.throwDart(11, DartType.s), ThrowResult.bust);
    });
  });

  group('bust round', () {
    test('ignores further darts until the turn ends', () {
      final e = engine(10);
      expect(e.throwDart(20, DartType.s), ThrowResult.bust);
      // Fast taps during the bust animation must not count or skip a player.
      expect(e.throwDart(5, DartType.d), ThrowResult.ignored);
      expect(e.throwDart(5, DartType.d), ThrowResult.ignored);
      expect(e.player.id, a.id);
      e.endTurn();
      expect(e.player.id, b.id);
      expect(e.game.rounds, hasLength(1));
    });

    test('undo restores the real darts and clears the bust', () {
      final e = engine(30);
      e.throwDart(10, DartType.s);
      e.throwDart(20, DartType.d); // 30 - 10 - 40 < 0
      expect(e.isBust, isTrue);
      e.endTurn();

      expect(e.undo(), isTrue);
      expect(e.player.id, a.id);
      expect(e.isBust, isFalse);
      expect(e.current.darts, [10, null, null]);
      expect(e.remaining(a), 20);
      // And the player can now finish correctly.
      expect(e.throwDart(10, DartType.d), ThrowResult.win);
    });
  });

  group('undo', () {
    test('removes darts one at a time', () {
      final e = engine(501);
      e.throwDart(20, DartType.t);
      e.throwDart(19, DartType.t);
      e.undo();
      expect(e.current.darts, [60, null, null]);
      e.undo();
      expect(e.current.darts, [null, null, null]);
      expect(e.canUndo, isFalse);
      expect(e.undo(), isFalse);
    });

    test("steps back into the previous player's round", () {
      final e = engine(501);
      e.throwDart(20, DartType.s);
      e.throwDart(20, DartType.s);
      e.throwDart(20, DartType.s);
      expect(e.player.id, b.id);
      e.undo();
      expect(e.player.id, a.id);
      expect(e.current.darts, [20, 20, null]);
      expect(e.remaining(a), 461);
    });

    test('is unavailable once the game is won', () {
      final e = engine(40);
      e.throwDart(20, DartType.d);
      expect(e.canUndo, isFalse);
      expect(e.throwDart(1, DartType.s), ThrowResult.ignored);
    });
  });

  test('resume continues from a JSON round-trip of the saved state', () {
    final e = engine(301);
    e.throwDart(20, DartType.t);
    final resumed = X01Engine.resume(
      Game.fromJson(_plain(e.game.toJson())),
      Round.fromJson(_plain(e.current.toJson())),
    );
    expect(resumed.player.id, a.id);
    expect(resumed.remaining(a), 241);
    expect(resumed.throwDart(20, DartType.t), ThrowResult.scored);
  });

  test('rematch order rotates the opener to the back', () {
    expect(X01Engine.rotatedForRematch([a, b, c]).map((u) => u.id), [2, 3, 1]);
    expect(X01Engine.rotatedForRematch([a, b]).map((u) => u.id), [2, 1]);
  });

  test('bust rounds count as zero in the saved-game average', () {
    final g = Game(
      date: DateTime(2026),
      startFrom: 501,
      users: [a],
      rounds: [
        Round(user: a, dart1: 60, dart2: 60, dart3: 60),
        Round(user: a, dart1: 60, dart2: 60, bust: true),
      ],
    );
    expect(averagePpr([g], a.id), '90.0');
  });
}

/// toJson leaves nested models as objects; storage hands back plain maps.
Map<String, dynamic> _plain(Map<String, dynamic> json) => json.map(
  (k, v) => MapEntry(k, switch (v) {
    User u => u.toJson(),
    List l =>
      l
          .map(
            (e) => switch (e) {
              User u => u.toJson(),
              Round r => _plain(r.toJson()),
              _ => e,
            },
          )
          .toList(),
    _ => v,
  }),
);
