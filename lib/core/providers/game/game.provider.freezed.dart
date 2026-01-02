// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Game {

 DateTime get date; set date(DateTime value); int get startFrom; set startFrom(int value); List<User> get users; set users(List<User> value); List<Round> get rounds; set rounds(List<Round> value);
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  return 'Game(date: $date, startFrom: $startFrom, users: $users, rounds: $rounds)';
}


}

/// @nodoc
abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
 DateTime date, int startFrom, List<User> users, List<Round> rounds
});




}
/// @nodoc
class _$GameCopyWithImpl<$Res>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? startFrom = null,Object? users = null,Object? rounds = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startFrom: null == startFrom ? _self.startFrom : startFrom // ignore: cast_nullable_to_non_nullable
as int,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<User>,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as List<Round>,
  ));
}

}


/// Adds pattern-matching-related methods to [Game].
extension GamePatterns on Game {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Game value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Game value)  $default,){
final _that = this;
switch (_that) {
case _Game():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Game value)?  $default,){
final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int startFrom,  List<User> users,  List<Round> rounds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.date,_that.startFrom,_that.users,_that.rounds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int startFrom,  List<User> users,  List<Round> rounds)  $default,) {final _that = this;
switch (_that) {
case _Game():
return $default(_that.date,_that.startFrom,_that.users,_that.rounds);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int startFrom,  List<User> users,  List<Round> rounds)?  $default,) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.date,_that.startFrom,_that.users,_that.rounds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Game implements Game {
   _Game({required this.date, required this.startFrom, this.users = const <User>[], this.rounds = const <Round>[]});
  factory _Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

@override  DateTime date;
@override  int startFrom;
@override@JsonKey()  List<User> users;
@override@JsonKey()  List<Round> rounds;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameCopyWith<_Game> get copyWith => __$GameCopyWithImpl<_Game>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameToJson(this, );
}



@override
String toString() {
  return 'Game(date: $date, startFrom: $startFrom, users: $users, rounds: $rounds)';
}


}

/// @nodoc
abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) = __$GameCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int startFrom, List<User> users, List<Round> rounds
});




}
/// @nodoc
class __$GameCopyWithImpl<$Res>
    implements _$GameCopyWith<$Res> {
  __$GameCopyWithImpl(this._self, this._then);

  final _Game _self;
  final $Res Function(_Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? startFrom = null,Object? users = null,Object? rounds = null,}) {
  return _then(_Game(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startFrom: null == startFrom ? _self.startFrom : startFrom // ignore: cast_nullable_to_non_nullable
as int,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<User>,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as List<Round>,
  ));
}


}


/// @nodoc
mixin _$Round {

 User get user; set user(User value); int? get dart1; set dart1(int? value); int? get dart2; set dart2(int? value); int? get dart3; set dart3(int? value);
/// Create a copy of Round
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoundCopyWith<Round> get copyWith => _$RoundCopyWithImpl<Round>(this as Round, _$identity);

  /// Serializes this Round to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  return 'Round(user: $user, dart1: $dart1, dart2: $dart2, dart3: $dart3)';
}


}

/// @nodoc
abstract mixin class $RoundCopyWith<$Res>  {
  factory $RoundCopyWith(Round value, $Res Function(Round) _then) = _$RoundCopyWithImpl;
@useResult
$Res call({
 User user, int? dart1, int? dart2, int? dart3
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$RoundCopyWithImpl<$Res>
    implements $RoundCopyWith<$Res> {
  _$RoundCopyWithImpl(this._self, this._then);

  final Round _self;
  final $Res Function(Round) _then;

/// Create a copy of Round
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? dart1 = freezed,Object? dart2 = freezed,Object? dart3 = freezed,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,dart1: freezed == dart1 ? _self.dart1 : dart1 // ignore: cast_nullable_to_non_nullable
as int?,dart2: freezed == dart2 ? _self.dart2 : dart2 // ignore: cast_nullable_to_non_nullable
as int?,dart3: freezed == dart3 ? _self.dart3 : dart3 // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of Round
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [Round].
extension RoundPatterns on Round {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Round value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Round() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Round value)  $default,){
final _that = this;
switch (_that) {
case _Round():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Round value)?  $default,){
final _that = this;
switch (_that) {
case _Round() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User user,  int? dart1,  int? dart2,  int? dart3)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Round() when $default != null:
return $default(_that.user,_that.dart1,_that.dart2,_that.dart3);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User user,  int? dart1,  int? dart2,  int? dart3)  $default,) {final _that = this;
switch (_that) {
case _Round():
return $default(_that.user,_that.dart1,_that.dart2,_that.dart3);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User user,  int? dart1,  int? dart2,  int? dart3)?  $default,) {final _that = this;
switch (_that) {
case _Round() when $default != null:
return $default(_that.user,_that.dart1,_that.dart2,_that.dart3);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Round implements Round {
   _Round({required this.user, this.dart1, this.dart2, this.dart3});
  factory _Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);

@override  User user;
@override  int? dart1;
@override  int? dart2;
@override  int? dart3;

/// Create a copy of Round
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoundCopyWith<_Round> get copyWith => __$RoundCopyWithImpl<_Round>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoundToJson(this, );
}



@override
String toString() {
  return 'Round(user: $user, dart1: $dart1, dart2: $dart2, dart3: $dart3)';
}


}

/// @nodoc
abstract mixin class _$RoundCopyWith<$Res> implements $RoundCopyWith<$Res> {
  factory _$RoundCopyWith(_Round value, $Res Function(_Round) _then) = __$RoundCopyWithImpl;
@override @useResult
$Res call({
 User user, int? dart1, int? dart2, int? dart3
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$RoundCopyWithImpl<$Res>
    implements _$RoundCopyWith<$Res> {
  __$RoundCopyWithImpl(this._self, this._then);

  final _Round _self;
  final $Res Function(_Round) _then;

/// Create a copy of Round
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? dart1 = freezed,Object? dart2 = freezed,Object? dart3 = freezed,}) {
  return _then(_Round(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,dart1: freezed == dart1 ? _self.dart1 : dart1 // ignore: cast_nullable_to_non_nullable
as int?,dart2: freezed == dart2 ? _self.dart2 : dart2 // ignore: cast_nullable_to_non_nullable
as int?,dart3: freezed == dart3 ? _self.dart3 : dart3 // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of Round
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
