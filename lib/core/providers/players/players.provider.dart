import 'package:darts/core/providers/settings/settings.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/l10n/l10n.dart';
import 'package:darts/utils/analytics.dart';
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
      final l10n = l10nFor(ref.read(settingsProvider).language);
      final lol = [
        user,
        for (var id = 2; id <= 8; id++)
          User(id: id, name: l10n.defaultPlayerName(id)),
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
    final players = list ?? state;
    storage.write(key, players.map((e) => e.toJson()).toList());
    Analytics.savedPlayers(players.length);
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
