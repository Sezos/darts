import 'dart:ui';

import 'package:darts/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:darts/l10n/app_localizations.dart';

/// The UI languages a player can pick in Settings. [auto] follows the phone.
enum AppLanguage {
  auto(null),
  en(Locale('en')),
  mn(Locale('mn'));

  const AppLanguage(this.locale);

  /// The locale this choice forces, or null to follow the phone.
  final Locale? locale;
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The locale [AppLanguage.auto] picks. English is the app's main language;
/// Mongolian wins when the phone's first usable locale is Mongolian or set
/// to the Mongolia region: iOS has no Mongolian system language, so
/// Mongolian iPhones mostly run English (or Russian) with region MN.
Locale autoLocale(List<Locale> deviceLocales) {
  for (final l in deviceLocales) {
    if (l.languageCode == 'mn' || l.countryCode == 'MN') {
      return const Locale('mn');
    }
    if (l.languageCode == 'en') return const Locale('en');
  }
  return const Locale('en');
}

Locale resolveLocale(AppLanguage language, List<Locale> deviceLocales) =>
    language.locale ?? autoLocale(deviceLocales);

/// Strings for code that runs without a BuildContext, such as the default
/// player names written to storage on first launch.
AppLocalizations l10nFor(AppLanguage language) => lookupAppLocalizations(
  resolveLocale(language, PlatformDispatcher.instance.locales),
);
