import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';

/// Which ring of a segment was hit.
enum DartType {
  s(1),
  d(2),
  t(3)
  ;

  const DartType(this.multiplier);
  final int multiplier;
}

/// What a single throw did to the game.
enum ThrowResult {
  /// Counted; the same player throws again.
  scored,

  /// Third dart counted; play passed to the next player.
  turnOver,

  /// Went over. The round is marked bust and waits for [X01Engine.endTurn].
  bust,

  /// Checked out. The winning round is already in [Game.rounds].
  win,

  /// Not accepted: the round is bust or the game is over.
  ignored,
}

/// Rules and turn state for an x01 game (101 / 301 / 501 / 701).
///
/// Mutates [game] in place: completed rounds are appended to [Game.rounds],
/// and [current] holds the round in progress.
class X01Engine {
  X01Engine(this.game, {this.doubleOut = true})
    : assert(game.users.isNotEmpty),
      current = Round(user: game.users.first) {
    _ensureGrowableRounds();
  }

  /// Rebuilds an engine from a saved game and its in-progress round.
  X01Engine.resume(this.game, this.current, {this.doubleOut = true}) {
    _ensureGrowableRounds();
  }

  // Game's default `rounds` is a const list; the engine appends to it.
  void _ensureGrowableRounds() => game.rounds = [...game.rounds];

  final Game game;
  Round current;

  /// Finishing dart must be a double (bull 50 counts). Read before each throw,
  /// so changing the setting mid-game applies from the next dart.
  bool doubleOut;

  bool _finished = false;
  bool get isFinished => _finished;

  User get player => current.user;
  int get playerIndex => game.users.indexWhere((u) => u.id == player.id);

  bool get hasAnyThrow => game.rounds.isNotEmpty || current.dartsThrown > 0;
  bool get canUndo => !_finished && hasAnyThrow;

  /// The current round has gone over and is waiting for [endTurn].
  bool get isBust => current.bust;

  /// Points [user] still needs, counting the round in progress.
  int remaining(User user) {
    var left = game.startFrom;
    for (final r in game.rounds) {
      if (r.user.id == user.id) left -= r.total;
    }
    if (!_finished && current.user.id == user.id) left -= current.total;
    return left;
  }

  /// Average points per completed round for [user] in this game.
  double ppr(User user) {
    final rounds = game.rounds.where((r) => r.user.id == user.id);
    if (rounds.isEmpty) return 0;
    return rounds.fold(0, (v, r) => v + r.total) / rounds.length;
  }

  /// The most recently completed round, by any player.
  Round? get lastRound => game.rounds.isEmpty ? null : game.rounds.last;

  /// Records one dart. [number] is 1–20, 25 for bull, or 0 for a miss.
  ThrowResult throwDart(int number, DartType type) {
    if (_finished || current.bust || current.dartsThrown >= 3) {
      return ThrowResult.ignored;
    }
    assert(number == 0 || number == 25 || (number >= 1 && number <= 20));
    assert(!(number == 25 && type == DartType.t), 'There is no triple bull');

    final score = number * type.multiplier;
    final before = remaining(player);
    _setNextDart(score);
    final after = before - score;

    final finishingDartOk = !doubleOut || (type == DartType.d && score > 0);
    final isBust =
        after < 0 ||
        (doubleOut && after == 1) ||
        (after == 0 && !finishingDartOk);

    if (isBust) {
      current.bust = true;
      return ThrowResult.bust;
    }

    if (after == 0) {
      game.rounds.add(current);
      _finished = true;
      return ThrowResult.win;
    }

    if (current.dartsThrown == 3) {
      _advance();
      return ThrowResult.turnOver;
    }
    return ThrowResult.scored;
  }

  /// Ends the current round early (unthrown darts count as misses) or closes
  /// a bust round, and passes play to the next player.
  void endTurn() {
    if (_finished) return;
    if (!current.bust) {
      current.dart1 ??= 0;
      current.dart2 ??= 0;
      current.dart3 ??= 0;
    }
    _advance();
  }

  /// Removes the most recent dart, stepping back into the previous player's
  /// round when the current one is empty. Returns false when there is
  /// nothing to undo.
  bool undo() {
    if (!canUndo) return false;
    if (current.dartsThrown == 0) {
      current = game.rounds.removeLast();
    }
    // The busting dart is always the last one thrown, so removing it
    // un-busts the round.
    current.bust = false;
    if (current.dart3 != null) {
      current.dart3 = null;
    } else if (current.dart2 != null) {
      current.dart2 = null;
    } else {
      current.dart1 = null;
    }
    return true;
  }

  void _setNextDart(int score) {
    if (current.dart1 == null) {
      current.dart1 = score;
    } else if (current.dart2 == null) {
      current.dart2 = score;
    } else {
      current.dart3 = score;
    }
  }

  void _advance() {
    game.rounds.add(current);
    final next = (playerIndex + 1) % game.users.length;
    current = Round(user: game.users[next]);
  }

  /// Players in the order they throw in a rematch: whoever went second now
  /// starts, and the opener moves to the back.
  static List<User> rotatedForRematch(List<User> users) =>
      users.length < 2 ? [...users] : [...users.skip(1), users.first];
}
