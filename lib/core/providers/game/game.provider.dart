import 'package:darts/core/providers/user/user.provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game.provider.g.dart';
part 'game.provider.freezed.dart';

@unfreezed
abstract class Game with _$Game {
  factory Game({
    required DateTime date,
    required int startFrom,
    @Default(<User>[]) List<User> users,
    @Default(<Round>[]) List<Round> rounds,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

@unfreezed
abstract class Round with _$Round {
  factory Round({
    required User user,
    int? dart1,
    int? dart2,
    int? dart3,
  }) = _Round;

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);
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

  String getAverage() {
    final user = ref.watch(userProvider);
    final myMatches = state
        .where((e) => e.users.any((e) => e.id == user.id))
        .toList();

    List<int> myPPRs = myMatches.fold(
      [],
      (value, e) => [
        ...value,
        ...e.rounds
            .where((e) => e.user.id == user.id)
            .fold(
              [],
              (value1, e1) => [
                ...value1,
                (e1.dart1 ?? 0) + (e1.dart2 ?? 0) + (e1.dart3 ?? 0),
              ],
            ),
      ],
    );

    if (myPPRs.isEmpty) {
      return "-";
    }

    return ((myPPRs.reduce((value, element) => value + element)) /
            myPPRs.length)
        .toStringAsFixed(1);
  }

  void addGame(Game game) {
    state = [...state, game];
    saveState();
  }

  void saveState([List<Game>? list]) {
    storage.write(key, (list ?? state).map((e) => e.toJson()).toList());
  }
}
