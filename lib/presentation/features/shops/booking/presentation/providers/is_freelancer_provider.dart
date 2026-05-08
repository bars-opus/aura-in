// lib/features/booking/presentation/providers/is_freelancer_provider.dart
import 'package:nano_embryo/presentation/features/currency/domain/entities/parsed_address.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'is_freelancer_provider.g.dart';

/// Provider that tracks whether the current booking is for a freelancer
@riverpod
class IsFreelancer extends _$IsFreelancer {
  @override
  bool build() => false;

  void setFreelancerMode(bool isFreelancer) {
    state = isFreelancer;
  }
}

/// Provider for selected service address (for freelancer bookings)
@riverpod
class SelectedAddress extends _$SelectedAddress {
  @override
  ParsedAddress? build() => null;

  void setAddress(ParsedAddress? address) {
    state = address;
  }
}
