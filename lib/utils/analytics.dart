import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Wrapper around FirebaseAnalytics.
/// All event tracking goes through here so it's easy to find and update.
///
/// Every call is a no-op until [enable] runs, which `main` does only after
/// `Firebase.initializeApp()` succeeds. Touching `FirebaseAnalytics.instance`
/// without a Firebase app throws, so nothing here may reach it early.
class Analytics {
  static bool _enabled = false;
  static bool get isEnabled => _enabled;

  static void enable() => _enabled = true;

  static Future<void> _log(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    if (!_enabled) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Analytics: $name failed: $e');
    }
  }

  // ── Screen tracking ────────────────────────────────────────────────────────

  static Future<void> screen(String name) async {
    if (!_enabled) return;
    try {
      await FirebaseAnalytics.instance.logScreenView(screenName: name);
    } catch (e) {
      debugPrint('Analytics: screen $name failed: $e');
    }
  }

  // ── Game events ────────────────────────────────────────────────────────────

  static Future<void> gameStarted({
    required int gameType,
    required int playerCount,
  }) => _log('game_started', {
    'game_type': gameType.toString(),
    'player_count': playerCount,
  });

  static Future<void> gameCompleted({
    required int gameType,
    required int roundsPlayed,
    required bool currentUserWon,
  }) => _log('game_completed', {
    'game_type': gameType.toString(),
    'rounds_played': roundsPlayed,
    'user_won': currentUserWon ? 1 : 0,
  });

  static Future<void> bust() => _log('bust');

  static Future<void> checkoutSuggestionShown({required int score}) =>
      _log('checkout_suggestion_shown', {'score': score});

  // ── App events ─────────────────────────────────────────────────────────────

  static Future<void> ratingPromptShown() => _log('rating_prompt_shown');

  static Future<void> adImpression(String adUnit) =>
      _log('ad_impression', {'ad_unit': adUnit});
}
