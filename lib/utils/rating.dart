import 'package:darts/utils/analytics.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_review/in_app_review.dart';

/// Shows the native iOS/Android rating dialog at the right moment.
/// Rules:
///   - First prompt: after the 3rd completed game
///   - Second prompt: after the 10th completed game
///   - Never again after that (iOS enforces its own 3x/year limit anyway)
class RatingService {
  static const _key = 'games_completed_count';
  static final _storage = GetStorage();
  static final _review = InAppReview.instance;

  /// Call this every time a game finishes.
  static Future<void> onGameCompleted() async {
    final count = (_storage.read<int>(_key) ?? 0) + 1;
    _storage.write(_key, count);

    if (count == 3 || count == 10) {
      await _maybeShow();
    }
  }

  static Future<void> _maybeShow() async {
    if (await _review.isAvailable()) {
      await _review.requestReview();
      Analytics.ratingPromptShown();
    }
  }
}
