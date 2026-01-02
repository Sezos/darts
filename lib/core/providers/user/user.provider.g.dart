// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  ppd: (json['ppd'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ppd': instance.ppd,
};

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserNotifier)
final userProvider = UserNotifierProvider._();

final class UserNotifierProvider extends $NotifierProvider<UserNotifier, User> {
  UserNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userNotifierHash();

  @$internal
  @override
  UserNotifier create() => UserNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User>(value),
    );
  }
}

String _$userNotifierHash() => r'f640d4780c2d9b37709718b070544a23560e4f28';

abstract class _$UserNotifier extends $Notifier<User> {
  User build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<User, User>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<User, User>,
              User,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
