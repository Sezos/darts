import 'package:darts/core/game/cricket_engine.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:flutter_test/flutter_test.dart';

final a = User(id: 1, name: 'A');
final b = User(id: 2, name: 'B');
final c = User(id: 3, name: 'C');

CricketEngine engine({List<User>? users}) => CricketEngine(
  Game(
    date: DateTime(2026),
    startFrom: 0,
    mode: GameMode.cricket,
    users: users ?? [a, b],
  ),
);

const s = DartType.s;
const d = DartType.d;
const t = DartType.t;

/// Throws [darts] in order and returns the last result.
ThrowResult play(CricketEngine e, List<(int, DartType)> darts) {
  var result = ThrowResult.ignored;
  for (final (number, type) in darts) {
    result = e.throwDart(number, type);
  }
  return result;
}

void main() {
  group('marks', () {
    test('single, double and triple add 1, 2 and 3 marks', () {
      final e = engine();
      play(e, [(20, s), (19, d), (18, t)]);
      expect(e.marks(a, 20), 1);
      expect(e.marks(a, 19), 2);
      expect(e.marks(a, 18), 3);
      expect(e.isClosed(a, 18), isTrue);
      expect(e.isClosed(a, 19), isFalse);
    });

    test('three marks close a number and the count stops at 3', () {
      final e = engine();
      expect(play(e, [(20, s), (20, s)]), ThrowResult.scored);
      expect(e.isClosed(a, 20), isFalse);
      expect(play(e, [(20, s)]), ThrowResult.turnOver);
      expect(e.isClosed(a, 20), isTrue);
      e.endTurn();
      play(e, [(20, t)]);
      expect(e.marks(a, 20), 3);
    });

    test('outer bull is one mark and inner bull two', () {
      final e = engine();
      play(e, [(25, s)]);
      expect(e.marks(a, 25), 1);
      play(e, [(25, d)]);
      expect(e.marks(a, 25), 3);
      expect(e.isClosed(a, 25), isTrue);
    });

    test('numbers 1–14 count as misses', () {
      final e = engine();
      expect(play(e, [(14, t), (1, d), (0, s)]), ThrowResult.turnOver);
      final round = e.game.rounds.single;
      expect(round.darts, [0, 0, 0]);
      expect(round.mults, [null, null, null]);
      for (final target in CricketEngine.targets) {
        expect(e.marks(a, target), 0);
      }
      expect(e.player.id, b.id);
    });

    test('ending a turn early counts the unthrown darts as misses', () {
      final e = engine();
      play(e, [(20, t)]);
      e.endTurn();
      expect(e.game.rounds.single.darts, [20, 0, 0]);
      expect(e.player.id, b.id);
    });
  });

  group('scoring', () {
    test('marks past closing score while an opponent has it open', () {
      final e = engine();
      play(e, [(20, s), (20, t)]); // 1 + 2 close it, 1 extra scores
      expect(e.isClosed(a, 20), isTrue);
      expect(e.points(a), 20);
      play(e, [(20, d)]);
      expect(e.points(a), 60);
      expect(e.points(b), 0);
    });

    test('scoring continues while any one opponent has it open', () {
      final e = engine(users: [a, b, c]);
      play(e, [(20, t)]);
      e.endTurn();
      play(e, [(20, t)]);
      e.endTurn();
      e.endTurn(); // C still has 20 open
      play(e, [(20, t)]);
      expect(e.points(a), 60);
    });

    test('no points once every opponent has closed it', () {
      final e = engine();
      play(e, [(20, t)]);
      e.endTurn();
      play(e, [(20, t)]);
      e.endTurn();
      play(e, [(20, t)]);
      expect(e.points(a), 0);
      expect(e.isDead(20), isTrue);
      expect(e.isDead(19), isFalse);
    });

    test('bull scores 25 a mark', () {
      final e = engine();
      play(e, [(25, d), (25, d)]); // 2 + 1 close it, 1 extra scores
      expect(e.points(a), 25);
      play(e, [(25, d)]);
      expect(e.points(a), 75);
    });

    test('a solo game never scores points', () {
      final e = engine(users: [a]);
      play(e, [(20, t), (20, t), (20, t)]);
      expect(e.points(a), 0);
    });
  });

  group('win', () {
    test('closing everything level on points wins', () {
      final e = engine();
      play(e, [(20, t), (19, t), (18, t)]);
      e.endTurn();
      play(e, [(17, t), (16, t), (15, t)]);
      e.endTurn();
      expect(play(e, [(25, d)]), ThrowResult.scored);
      expect(play(e, [(25, s)]), ThrowResult.win);
      expect(e.isFinished, isTrue);
      expect(e.game.winner?.id, a.id);
      expect(e.game.rounds.last.darts, [25, 25, null]);
    });

    test('closing everything while behind on points is not a win', () {
      final e = engine();
      e.endTurn();
      play(e, [(20, t), (20, t), (0, s)]); // B: 60 points
      play(e, [(20, t), (19, t), (18, t)]);
      e.endTurn();
      play(e, [(17, t), (16, t), (15, t)]);
      e.endTurn();

      // A closes out on 0 points against 60: play goes on.
      expect(play(e, [(25, d), (25, s)]), ThrowResult.scored);
      expect(e.hasClosedAll(a), isTrue);
      expect(e.isFinished, isFalse);
      // 19 is still open for B, so A can catch up.
      expect(play(e, [(19, t)]), ThrowResult.turnOver);
      expect(e.points(a), 57);
      expect(e.isFinished, isFalse);

      e.endTurn();
      expect(play(e, [(19, s)]), ThrowResult.win);
      expect(e.points(a), 76);
      expect(e.game.winner?.id, a.id);
    });

    test('a solo game ends when every number is closed', () {
      final e = engine(users: [a]);
      play(e, [(20, t), (19, t), (18, t)]);
      play(e, [(17, t), (16, t), (15, t)]);
      expect(play(e, [(25, d), (25, s)]), ThrowResult.win);
    });

    test('nothing is accepted after the win', () {
      final e = engine(users: [a]);
      play(e, [(20, t), (19, t), (18, t)]);
      play(e, [(17, t), (16, t), (15, t)]);
      play(e, [(25, d), (25, s)]);
      expect(e.canUndo, isFalse);
      expect(e.undo(), isFalse);
      expect(e.throwDart(20, t), ThrowResult.ignored);
      expect(e.game.rounds, hasLength(3));
    });
  });

  group('undo', () {
    test('removes the last dart with its marks and points', () {
      final e = engine();
      play(e, [(20, s), (20, t)]);
      expect(e.points(a), 20);
      expect(e.undo(), isTrue);
      expect(e.marks(a, 20), 1);
      expect(e.points(a), 0);
      expect(e.current.darts, [20, null, null]);
      expect(e.current.mults, [1, null, null]);
    });

    test("steps back into the previous player's round", () {
      final e = engine();
      play(e, [(20, t), (19, t), (18, t)]);
      expect(e.player.id, b.id);
      e.undo();
      expect(e.player.id, a.id);
      expect(e.current.darts, [20, 19, null]);
      expect(e.marks(a, 18), 0);
      expect(e.isClosed(a, 19), isTrue);
    });

    test("reopening an opponent's number lets it score again", () {
      final e = engine();
      play(e, [(20, t)]);
      e.endTurn();
      play(e, [(20, t)]); // B closes 20
      e.undo(); // ...and takes it back
      e.endTurn();
      play(e, [(20, t)]);
      expect(e.points(a), 60);
    });

    test('there is nothing to undo before the first dart', () {
      final e = engine();
      expect(e.canUndo, isFalse);
      expect(e.undo(), isFalse);
    });
  });

  group('marks per round', () {
    test('counts marks that closed or scored, per completed round', () {
      final e = engine();
      play(e, [(20, t), (20, t), (0, s)]); // 3 closing + 3 scoring
      play(e, [(20, t)]); // B closes 20
      e.endTurn();
      play(e, [(20, t)]); // dead: counts nothing
      e.endTurn();
      expect(e.mpr(a), 3.0);
      expect(e.mpr(b), 3.0);
      expect(CricketEngine.countedMarksPerRound(e.game).toList(), [
        (a.id, 6),
        (b.id, 3),
        (a.id, 0),
      ]);
    });

    test('the round in progress is not counted yet', () {
      final e = engine();
      play(e, [(20, t)]);
      expect(e.mpr(a), 0);
    });
  });

  group('saving', () {
    test('resume continues from a JSON round-trip of the saved state', () {
      final e = engine();
      play(e, [(20, t), (20, s)]);
      e.endTurn();
      play(e, [(19, d)]);

      final resumed = CricketEngine.resume(
        Game.fromJson(_plain(e.game.toJson())),
        Round.fromJson(_plain(e.current.toJson())),
      );
      expect(resumed.game.mode, GameMode.cricket);
      expect(resumed.player.id, b.id);
      expect(resumed.points(a), 20);
      expect(resumed.marks(b, 19), 2);
      expect(resumed.current.mults, [2, null, null]);

      // 2 marks + a triple: 1 closes 19, 2 score while A has it open.
      expect(resumed.throwDart(19, t), ThrowResult.scored);
      expect(resumed.points(b), 38);
    });

    test('an old saved game with no mode loads as x01', () {
      final json = {
        'date': '2026-01-01T00:00:00.000',
        'startFrom': 501,
        'users': [a.toJson()],
        'rounds': [
          {
            'user': a.toJson(),
            'dart1': 60,
            'dart2': 20,
            'dart3': null,
            'bust': false,
          },
        ],
      };
      final game = Game.fromJson(json);
      expect(game.mode, GameMode.x01);
      expect(game.isCricket, isFalse);
      expect(game.rounds.single.total, 80);
      expect(game.rounds.single.mults, [null, null, null]);
    });

    test('x01 rounds save without ring fields', () {
      final json = Round(user: a, dart1: 60).toJson();
      expect(json.containsKey('mult1'), isFalse);
    });

    test('the saved-game average leaves Cricket games out', () {
      final e = engine();
      play(e, [(20, t), (20, t), (20, t)]);
      expect(averagePpr([e.game], a.id), '-');
    });
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
