import 'package:darts/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveLocale', () {
    Locale auto(List<Locale> device) => resolveLocale(AppLanguage.auto, device);

    test('auto: Mongolian phone gets Mongolian', () {
      expect(auto([const Locale('mn', 'MN')]), const Locale('mn'));
    });

    test('auto: English iPhone in the Mongolia region gets Mongolian', () {
      expect(auto([const Locale('en', 'MN')]), const Locale('mn'));
    });

    test('auto: Russian phone in Mongolia gets Mongolian', () {
      expect(auto([const Locale('ru', 'MN')]), const Locale('mn'));
    });

    test('auto: English elsewhere gets English', () {
      expect(auto([const Locale('en', 'US')]), const Locale('en'));
    });

    test('auto: first usable locale wins', () {
      expect(
        auto([const Locale('en', 'GB'), const Locale('mn')]),
        const Locale('en'),
      );
      expect(
        auto([const Locale('de', 'DE'), const Locale('mn')]),
        const Locale('mn'),
      );
    });

    test('auto: unsupported languages fall back to English', () {
      expect(auto([const Locale('ko', 'KR')]), const Locale('en'));
      expect(auto(const []), const Locale('en'));
    });

    test('a picked language ignores the phone', () {
      expect(
        resolveLocale(AppLanguage.en, [const Locale('mn', 'MN')]),
        const Locale('en'),
      );
      expect(
        resolveLocale(AppLanguage.mn, [const Locale('en', 'US')]),
        const Locale('mn'),
      );
    });
  });

  test('both languages load, with plurals', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final mn = lookupAppLocalizations(const Locale('mn'));
    expect(en.appName, 'DartScore');
    expect(mn.appName, 'Дартсны оноо');
    expect(en.gamesCount(1), '1 game');
    expect(en.gamesCount(3), '3 games');
    expect(mn.gamesCount(3), '3 тоглолт');
  });
}
