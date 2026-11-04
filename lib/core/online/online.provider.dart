import 'package:darts/core/game/skill_rating.dart';
import 'package:darts/core/online/online.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The owner's profile, signing in and creating it on first use. Re-runs,
/// and republishes, when their name or games change.
final myProfileProvider = FutureProvider<OnlineProfile>((ref) {
  final user = ref.watch(userProvider);
  final history = ref.watch(historyProvider);
  return Online.ensureProfile(
    name: user.name,
    x01: skillRating(history, user.id, RatingMode.x01),
    cricket: skillRating(history, user.id, RatingMode.cricket),
  );
});

/// Keeps the owner's published ratings current after every game, once they
/// have gone online, by keeping [myProfileProvider] alive. `MyApp` watches
/// it. Before the first sign-in nothing goes online.
final profileSyncProvider = Provider<void>((ref) {
  if (Online.available && Online.uid != null) ref.watch(myProfileProvider);
});

/// The owner's friends' profiles, refetched when the friend list changes.
final friendsProvider = StreamProvider<List<OnlineProfile>>((ref) async* {
  await ref.watch(myProfileProvider.future);
  await for (final ids in Online.friendIds()) {
    final profiles = await Future.wait(ids.map(Online.profile));
    yield profiles.nonNulls.toList();
  }
});

/// Someone's profile by friend code, for a scanned QR or opened link.
final profileByCodeProvider = FutureProvider.family<OnlineProfile?, String>((
  ref,
  code,
) async {
  await ref.watch(myProfileProvider.future);
  return Online.profileByCode(code);
});
