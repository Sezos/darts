// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'players.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayersNotifier)
final playersProvider = PlayersNotifierProvider._();

final class PlayersNotifierProvider
    extends $NotifierProvider<PlayersNotifier, List<User>> {
  PlayersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playersNotifierHash();

  @$internal
  @override
  PlayersNotifier create() => PlayersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<User> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<User>>(value),
    );
  }
}

String _$playersNotifierHash() => r'73df1c1a991c52bffd1d0ba594d02655a2885695';

abstract class _$PlayersNotifier extends $Notifier<List<User>> {
  List<User> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<User>, List<User>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<User>, List<User>>,
              List<User>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
