import 'dart:math';

import 'package:darts/core/game/engine.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';

export 'package:darts/core/game/engine.dart';

/// Rules and turn state for a Cricket game: close 15–20 and bull with three
/// marks each, and score on numbers you have closed while an opponent still
/// has them open.
///
/// Like `X01Engine`, it mutates [game] in place: completed rounds are
/// appended to [Game.rounds], and [current] holds the round in progress. Each
/// dart is saved as its segment (`dartN`) and ring (`multN`); the board is
/// rebuilt by replaying them, which keeps undo and resume exact.
class CricketEngine implements GameEngine {
  CricketEngine(this.game)
    : assert(game.users.isNotEmpty),
      current = Round(user: game.users.first) {
    _ensureGrowableRounds();
  }

  /// Rebuilds an engine from a saved game and its in-progress round.
  CricketEngine.resume(this.game, this.current) {
    _ensureGrowableRounds();
    _replay();
  }

  // Game's default `rounds` is a const list; the engine appends to it.
  void _ensureGrowableRounds() => game.rounds = [...game.rounds];

  /// The numbers in play, in scoreboard order. 25 is the bull.
  static const targets = [20, 19, 18, 17, 16, 15, 25];

  /// Marks that close a number.
  static const closingMarks = 3;

  @override
  final Game game;
  @override
  Round current;

  bool _finished = false;
  @override
  bool get isFinished => _finished;

  @override
  User get player => current.user;
  int get playerIndex => game.users.indexWhere((u) => u.id == player.id);

  @override
  bool get hasAnyThrow => game.rounds.isNotEmpty || current.dartsThrown > 0;
  @override
  bool get canUndo => !_finished && hasAnyThrow;

  // Board state, keyed by user id. Rebuilt from the darts by [_replay].
  final _marks = <int, List<int>>{};
  final _points = <int, int>{};
  final _countedMarks = <int, int>{};
  final _completedRounds = <int, int>{};

  /// Marks [user] has on [target], 0–3, counting the round in progress.
  int marks(User user, int target) =>
      _marksOf(user.id)[targets.indexOf(target)];

  bool isClosed(User user, int target) => marks(user, target) >= closingMarks;

  /// Every player has closed [target], so nobody can score on it any more.
  bool isDead(int target) => game.users.every((u) => isClosed(u, target));

  bool hasClosedAll(User user) => _marksOf(user.id).every(_closed);

  /// Points [user] has scored, counting the round in progress.
  int points(User user) => _points[user.id] ?? 0;

  /// Marks per completed round (MPR) for [user] in this game. Only marks
  /// that closed a number or scored count.
  double mpr(User user) {
    final rounds = _completedRounds[user.id] ?? 0;
    if (rounds == 0) return 0;
    return (_countedMarks[user.id] ?? 0) / rounds;
  }

  /// The most recently completed round, by any player.
  Round? get lastRound => game.rounds.isEmpty ? null : game.rounds.last;

  /// Records one dart. [number] is 1–20, 25 for bull, or 0 for a miss; 1–14
  /// are not in play and count as misses.
  @override
  ThrowResult throwDart(int number, DartType type) {
    if (_finished || current.dartsThrown >= 3) return ThrowResult.ignored;
    assert(number == 0 || number == 25 || (number >= 1 && number <= 20));
    assert(!(number == 25 && type == DartType.t), 'There is no triple bull');

    final inPlay = targets.contains(number);
    _setNextDart(inPlay ? number : 0, inPlay ? type.multiplier : null);
    _replay();

    if (_hasWon(player)) {
      game.rounds.add(current);
      _finished = true;
      _replay();
      return ThrowResult.win;
    }

    if (current.dartsThrown == 3) {
      _advance();
      return ThrowResult.turnOver;
    }
    return ThrowResult.scored;
  }

  /// Ends the current round early (unthrown darts count as misses) and
  /// passes play to the next player.
  @override
  void endTurn() {
    if (_finished) return;
    current.dart1 ??= 0;
    current.dart2 ??= 0;
    current.dart3 ??= 0;
    _advance();
  }

  /// Removes the most recent dart, stepping back into the previous player's
  /// round when the current one is empty. Returns false when there is
  /// nothing to undo.
  @override
  bool undo() {
    if (!canUndo) return false;
    if (current.dartsThrown == 0) {
      current = game.rounds.removeLast();
    }
    if (current.dart3 != null) {
      current
        ..dart3 = null
        ..mult3 = null;
    } else if (current.dart2 != null) {
      current
        ..dart2 = null
        ..mult2 = null;
    } else {
      current
        ..dart1 = null
        ..mult1 = null;
    }
    _replay();
    return true;
  }

  /// Closed everything and has the highest (or equal-highest) points.
  bool _hasWon(User user) =>
      hasClosedAll(user) && game.users.every((u) => points(u) <= points(user));

  void _setNextDart(int number, int? mult) {
    if (current.dart1 == null) {
      current
        ..dart1 = number
        ..mult1 = mult;
    } else if (current.dart2 == null) {
      current
        ..dart2 = number
        ..mult2 = mult;
    } else {
      current
        ..dart3 = number
        ..mult3 = mult;
    }
  }

  void _advance() {
    game.rounds.add(current);
    final next = (playerIndex + 1) % game.users.length;
    current = Round(user: game.users[next]);
    _replay();
  }

  static bool _closed(int marks) => marks >= closingMarks;

  List<int> _marksOf(int userId) =>
      _marks.putIfAbsent(userId, () => List.filled(targets.length, 0));

  /// Rebuilds the board from every dart thrown so far, in order.
  void _replay() {
    _marks.clear();
    _points.clear();
    _countedMarks.clear();
    _completedRounds.clear();
    for (final r in game.rounds) {
      final counted = _applyRound(r);
      _countedMarks.update(
        r.user.id,
        (v) => v + counted,
        ifAbsent: () => counted,
      );
      _completedRounds.update(r.user.id, (v) => v + 1, ifAbsent: () => 1);
    }
    // Once won, the current round is already the last of [Game.rounds].
    if (!_finished) _applyRound(current);
  }

  int _applyRound(Round r) {
    var counted = 0;
    for (var i = 0; i < 3; i++) {
      final number = r.darts[i];
      if (number == null) break;
      counted += _applyDart(r.user, number, r.mults[i] ?? 0);
    }
    return counted;
  }

  /// Applies one dart to the board and returns how many of its marks
  /// counted (closed the number or scored).
  int _applyDart(User user, int number, int mult) {
    final t = targets.indexOf(number);
    if (t < 0 || mult == 0) return 0;

    final marks = _marksOf(user.id);
    final closing = min(mult, max(0, closingMarks - marks[t]));
    marks[t] += closing;

    final extra = mult - closing;
    final opponentOpen = game.users.any(
      (u) => u.id != user.id && !_closed(_marksOf(u.id)[t]),
    );
    if (extra == 0 || !opponentOpen) return closing;

    _points.update(
      user.id,
      (v) => v + extra * number,
      ifAbsent: () => extra * number,
    );
    return closing + extra;
  }

  /// Marks that counted in each of [game]'s completed rounds, as
  /// (player id, marks) pairs. For marks-per-round across saved games.
  static Iterable<(int, int)> countedMarksPerRound(Game game) sync* {
    // An empty board for the same players, fed the saved rounds in order.
    final board = CricketEngine(
      Game(date: game.date, startFrom: 0, mode: game.mode, users: game.users),
    );
    for (final r in game.rounds) {
      yield (r.user.id, board._applyRound(r));
    }
  }
}
