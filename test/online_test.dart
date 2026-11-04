import 'package:darts/core/online/online.dart';
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
}
