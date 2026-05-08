// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProductFormState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  ProductModel? get createdProduct => throw _privateConstructorUsedError;
  ProductModel? get updatedProduct => throw _privateConstructorUsedError;

  /// Create a copy of ProductFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductFormStateCopyWith<ProductFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductFormStateCopyWith<$Res> {
  factory $ProductFormStateCopyWith(
          ProductFormState value, $Res Function(ProductFormState) then) =
      _$ProductFormStateCopyWithImpl<$Res, ProductFormState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool success,
      String? error,
      ProductModel? createdProduct,
      ProductModel? updatedProduct});
}

/// @nodoc
class _$ProductFormStateCopyWithImpl<$Res, $Val extends ProductFormState>
    implements $ProductFormStateCopyWith<$Res> {
  _$ProductFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? success = null,
    Object? error = freezed,
    Object? createdProduct = freezed,
    Object? updatedProduct = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      createdProduct: freezed == createdProduct
          ? _value.createdProduct
          : createdProduct // ignore: cast_nullable_to_non_nullable
              as ProductModel?,
      updatedProduct: freezed == updatedProduct
          ? _value.updatedProduct
          : updatedProduct // ignore: cast_nullable_to_non_nullable
              as ProductModel?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductFormStateImplCopyWith<$Res>
    implements $ProductFormStateCopyWith<$Res> {
  factory _$$ProductFormStateImplCopyWith(_$ProductFormStateImpl value,
          $Res Function(_$ProductFormStateImpl) then) =
      __$$ProductFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool success,
      String? error,
      ProductModel? createdProduct,
      ProductModel? updatedProduct});
}

/// @nodoc
class __$$ProductFormStateImplCopyWithImpl<$Res>
    extends _$ProductFormStateCopyWithImpl<$Res, _$ProductFormStateImpl>
    implements _$$ProductFormStateImplCopyWith<$Res> {
  __$$ProductFormStateImplCopyWithImpl(_$ProductFormStateImpl _value,
      $Res Function(_$ProductFormStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? success = null,
    Object? error = freezed,
    Object? createdProduct = freezed,
    Object? updatedProduct = freezed,
  }) {
    return _then(_$ProductFormStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      createdProduct: freezed == createdProduct
          ? _value.createdProduct
          : createdProduct // ignore: cast_nullable_to_non_nullable
              as ProductModel?,
      updatedProduct: freezed == updatedProduct
          ? _value.updatedProduct
          : updatedProduct // ignore: cast_nullable_to_non_nullable
              as ProductModel?,
    ));
  }
}

/// @nodoc

class _$ProductFormStateImpl implements _ProductFormState {
  const _$ProductFormStateImpl(
      {this.isLoading = false,
      this.success = false,
      this.error,
      this.createdProduct,
      this.updatedProduct});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool success;
  @override
  final String? error;
  @override
  final ProductModel? createdProduct;
  @override
  final ProductModel? updatedProduct;

  @override
  String toString() {
    return 'ProductFormState(isLoading: $isLoading, success: $success, error: $error, createdProduct: $createdProduct, updatedProduct: $updatedProduct)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductFormStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.createdProduct, createdProduct) ||
                other.createdProduct == createdProduct) &&
            (identical(other.updatedProduct, updatedProduct) ||
                other.updatedProduct == updatedProduct));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, isLoading, success, error, createdProduct, updatedProduct);

  /// Create a copy of ProductFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductFormStateImplCopyWith<_$ProductFormStateImpl> get copyWith =>
      __$$ProductFormStateImplCopyWithImpl<_$ProductFormStateImpl>(
          this, _$identity);
}

abstract class _ProductFormState implements ProductFormState {
  const factory _ProductFormState(
      {final bool isLoading,
      final bool success,
      final String? error,
      final ProductModel? createdProduct,
      final ProductModel? updatedProduct}) = _$ProductFormStateImpl;

  @override
  bool get isLoading;
  @override
  bool get success;
  @override
  String? get error;
  @override
  ProductModel? get createdProduct;
  @override
  ProductModel? get updatedProduct;

  /// Create a copy of ProductFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductFormStateImplCopyWith<_$ProductFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
