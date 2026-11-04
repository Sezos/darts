import 'package:darts/core/providers/user/user.provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game.provider.g.dart';
part 'game.provider.freezed.dart';

/// Rules a game is played under.
enum GameMode { x01, cricket }

@unfreezed
abstract class Game with _$Game {
  Game._();

  factory Game({
    required DateTime date,

    /// x01 starting score (101–701). Cricket games save 0.
    required int startFrom,

    /// Games saved before Cricket existed have no mode and load as x01.
    @Default(GameMode.x01) GameMode mode,
    @Default(<User>[]) List<User> users,
    @Default(<Round>[]) List<Round> rounds,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  bool get isCricket => mode == GameMode.cricket;

  /// For a finished game, the player whose round won it.
  /// Saved games always end on the winning round.
  User? get winner => rounds.isEmpty ? null : rounds.last.user;
}

@unfreezed
abstract class Round with _$Round {
  Round._();

  factory Round({
    required User user,

    /// x01: the points each dart scored. Cricket: the segment hit (15–20, or
    /// 25 for bull), or 0 for a miss or any other number.
    int? dart1,
    int? dart2,
    int? dart3,

    /// The round went over (or left an unfinishable 1). Its darts stay
    /// recorded so undo can restore them, but it scores nothing.
    @Default(false) bool bust,

    /// Cricket only: each dart's ring (1 single, 2 double, 3 triple), null
    /// for a miss. Left out of x01 saves.
    @JsonKey(includeIfNull: false) int? mult1,
    @JsonKey(includeIfNull: false) int? mult2,
    @JsonKey(includeIfNull: false) int? mult3,
  }) = _Round;

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);

  List<int?> get darts => [dart1, dart2, dart3];

  List<int?> get mults => [mult1, mult2, mult3];

  int get dartsThrown => darts.where((d) => d != null).length;

  /// x01: sum of the darts thrown, ignoring bust. Meaningless for Cricket.
  int get rawTotal => (dart1 ?? 0) + (dart2 ?? 0) + (dart3 ?? 0);

  /// Points this round takes off the player's remaining score.
  int get total => bust ? 0 : rawTotal;
}

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  String key = 'games';

  @override
  List<Game> build() {
    var games = storage.read(key);

    if (games == null) {
      final lol = <Game>[];
      saveState(lol);
      return lol;
    }

    return (games as List).map((e) => Game.fromJson(e)).toList();
  }

  void addGame(Game game) {
    state = [...state, game];
    saveState();
  }

  void deleteGame(Game game) {
    state = state.where((g) => !identical(g, game)).toList();
    saveState();
  }

  /// Adds games from an online backup that aren't on this phone yet, in
  /// play order. A game's start time identifies it.
  void mergeBackup(List<Game> games) {
    final have = {for (final g in state) g.date.microsecondsSinceEpoch};
    final missing = [
      for (final g in games)
        if (!have.contains(g.date.microsecondsSinceEpoch)) g,
    ];
    if (missing.isEmpty) return;
    state = [...state, ...missing]..sort((a, b) => a.date.compareTo(b.date));
    saveState();
  }

  void saveState([List<Game>? list]) {
    storage.write(key, (list ?? state).map((e) => e.toJson()).toList());
  }
}

/// Average points per round for [userId] across saved x01 games, or "-".
String averagePpr(List<Game> games, int userId) {
  final scores = [
    for (final g in games)
      if (g.mode == GameMode.x01)
        for (final r in g.rounds)
          if (r.user.id == userId) r.total,
  ];
  if (scores.isEmpty) return "-";
  return (scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(1);
}
