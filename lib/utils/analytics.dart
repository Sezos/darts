import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

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

  static Future<void> _property(String name, String value) async {
    if (!_enabled) return;
    try {
      await FirebaseAnalytics.instance.setUserProperty(
        name: name,
        value: value,
      );
    } catch (e) {
      debugPrint('Analytics: property $name failed: $e');
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

  /// Logs a screen view each time [router]'s top route changes, named after
  /// the route's `name`. Dialogs and sheets aren't routes, so they don't count.
  static void trackScreens(GoRouter router) {
    String? last;
    void report() {
      final name =
          router.routerDelegate.currentConfiguration.lastOrNull?.route.name;
      if (name == null || name == last) return;
      last = name;
      screen(name);
    }

    router.routerDelegate.addListener(report);
    report();
  }

  // ── Game events ────────────────────────────────────────────────────────────

  /// [mode] is "x01" or "cricket". [gameType] is the x01 starting score
  /// ("501"), or "cricket".
  static Future<void> gameStarted({
    required String mode,
    required String gameType,
    required int playerCount,
  }) => _log('game_started', {
    'mode': mode,
    'game_type': gameType,
    'player_count': playerCount,
  });

  static Future<void> gameCompleted({
    required String mode,
    required String gameType,
    required int roundsPlayed,
    required bool currentUserWon,
  }) => _log('game_completed', {
    'mode': mode,
    'game_type': gameType,
    'rounds_played': roundsPlayed,
    'user_won': currentUserWon ? 1 : 0,
  });

  /// A game closed before it finished. It stays saved, so it can be resumed
  /// from the home screen.
  static Future<void> gameLeft({
    required String mode,
    required String gameType,
    required int roundsPlayed,
    required int playerCount,
  }) => _log('game_left', {
    'mode': mode,
    'game_type': gameType,
    'rounds_played': roundsPlayed,
    'player_count': playerCount,
  });

  static Future<void> gameResumed({
    required String mode,
    required String gameType,
  }) => _log('game_resumed', {'mode': mode, 'game_type': gameType});

  /// The saved unfinished game was thrown away from the home screen.
  static Future<void> gameDiscarded() => _log('game_discarded');

  static Future<void> bust() => _log('bust');

  static Future<void> checkoutSuggestionShown({required int score}) =>
      _log('checkout_suggestion_shown', {'score': score});

  // ── App events ─────────────────────────────────────────────────────────────

  static Future<void> ratingPromptShown() => _log('rating_prompt_shown');

  /// [setting] is "sound", "haptic", "double_out" or "language"; [value] is
  /// "on"/"off", or the language picked ("auto", "en", "mn").
  static Future<void> settingChanged(String setting, String value) =>
      _log('setting_changed', {'setting': setting, 'value': value});

  static Future<void> adImpression(String adUnit) =>
      _log('ad_impression', {'ad_unit': adUnit});

  /// [code] is the AdMob error code; 3 means no ad was available (no fill).
  static Future<void> adFailedToLoad(String adUnit, int code) =>
      _log('ad_failed_to_load', {'ad_unit': adUnit, 'error_code': code});

  // ── Friends ────────────────────────────────────────────────────────────────

  static Future<void> qrShown() => _log('qr_shown');
  static Future<void> qrScanned() => _log('qr_scanned');
  static Future<void> friendCodeEntered() => _log('friend_code_entered');
  static Future<void> friendProfileViewed() => _log('friend_profile_viewed');
  static Future<void> friendAdded() => _log('friend_added');
  static Future<void> friendRemoved() => _log('friend_removed');

  // ── User properties ────────────────────────────────────────────────────────

  /// [languageSetting] is the Settings choice ("auto", "en", "mn");
  /// [appLanguage] is what the UI actually shows ("en" or "mn").
  static Future<void> settingsProperties({
    required String languageSetting,
    required String appLanguage,
    required bool doubleOut,
  }) async {
    await _property('language_setting', languageSetting);
    await _property('app_language', appLanguage);
    await _property('double_out', doubleOut ? 'on' : 'off');
  }

  static Future<void> savedPlayers(int count) =>
      _property('saved_players', '$count');
}
