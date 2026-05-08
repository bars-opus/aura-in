// lib/features/payment/data/models/bank_model.dart

import 'package:equatable/equatable.dart';

class BankModel extends Equatable {
  final String code;
  final String name;

  const BankModel({required this.code, required this.name});

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [code, name];
}
