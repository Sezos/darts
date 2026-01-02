import 'package:darts/core/game.screen.dart';
import 'package:darts/core/history.screen.dart';
import 'package:darts/core/homescreen.dart';
import 'package:darts/core/players.screen.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/settings.screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const Homescreen(),
    ),
    GoRoute(
      path: "/players",
      builder: (context, state) => const PlayersScreen(),
    ),
    GoRoute(
      path: "/settings",
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: "/game",
      builder: (context, state) => GameScreen(state.extra as Game),
    ),
    GoRoute(
      path: "/history",
      builder: (context, state) => HistoryScreen(),
    ),
  ],
);
