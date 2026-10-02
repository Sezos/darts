import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

class AppSettings {
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool doubleOutRequired;

  const AppSettings({
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.doubleOutRequired = true,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? doubleOutRequired,
  }) =>
      AppSettings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticEnabled: hapticEnabled ?? this.hapticEnabled,
        doubleOutRequired: doubleOutRequired ?? this.doubleOutRequired,
      );

  Map<String, dynamic> toJson() => {
        'soundEnabled': soundEnabled,
        'hapticEnabled': hapticEnabled,
        'doubleOutRequired': doubleOutRequired,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        hapticEnabled: json['hapticEnabled'] as bool? ?? true,
        doubleOutRequired: json['doubleOutRequired'] as bool? ?? true,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'app_settings';
  final _storage = GetStorage();

  @override
  AppSettings build() {
    final saved = _storage.read(_key);
    if (saved != null) {
      return AppSettings.fromJson(Map<String, dynamic>.from(saved as Map));
    }
    return const AppSettings();
  }

  void toggleSound() => _update(state.copyWith(soundEnabled: !state.soundEnabled));
  void toggleHaptic() => _update(state.copyWith(hapticEnabled: !state.hapticEnabled));
  void toggleDoubleOut() =>
      _update(state.copyWith(doubleOutRequired: !state.doubleOutRequired));

  void _update(AppSettings s) {
    state = s;
    _storage.write(_key, s.toJson());
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
