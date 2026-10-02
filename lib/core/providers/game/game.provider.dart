import 'package:darts/core/providers/user/user.provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game.provider.g.dart';
part 'game.provider.freezed.dart';

@unfreezed
abstract class Game with _$Game {
  Game._();

  factory Game({
    required DateTime date,
    required int startFrom,
    @Default(<User>[]) List<User> users,
    @Default(<Round>[]) List<Round> rounds,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  /// For a finished game, the player whose round checked out.
  /// Saved games always end on the winning round.
  User? get winner => rounds.isEmpty ? null : rounds.last.user;
}

@unfreezed
abstract class Round with _$Round {
  Round._();

  factory Round({
    required User user,
    int? dart1,
    int? dart2,
    int? dart3,

    /// The round went over (or left an unfinishable 1). Its darts stay
    /// recorded so undo can restore them, but it scores nothing.
    @Default(false) bool bust,
  }) = _Round;

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);

  List<int?> get darts => [dart1, dart2, dart3];

  int get dartsThrown => darts.where((d) => d != null).length;

  /// Sum of the darts thrown, ignoring bust.
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

  void saveState([List<Game>? list]) {
    storage.write(key, (list ?? state).map((e) => e.toJson()).toList());
  }
}

/// Average points per round for [userId] across saved games, or "-".
String averagePpr(List<Game> games, int userId) {
  final scores = [
    for (final g in games)
      for (final r in g.rounds)
        if (r.user.id == userId) r.total,
  ];
  if (scores.isEmpty) return "-";
  return (scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(1);
}
