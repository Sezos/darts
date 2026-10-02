import 'package:firebase_analytics/firebase_analytics.dart';

/// Wrapper around FirebaseAnalytics.
/// All event tracking goes through here so it's easy to find and update.
class Analytics {
  static final _fa = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _fa);

  // ── Screen tracking ────────────────────────────────────────────────────────

  static Future<void> screen(String name) =>
      _fa.logScreenView(screenName: name);

  // ── Game events ────────────────────────────────────────────────────────────

  static Future<void> gameStarted({
    required int gameType,
    required int playerCount,
  }) =>
      _fa.logEvent(
        name: 'game_started',
        parameters: {
          'game_type': gameType.toString(),
          'player_count': playerCount,
        },
      );

  static Future<void> gameCompleted({
    required int gameType,
    required int roundsPlayed,
    required bool currentUserWon,
  }) =>
      _fa.logEvent(
        name: 'game_completed',
        parameters: {
          'game_type': gameType.toString(),
          'rounds_played': roundsPlayed,
          'user_won': currentUserWon ? 1 : 0,
        },
      );

  static Future<void> bust() => _fa.logEvent(name: 'bust');

  static Future<void> checkoutSuggestionShown({required int score}) =>
      _fa.logEvent(
        name: 'checkout_suggestion_shown',
        parameters: {'score': score},
      );

  // ── App events ─────────────────────────────────────────────────────────────

  static Future<void> ratingPromptShown() =>
      _fa.logEvent(name: 'rating_prompt_shown');

  static Future<void> adImpression(String adUnit) =>
      _fa.logEvent(name: 'ad_impression', parameters: {'ad_unit': adUnit});
}
