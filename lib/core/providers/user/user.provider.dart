import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.provider.g.dart';
part 'user.provider.freezed.dart';

@unfreezed
abstract class User with _$User {
  factory User({
    required int id,
    required String name,
    @Default(0) int ppd, //Point per Dart
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@riverpod
class UserNotifier extends _$UserNotifier {
  String key = "user";

  @override
  User build() {
    if (storage.read(key) != null) {
      return User.fromJson(storage.read(key));
    }
    return User(id: 0, name: "Player 1");
  }

  User updateUser({String? name, int? ppd}) {
    var user = state;

    state = user.copyWith(
      name: name ?? state.name,
      ppd: ppd ?? state.ppd,
    );

    storage.write(key, state.toJson());

    return state;
  }
}

final storage = GetStorage();
