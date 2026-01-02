import 'package:darts/core/providers/user/user.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'players.provider.g.dart';

@riverpod
class PlayersNotifier extends _$PlayersNotifier {
  String key = 'players';

  @override
  List<User> build() {
    var players = storage.read(key);

    var user = ref.read(userProvider);

    if (players == null) {
      final lol = [
        user,
        User(id: 2, name: "Player 2"),
        User(id: 3, name: "Player 3"),
        User(id: 4, name: "Player 4"),
        User(id: 5, name: "Player 5"),
        User(id: 6, name: "Player 6"),
        User(id: 7, name: "Player 7"),
        User(id: 8, name: "Player 8"),
      ];
      saveState(lol);
      return lol;
    } else {
      var kk = (players as List).map((e) => User.fromJson(e)).toList();
      kk.removeWhere((e) => e.id == 0);
      return [user, ...kk];
    }
  }

  void addPlayer(User user) {
    state = [...state, user];
    saveState();
  }

  void saveState([List<User>? list]) {
    storage.write(key, (list ?? state).map((e) => e.toJson()).toList());
  }

  void deletePlayer(int userId) {
    state = state.where((user) => user.id != userId).toList();
    saveState();
  }

  void updatePlayer(User user) {
    state = [
      for (final p in state)
        if (p.id == user.id) user else p,
    ];
    saveState();
  }
}
