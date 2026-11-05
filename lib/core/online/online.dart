import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darts/core/game/skill_rating.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Online profiles and friends, on Firebase Auth and Firestore.
///
/// Only the phone's owner (local user id 0) goes online; other players saved
/// on the phone stay local. An anonymous account is made the first time the
/// owner opens Friends or a friend's link.
///
/// Firestore layout (rules in `firestore.rules`):
///   profiles/{uid}                    name, code and ratings; any signed-in
///                                     user can read one, nobody can list them
///   codes/{code}                      { uid }: turns a friend code into a uid
///   profiles/{uid}/friends/{uid2}     uid's friends, readable only by uid
///   profiles/{uid}/games/{id}         private backup of the owner's games,
///                                     so ranks survive a reinstall (the iOS
///                                     keychain keeps the sign-in) or, once
///                                     linked to Apple or Google, a new phone
abstract final class Online {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Firebase started; everything here is off until [init] runs.
  static bool available = false;

  /// Debug builds run with `--dart-define=USE_FIREBASE_EMULATORS=true` talk
  /// to the local emulators (`firebase emulators:start`) instead.
  static const _useEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');

  /// Call once after `Firebase.initializeApp()` succeeds.
  static Future<void> init() async {
    if (_useEmulators) {
      await _auth.useAuthEmulator('localhost', 9099);
      _db.useFirestoreEmulator('localhost', 8080);
    }
    available = true;
  }

  static DocumentReference<Map<String, dynamic>> _profile(String uid) =>
      _db.collection('profiles').doc(uid);
  static DocumentReference<Map<String, dynamic>> _code(String code) =>
      _db.collection('codes').doc(code);
  static CollectionReference<Map<String, dynamic>> _friends(String uid) =>
      _profile(uid).collection('friends');
  static CollectionReference<Map<String, dynamic>> _games(String uid) =>
      _profile(uid).collection('games');

  static String? get uid => _auth.currentUser?.uid;

  static var _verified = false;

  /// Signs in anonymously unless already signed in.
  ///
  /// A saved sign-in is checked with the server once per run: if its account
  /// no longer exists (deleted, or made on the emulators by a debug build),
  /// Firestore would retry it forever, so start a fresh account instead.
  static Future<String> signIn() async {
    final current =
        await _savedUser() ?? (await _auth.signInAnonymously()).user!;
    _verified = true;
    return current.uid;
  }

  /// The saved sign-in once checked with the server, or null when there is
  /// none (or its account is gone). Never creates an account.
  static Future<User?> _savedUser() async {
    final current = _auth.currentUser;
    if (current == null || _verified) return current;
    try {
      await current.reload();
    } on FirebaseAuthException catch (e) {
      // The emulators answer a sign-in saved by a live build with an
      // internal error; it's no use to them either.
      final foreign = _useEmulators && e.code == 'internal-error';
      if (!foreign && !_goneAccountCodes.contains(e.code)) rethrow;
      await _auth.signOut();
      return null;
    }
    _verified = true;
    return current;
  }

  /// Republishes the owner's name and ratings if they're already online.
  /// Unlike [ensureProfile], never signs in or creates anything.
  static Future<void> syncIfSignedIn({
    required String name,
    required SkillRating x01,
    required SkillRating cricket,
  }) async {
    if (await _savedUser() case final user?) {
      final doc = await _profile(user.uid).get();
      if (!doc.exists) return;
      if (OnlineProfile.fromDoc(doc).sameAs(name, x01, cricket)) return;
      await publish(name: name, x01: x01, cricket: cricket);
    }
  }

  static const _goneAccountCodes = {
    'user-not-found',
    'user-disabled',
    'user-token-expired',
    'invalid-user-token',
  };

