import 'package:darts/core/game/skill_rating.dart';
import 'package:darts/core/online/online.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/players/players.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

/// The owner's profile, signing in and creating it on first use. Lives only
/// while a Friends screen uses it, and republishes when the owner's name or
/// games change meanwhile.
final myProfileProvider = FutureProvider.autoDispose<OnlineProfile>((ref) {
  final user = ref.watch(userProvider);
  final history = ref.watch(historyProvider);
  return Online.ensureProfile(
    name: user.name,
    x01: skillRating(history, user.id, RatingMode.x01),
    cricket: skillRating(history, user.id, RatingMode.cricket),
  );
});

/// Keeps an online owner's published ratings and game backup in step with
/// the phone. On launch it first merges the backup both ways: after a
/// reinstall the sign-in survives in the iOS keychain while the phone's games
/// don't, and publishing before the restore would wipe the owner's rank.
/// Never signs in by itself: nothing goes online until the owner opens
/// Friends. `MyApp` watches it.
final profileSyncProvider = Provider<void>((ref) {
  if (!Online.available) return;
  var ready = false;
  void publish() {
    if (!ready) return;
    final user = ref.read(userProvider);
    final history = ref.read(historyProvider);
    Online.syncIfSignedIn(
      name: user.name,
      x01: skillRating(history, user.id, RatingMode.x01),
      cricket: skillRating(history, user.id, RatingMode.cricket),
    ).ignore();
  }

  ref.listen(historyProvider, (prev, next) {
    publish();
    if (!ready || prev == null) return;
    final before = {for (final g in prev) Online.gameId(g)};
    final after = {for (final g in next) Online.gameId(g)};
    Online.backUp(
      next.where((g) => !before.contains(Online.gameId(g))),
    ).ignore();
    Online.deleteBackups(before.difference(after)).ignore();
  });
  ref.listen(userProvider, (_, _) => publish());

  () async {
    try {
      if (Online.uid != null) await _syncBackup(ref.read);
    } catch (_) {
      // Offline or signed out elsewhere: the next launch tries again.
    } finally {
      ready = true;
      publish();
    }
  }();
});

/// Two-way merge of the phone's games with the online backup: brings
/// backed-up games and their players onto the phone, then uploads the
/// phone's games the backup lacks.
Future<void> _syncBackup(T Function<T>(ProviderListenable<T>) read) async {
  final remote = await Online.backedUpGames();
  final remoteIds = {for (final g in remote) Online.gameId(g)};
  Online.pauseBackup = true;
  try {
    read(historyProvider.notifier).mergeBackup(remote);
    final players = read(playersProvider.notifier);
    final known = {for (final p in read(playersProvider)) p.id};
    for (final g in remote) {
      for (final u in g.users) {
        if (u.id != 0 && known.add(u.id)) players.addPlayer(u);
      }
    }
  } finally {
    Online.pauseBackup = false;
  }
  await Online.backUp([
    for (final g in read(historyProvider))
      if (!remoteIds.contains(Online.gameId(g))) g,
  ]);
}

/// The signed-in Firebase user, live: changes when Apple or Google is linked.
final authUserProvider = StreamProvider<fb.User?>(
  (ref) => Online.userChanges(),
);

/// Signs the owner in with Apple or Google so their account survives a new
/// phone, then merges the phone's games with that account's backup: switching
/// to an existing account brings its games and players onto this phone.
///
/// Takes the [ProviderContainer] rather than a widget's ref: the sign-in
/// sheet can outlive the screen that opened it.
Future<LinkResult> linkAccount(
  ProviderContainer ref,
  fb.AuthProvider provider,
) async {
  final result = await Online.link(provider);
  await _syncBackup(ref.read);
  if (result == LinkResult.switched) {
    Analytics.accountSwitched();
  } else {
    Analytics.accountLinked(provider.providerId);
  }
  ref.invalidate(myProfileProvider);
  ref.invalidate(friendsProvider);
  return result;
}

/// Deletes the owner's online account. Nothing goes online again until they
/// next open Friends.
Future<void> deleteOnlineAccount(ProviderContainer ref) async {
  await Online.deleteAccount(switch (Online.linkedProvider) {
    'apple.com' => fb.AppleAuthProvider(),
    'google.com' => fb.GoogleAuthProvider(),
    _ => null,
  });
  Analytics.accountDeleted();
  ref.invalidate(myProfileProvider);
  ref.invalidate(friendsProvider);
}

/// The owner's friends' profiles, refetched when the friend list changes.
final friendsProvider = StreamProvider.autoDispose<List<OnlineProfile>>((
  ref,
) async* {
  await ref.watch(myProfileProvider.future);
  await for (final ids in Online.friendIds()) {
    final profiles = await Future.wait(ids.map(Online.profile));
    yield profiles.nonNulls.toList();
  }
});

/// Someone's profile by friend code, for a scanned QR or opened link.
final profileByCodeProvider = FutureProvider.autoDispose
    .family<OnlineProfile?, String>((
      ref,
      code,
    ) async {
      await ref.watch(myProfileProvider.future);
      return Online.profileByCode(code);
    });
