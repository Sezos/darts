import 'package:darts/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

class AppSettings {
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool doubleOutRequired;
  final AppLanguage language;

  const AppSettings({
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.doubleOutRequired = true,
    this.language = AppLanguage.auto,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? doubleOutRequired,
    AppLanguage? language,
  }) => AppSettings(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    doubleOutRequired: doubleOutRequired ?? this.doubleOutRequired,
    language: language ?? this.language,
  );

  Map<String, dynamic> toJson() => {
    'soundEnabled': soundEnabled,
    'hapticEnabled': hapticEnabled,
    'doubleOutRequired': doubleOutRequired,
    'language': language.name,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    soundEnabled: json['soundEnabled'] as bool? ?? true,
    hapticEnabled: json['hapticEnabled'] as bool? ?? true,
    doubleOutRequired: json['doubleOutRequired'] as bool? ?? true,
    language:
        AppLanguage.values.asNameMap()[json['language']] ?? AppLanguage.auto,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'app_settings';
  final _storage = GetStorage();

  /// Installs from before English was added were Mongolian-only; pin them to Mongolian
  /// so the update doesn't switch their app to English. Call once after
  /// `GetStorage.init()`, before anything writes to storage.
  static void keepMongolianForExistingInstalls() {
    final storage = GetStorage();
    if (storage.getKeys().isEmpty) return;
    final saved = storage.read(_key);
    final json = saved == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(saved as Map);
    if (json.containsKey('language')) return;
    json['language'] = AppLanguage.mn.name;
    storage.write(_key, json);
  }

  @override
  AppSettings build() {
    final saved = _storage.read(_key);
    if (saved != null) {
      return AppSettings.fromJson(Map<String, dynamic>.from(saved as Map));
    }
    return const AppSettings();
  }

  void toggleSound() =>
      _update(state.copyWith(soundEnabled: !state.soundEnabled));
  void toggleHaptic() =>
      _update(state.copyWith(hapticEnabled: !state.hapticEnabled));
  void toggleDoubleOut() =>
      _update(state.copyWith(doubleOutRequired: !state.doubleOutRequired));
  void setLanguage(AppLanguage language) =>
      _update(state.copyWith(language: language));

  void _update(AppSettings s) {
    state = s;
    _storage.write(_key, s.toJson());
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
