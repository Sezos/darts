import 'package:darts/core/game.screen.dart';
import 'package:darts/core/history.screen.dart';
import 'package:darts/core/homescreen.dart';
import 'package:darts/core/online/friend_profile.screen.dart';
import 'package:darts/core/online/friends.screen.dart';
import 'package:darts/core/online/scan.screen.dart';
import 'package:darts/core/players.screen.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/game/ongoing_game.provider.dart';
import 'package:darts/core/ranks.screen.dart';
import 'package:darts/core/settings.screen.dart';
import 'package:darts/core/stats.screen.dart';
import 'package:darts/core/tabs.dart';
import 'package:darts/utils/glass.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/",
  observers: glassRouteObservers(),
  // Firebase Auth's Google sign-in returns through the app's URL scheme
  // (`app-1-…://firebaseauth/link?…`). Flutter hands that link to the router
  // too, but Firebase has already handled it: stay where we are.
  onEnter: (context, current, next, router) =>
      next.uri.host == 'firebaseauth' ? const Block.stop() : const Allow(),
  routes: [
    // The tabs, in the order of the tab bar (see tabs.dart).
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppTabs(shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/",
              name: "home",
              builder: (context, state) => const Homescreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/ranks",
              name: "ranks",
              builder: (context, state) => const RanksScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/friends",
              name: "friends",
              builder: (context, state) => const FriendsScreen(),
              routes: [
                GoRoute(
                  path: "scan",
                  name: "scan",
                  builder: (context, state) => const ScanScreen(),
                ),
                GoRoute(
                  path: "f/:code",
                  name: "friend_profile",
                  builder: (context, state) => FriendProfileScreen(
                    state.pathParameters['code']!.toUpperCase(),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/history",
              name: "history",
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/settings",
              name: "settings",
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Full-screen, above the tab bar.
    GoRoute(
      path: "/players",
      name: "players",
      builder: (context, state) => const PlayersScreen(),
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

    // Profile links (`https://darts-onoo.web.app/f/7K2QXP`) open in the
    // Friends tab, with the friends list behind them.
    GoRoute(
      path: "/f/:code",
      redirect: (context, state) =>
          "/friends/f/${state.pathParameters['code']}",
    ),
  ],
);
