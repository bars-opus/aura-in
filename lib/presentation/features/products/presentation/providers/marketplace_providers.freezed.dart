// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MarketplaceFilterState {
  String? get category => throw _privateConstructorUsedError;
  SortOption get sortBy => throw _privateConstructorUsedError;
  double? get minPrice => throw _privateConstructorUsedError;
  double? get maxPrice => throw _privateConstructorUsedError;
  bool get showVerifiedOnly => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;

  /// Create a copy of MarketplaceFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketplaceFilterStateCopyWith<MarketplaceFilterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketplaceFilterStateCopyWith<$Res> {
  factory $MarketplaceFilterStateCopyWith(MarketplaceFilterState value,
          $Res Function(MarketplaceFilterState) then) =
      _$MarketplaceFilterStateCopyWithImpl<$Res, MarketplaceFilterState>;
  @useResult
  $Res call(
      {String? category,
      SortOption sortBy,
      double? minPrice,
      double? maxPrice,
      bool showVerifiedOnly,
      int page,
      int limit});
}

/// @nodoc
class _$MarketplaceFilterStateCopyWithImpl<$Res,
        $Val extends MarketplaceFilterState>
    implements $MarketplaceFilterStateCopyWith<$Res> {
  _$MarketplaceFilterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketplaceFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = freezed,
    Object? sortBy = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? showVerifiedOnly = null,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(_value.copyWith(
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortOption,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      showVerifiedOnly: null == showVerifiedOnly
          ? _value.showVerifiedOnly
          : showVerifiedOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MarketplaceFilterStateImplCopyWith<$Res>
    implements $MarketplaceFilterStateCopyWith<$Res> {
  factory _$$MarketplaceFilterStateImplCopyWith(
          _$MarketplaceFilterStateImpl value,
          $Res Function(_$MarketplaceFilterStateImpl) then) =
      __$$MarketplaceFilterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? category,
      SortOption sortBy,
      double? minPrice,
      double? maxPrice,
      bool showVerifiedOnly,
      int page,
      int limit});
}

/// @nodoc
class __$$MarketplaceFilterStateImplCopyWithImpl<$Res>
    extends _$MarketplaceFilterStateCopyWithImpl<$Res,
        _$MarketplaceFilterStateImpl>
    implements _$$MarketplaceFilterStateImplCopyWith<$Res> {
  __$$MarketplaceFilterStateImplCopyWithImpl(
      _$MarketplaceFilterStateImpl _value,
      $Res Function(_$MarketplaceFilterStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = freezed,
    Object? sortBy = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? showVerifiedOnly = null,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(_$MarketplaceFilterStateImpl(
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortOption,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      showVerifiedOnly: null == showVerifiedOnly
          ? _value.showVerifiedOnly
          : showVerifiedOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MarketplaceFilterStateImpl implements _MarketplaceFilterState {
  const _$MarketplaceFilterStateImpl(
      {this.category = null,
      this.sortBy = SortOption.recent,
      this.minPrice = null,
      this.maxPrice = null,
      this.showVerifiedOnly = false,
      this.page = 0,
      this.limit = 20});

  @override
  @JsonKey()
  final String? category;
  @override
  @JsonKey()
  final SortOption sortBy;
  @override
  @JsonKey()
  final double? minPrice;
  @override
  @JsonKey()
  final double? maxPrice;
  @override
  @JsonKey()
  final bool showVerifiedOnly;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;

  @override
  String toString() {
    return 'MarketplaceFilterState(category: $category, sortBy: $sortBy, minPrice: $minPrice, maxPrice: $maxPrice, showVerifiedOnly: $showVerifiedOnly, page: $page, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketplaceFilterStateImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.showVerifiedOnly, showVerifiedOnly) ||
                other.showVerifiedOnly == showVerifiedOnly) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, category, sortBy, minPrice,
      maxPrice, showVerifiedOnly, page, limit);

  /// Create a copy of MarketplaceFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketplaceFilterStateImplCopyWith<_$MarketplaceFilterStateImpl>
      get copyWith => __$$MarketplaceFilterStateImplCopyWithImpl<
          _$MarketplaceFilterStateImpl>(this, _$identity);
}

abstract class _MarketplaceFilterState implements MarketplaceFilterState {
  const factory _MarketplaceFilterState(
      {final String? category,
      final SortOption sortBy,
      final double? minPrice,
      final double? maxPrice,
      final bool showVerifiedOnly,
      final int page,
      final int limit}) = _$MarketplaceFilterStateImpl;

  @override
  String? get category;
  @override
  SortOption get sortBy;
  @override
  double? get minPrice;
  @override
  double? get maxPrice;
  @override
  bool get showVerifiedOnly;
  @override
  int get page;
  @override
  int get limit;

  /// Create a copy of MarketplaceFilterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketplaceFilterStateImplCopyWith<_$MarketplaceFilterStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
