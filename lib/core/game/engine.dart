import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';

/// Which ring of a segment was hit.
enum DartType {
  s(1),
  d(2),
  t(3);

  const DartType(this.multiplier);
  final int multiplier;
}

/// What a single throw did to the game.
enum ThrowResult {
  /// Counted; the same player throws again.
  scored,

  /// Third dart counted; play passed to the next player.
  turnOver,

  /// x01 only: went over. The round is marked bust and waits for
  /// [GameEngine.endTurn].
  bust,

  /// Won the game. The winning round is already in [Game.rounds].
  win,

  /// Not accepted: the round is bust or the game is over.
  ignored,
}

/// Turn handling every game mode shares, so the game screen can drive x01
/// and Cricket the same way.
abstract interface class GameEngine {
  Game get game;

  /// The round in progress.
  Round get current;

  /// Whose turn it is.
  User get player;

  bool get isFinished;
  bool get hasAnyThrow;
  bool get canUndo;

  /// Records one dart. [number] is 1–20, 25 for bull, or 0 for a miss.
  ThrowResult throwDart(int number, DartType type);

  /// Ends the current round early (unthrown darts count as misses) and
  /// passes play to the next player.
  void endTurn();

  /// Removes the most recent dart. Returns false when there is nothing to
  /// undo.
  bool undo();
}
