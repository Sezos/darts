import 'dart:convert';

import 'package:darts/core/providers/game/game.provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

/// A game that was left before anyone checked out.
class OngoingGame {
  const OngoingGame(this.game, this.current);
  final Game game;

  /// The round in progress when the game was saved.
  final Round current;
}

/// Keeps the in-progress game on disk so leaving the game screen, or the OS
/// killing the app, doesn't lose it.
class OngoingGameNotifier extends Notifier<OngoingGame?> {
  static const _key = 'ongoing_game';
  final _storage = GetStorage();

  @override
  OngoingGame? build() {
    final saved = _storage.read(_key);
    if (saved == null) return null;
    try {
      final map = Map<String, dynamic>.from(saved as Map);
      return OngoingGame(
        Game.fromJson(Map<String, dynamic>.from(map['game'] as Map)),
        Round.fromJson(Map<String, dynamic>.from(map['current'] as Map)),
      );
    } catch (e) {
      debugPrint('Discarding unreadable ongoing game: $e');
      _storage.remove(_key);
      return null;
    }
  }

  void save(Game game, Round current) {
    state = OngoingGame(game, current);
    // Round-trip through JSON so storage holds plain maps, not model objects.
    _storage.write(
      _key,
      jsonDecode(jsonEncode({'game': game, 'current': current})),
    );
  }

  void clear() {
    state = null;
    _storage.remove(_key);
  }
}

final ongoingGameProvider = NotifierProvider<OngoingGameNotifier, OngoingGame?>(
  OngoingGameNotifier.new,
);
