import 'package:darts/core/game.screen.dart';
import 'package:darts/core/history.screen.dart';
import 'package:darts/core/homescreen.dart';
import 'package:darts/core/players.screen.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/game/ongoing_game.provider.dart';
import 'package:darts/core/settings.screen.dart';
import 'package:darts/core/stats.screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      name: "home",
      builder: (context, state) => const Homescreen(),
    ),
    GoRoute(
      path: "/players",
      name: "players",
      builder: (context, state) => const PlayersScreen(),
    ),
    GoRoute(
      path: "/settings",
      name: "settings",
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: "/game",
      name: "game",
      // A new Game starts fresh; an OngoingGame resumes where it was left.
      builder: (context, state) => switch (state.extra) {
        OngoingGame o => GameScreen(o.game, resumeRound: o.current),
        Game g => GameScreen(g),
        _ => const Homescreen(),
      },
    ),
    GoRoute(
      path: "/history",
      name: "history",
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: "/stats",
      name: "stats",
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return StatsScreen(
          userId: extra['userId'] as int,
          userName: extra['userName'] as String,
        );
      },
    ),
  ],
);
