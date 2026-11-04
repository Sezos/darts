import 'dart:convert';

import 'package:darts/core/online/online.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCode', () {
    test('reads a profile link', () {
      expect(
        Online.parseCode('https://darts-onoo.web.app/f/7K2QXP'),
        '7K2QXP',
      );
      expect(
        Online.parseCode('https://darts-onoo.web.app/f/7k2qxp/'),
        '7K2QXP',
      );
    });

    test('reads a typed code in any case, with spaces or a dash', () {
      expect(Online.parseCode('7k2-qxp'), '7K2QXP');
      expect(Online.parseCode(' 7K2 QXP '), '7K2QXP');
    });

    test('rejects anything else', () {
      expect(Online.parseCode('https://example.com'), isNull);
      expect(Online.parseCode('7K2QX'), isNull);
      // 0, O, 1 and I are never used in codes.
      expect(Online.parseCode('7K2Q0P'), isNull);
      expect(Online.parseCode('7K2QIP'), isNull);
    });
  });

  test('new codes are six characters from the code alphabet', () {
    for (var i = 0; i < 200; i++) {
      final code = Online.newCode();
      expect(Online.parseCode(code), code);
    }
  });

  test('display splits a code in two', () {
    expect(Online.display('7K2QXP'), '7K2-QXP');
    expect(Online.linkFor('7K2QXP'), 'https://darts-onoo.web.app/f/7K2QXP');
  });

  test('a game survives the backup round trip', () {
    final a = User(id: 0, name: 'A');
    final b = User(id: 1700000000000, name: 'B');
    final game = Game(
      date: DateTime(2026, 11, 5, 20, 15, 30, 123, 456),
      startFrom: 0,
      mode: GameMode.cricket,
      users: [a, b],
      rounds: [
        Round(user: a, dart1: 20, mult1: 3, dart2: 0, dart3: 19, mult3: 2),
        Round(user: b, dart1: 0, dart2: 0, dart3: 0),
      ],
    );
    final back = Game.fromJson(jsonDecode(jsonEncode(game.toJson())));
    expect(Online.gameId(back), Online.gameId(game));
    expect(back.mode, GameMode.cricket);
    expect(back.users.map((u) => u.id), [0, 1700000000000]);
    expect(back.rounds.first.mults, [3, null, 2]);
    expect(back.rounds.last.darts, [0, 0, 0]);
  });
}
