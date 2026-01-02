// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
  date: DateTime.parse(json['date'] as String),
  startFrom: (json['startFrom'] as num).toInt(),
  users:
      (json['users'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <User>[],
  rounds:
      (json['rounds'] as List<dynamic>?)
          ?.map((e) => Round.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Round>[],
);

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'startFrom': instance.startFrom,
  'users': instance.users,
  'rounds': instance.rounds,
};

_Round _$RoundFromJson(Map<String, dynamic> json) => _Round(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  dart1: (json['dart1'] as num?)?.toInt(),
  dart2: (json['dart2'] as num?)?.toInt(),
  dart3: (json['dart3'] as num?)?.toInt(),
);

Map<String, dynamic> _$RoundToJson(_Round instance) => <String, dynamic>{
  'user': instance.user,
  'dart1': instance.dart1,
  'dart2': instance.dart2,
  'dart3': instance.dart3,
};

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryNotifier)
final historyProvider = HistoryNotifierProvider._();

final class HistoryNotifierProvider
    extends $NotifierProvider<HistoryNotifier, List<Game>> {
  HistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyNotifierHash();

  @$internal
  @override
  HistoryNotifier create() => HistoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Game> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Game>>(value),
    );
  }
}

String _$historyNotifierHash() => r'fb93d4c8bfb2d05c360dc3eb9ca47b3a53da60d6';

abstract class _$HistoryNotifier extends $Notifier<List<Game>> {
  List<Game> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Game>, List<Game>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Game>, List<Game>>,
              List<Game>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