  /// The signed-in owner's profile, created with a fresh friend code the
  /// first time. [name] and the ratings are what to publish right now.
  static Future<OnlineProfile> ensureProfile({
    required String name,
    required SkillRating x01,
    required SkillRating cricket,
  }) async {
    final me = await signIn();
    final existing = await _profile(me).get();
    if (existing.exists) {
      final profile = OnlineProfile.fromDoc(existing);
      return profile.sameAs(name, x01, cricket)
          ? profile
          : await publish(name: name, x01: x01, cricket: cricket);
    }
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = newCode();
      final created = await _db.runTransaction((tx) async {
        if ((await tx.get(_code(code))).exists) return false;
        tx.set(_code(code), {'uid': me});
        tx.set(_profile(me), {
          'name': name,
          'code': code,
          'x01': OnlineRating.of(x01).toMap(),
          'cricket': OnlineRating.of(cricket).toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      });
      if (created) {
        return OnlineProfile(
          uid: me,
          name: name,
          code: code,
          x01: OnlineRating.of(x01),
          cricket: OnlineRating.of(cricket),
        );
      }
    }
    throw StateError('No free friend code after 5 tries');
  }

  /// Pushes the owner's current name and ratings to their profile.
  static Future<OnlineProfile> publish({
    required String name,
    required SkillRating x01,
    required SkillRating cricket,
  }) async {
    final me = uid!;
    await _profile(me).update({
      'name': name,
      'x01': OnlineRating.of(x01).toMap(),
      'cricket': OnlineRating.of(cricket).toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return OnlineProfile.fromDoc(await _profile(me).get());
  }

  static Future<OnlineProfile?> profile(String uid) async {
    final doc = await _profile(uid).get();
    return doc.exists ? OnlineProfile.fromDoc(doc) : null;
  }

  static Future<OnlineProfile?> profileByCode(String code) async {
    final doc = await _code(code).get();
    if (!doc.exists) return null;
    final p = await profile(doc.data()!['uid'] as String);
    // A stale code doc could point at a profile that has moved on.
    return p?.code == code ? p : null;
  }

  /// The owner's friends' uids, live.
  static Stream<Set<String>> friendIds() => _friends(
    uid!,
  ).snapshots().map((s) => {for (final d in s.docs) d.id});

  /// Adds [friend] to the owner's friends and the owner to theirs.
  ///
  /// Friend docs can't be updated, so a half left over from an earlier add
  /// would fail the batch; clear both halves first, then write them fresh.
  static Future<void> addFriend(String friend) async {
    final me = uid!;
    await removeFriend(friend);
    final batch = _db.batch()
      ..set(_friends(me).doc(friend), {
        'addedAt': FieldValue.serverTimestamp(),
      })
      ..set(_friends(friend).doc(me), {
        'addedAt': FieldValue.serverTimestamp(),
      });
    await batch.commit();
  }

  /// Unfriends both ways.
  static Future<void> removeFriend(String friend) async {
    final me = uid!;
    final batch = _db.batch()
      ..delete(_friends(me).doc(friend))
      ..delete(_friends(friend).doc(me));
    await batch.commit();
  }

  // ── Accounts ─────────────────────────────────────────────────────────────

  /// Signed in with Apple or Google, so the account survives a reinstall.
  static bool get isLinked => _auth.currentUser?.isAnonymous == false;

  /// "apple.com" or "google.com" once linked.
  static String? get linkedProvider {
    final providers = _auth.currentUser?.providerData ?? const [];
    return providers.isEmpty ? null : providers.first.providerId;
  }

  /// Ties the owner's anonymous account to Apple or Google.
  ///
  /// When that Apple or Google login already has a DartScore account (an
  /// earlier phone, or a reinstall), the anonymous one is deleted and the
  /// app switches to the existing account: returns [LinkResult.switched], and
  /// the caller restores its games.
  static Future<LinkResult> link(AuthProvider provider) async {
    await signIn();
    final user = _auth.currentUser!;
    try {
      await user.linkWithProvider(provider);
      return LinkResult.linked;
    } on FirebaseAuthException catch (e) {
      final existing = e.credential;
      if (e.code != 'credential-already-in-use' || existing == null) rethrow;
      await _deleteData(user.uid);
      await user.delete();
      await _auth.signInWithCredential(existing);
      return LinkResult.switched;
    }
  }

  /// Removes the owner's profile, friend links (both ways), backups and
  /// Auth account. Games on the phone stay. The next visit to Friends starts
  /// a fresh anonymous account.
  static Future<void> deleteAccount(AuthProvider? reauthWith) async {
    final user = _auth.currentUser;
    if (user == null) return;
    // Apple requires apps to revoke Sign in with Apple when the account is
    // deleted. That takes a fresh authorization code (single-use, valid for
    // minutes), so sign in with Apple once more first; it also counts as the
    // recent login deletion needs.
    if (reauthWith is AppleAuthProvider) {
      final cred = await user.reauthenticateWithProvider(reauthWith);
      final code = cred.additionalUserInfo?.authorizationCode;
      if (code != null) {
        try {
          await _auth.revokeTokenWithAuthorizationCode(code);
        } on FirebaseAuthException catch (e) {
          // Fails until the Apple key (OAuth code flow) is set up in the
          // Firebase console; deleting the account matters more.
          debugPrint('Online: Apple token revoke failed: ${e.code}');
        }
      }
    }
    await _deleteData(user.uid);
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login' || reauthWith == null) rethrow;
      await user.reauthenticateWithProvider(reauthWith);
      await user.delete();
    }
    _verified = false;
  }

  static Future<void> _deleteData(String me) async {
    final refs = <DocumentReference>[];
    for (final f in (await _friends(me).get()).docs) {
      refs
        ..add(_friends(f.id).doc(me))
        ..add(f.reference);
    }
    refs.addAll((await _games(me).get()).docs.map((d) => d.reference));
    final profile = await _profile(me).get();
    if (profile.exists) {
      // Code and profile go together so the code can't point at nothing.
      refs
        ..add(_code(profile.data()!['code'] as String))
        ..add(profile.reference);
    }
    await _commitDeletes(refs);
  }

  // ── Game backup ──────────────────────────────────────────────────────────

  /// One backup doc per game; a game's start time is unique on a phone.
  static String gameId(Game game) => '${game.date.microsecondsSinceEpoch}';

  /// Uploads [games] to the owner's backup, once they're online.
  static Future<void> backUp(Iterable<Game> games) async {
    final me = uid;
    if (me == null || pauseBackup) return;
    final list = games.toList();
    for (var i = 0; i < list.length; i += _batchLimit) {
      final batch = _db.batch();
      for (final g in list.skip(i).take(_batchLimit)) {
        batch.set(_games(me).doc(gameId(g)), {
          'json': jsonEncode(g.toJson()),
          'playedAt': Timestamp.fromDate(g.date),
        });
      }
      await batch.commit();
    }
  }

  /// Set while restored games are merged in, so they aren't uploaded again.
  static var pauseBackup = false;

  static Future<void> deleteBackups(Iterable<String> ids) async {
    final me = uid;
    if (me == null || ids.isEmpty) return;
    await _commitDeletes([for (final id in ids) _games(me).doc(id)]);
  }

  /// Fires when the owner signs in, links Apple or Google, or is deleted.
  static Stream<User?> userChanges() => _auth.userChanges();

  /// Every backed-up game, oldest first; none when not online.
  static Future<List<Game>> backedUpGames() async {
    final user = await _savedUser();
    if (user == null) return const [];
    final docs = (await _games(user.uid).orderBy('playedAt').get()).docs;
    return [
      for (final d in docs)
        Game.fromJson(jsonDecode(d.data()['json'] as String)),
    ];
  }

  static const _batchLimit = 400;

  static Future<void> _commitDeletes(List<DocumentReference> refs) async {
    for (var i = 0; i < refs.length; i += _batchLimit) {
      final batch = _db.batch();
      for (final r in refs.skip(i).take(_batchLimit)) {
        batch.delete(r);
      }
      await batch.commit();
    }
  }

  /// Friend codes avoid characters that are easy to misread: 0/O and 1/I.
  static const _alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  static final _random = Random.secure();

  static String newCode() => String.fromCharCodes([
    for (var i = 0; i < 6; i++)
      _alphabet.codeUnitAt(_random.nextInt(_alphabet.length)),
  ]);

  /// The friend code in a scanned QR or typed text: a profile link
  /// (`…/f/7K2QXP`) or the bare code, any case, spaces and dashes ignored.
  static String? parseCode(String text) {
    final t = text.trim();
    final fromLink = RegExp(r'/f/([A-Za-z0-9]{6})/?$').firstMatch(t)?.group(1);
    final code = (fromLink ?? t).replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
    return RegExp('^[$_alphabet]{6}\$').hasMatch(code) ? code : null;
  }

  /// The link a profile's QR code holds. It opens the app straight to the
  /// profile once app links are set up, and a store page otherwise.
  static String linkFor(String code) => 'https://darts-onoo.web.app/f/$code';

  /// "7K2-QXP": easier to read out than six characters in a row.
  static String display(String code) =>
      '${code.substring(0, 3)}-${code.substring(3)}';
}

enum LinkResult {
  /// The anonymous account now has Apple or Google attached.
  linked,

  /// That login already had an account; the app is now signed in to it.
  switched,
}

/// A published rating: just what friends need to see a rank.
class OnlineRating {
  const OnlineRating({required this.value, required this.games});
  final double? value;
  final int games;

  factory OnlineRating.of(SkillRating r) =>
      OnlineRating(value: r.value, games: r.games);

  factory OnlineRating.fromMap(Object? map) {
    final m = map is Map ? map : const {};
    return OnlineRating(
      value: (m['value'] as num?)?.toDouble(),
      games: (m['games'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object?> toMap() => {'value': value, 'games': games};

  SkillRating toSkill(RatingMode mode) =>
      SkillRating(mode: mode, games: games, value: value);
}

class OnlineProfile {
  const OnlineProfile({
    required this.uid,
    required this.name,
    required this.code,
    required this.x01,
    required this.cricket,
  });

  final String uid;
  final String name;
  final String code;
  final OnlineRating x01;
  final OnlineRating cricket;

  factory OnlineProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return OnlineProfile(
      uid: doc.id,
      name: d['name'] as String? ?? '',
      code: d['code'] as String? ?? '',
      x01: OnlineRating.fromMap(d['x01']),
      cricket: OnlineRating.fromMap(d['cricket']),
    );
  }

  SkillRating rating(RatingMode mode) =>
      mode == RatingMode.x01 ? x01.toSkill(mode) : cricket.toSkill(mode);

  bool sameAs(String name, SkillRating x01, SkillRating cricket) =>
      this.name == name &&
      this.x01.value == x01.value &&
      this.x01.games == x01.games &&
      this.cricket.value == cricket.value &&
      this.cricket.games == cricket.games;
}
