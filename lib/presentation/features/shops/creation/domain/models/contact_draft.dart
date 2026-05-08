// lib/features/shop/creation/domain/entities/contact_draft.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nano_embryo/core/utils/validation/validation_result.dart';
import 'package:uuid/uuid.dart';

enum ContactType {
  phone('Phone', Icons.phone, 'tel:'),
  email('Email', Icons.email, 'mailto:'),
  website('Website', Icons.language, 'https://');

  const ContactType(this.displayName, this.icon, this.urlPrefix);
  final String displayName;
  final IconData icon;
  final String urlPrefix;
}

class ContactDraft extends Equatable {
  final String id;
  final ContactType type;
  final String value;
  final bool isPrimary;
  final int sortOrder;

  ContactDraft({
    String? id,
    required this.type,
    required this.value,
    this.isPrimary = false,
    this.sortOrder = 0,
  }) : id = id ?? const Uuid().v4();

  /// Validate contact based on type using your ValidationUtils
  String? validate() {
    if (value.isEmpty) return '${type.displayName} is required';

    switch (type) {
      case ContactType.phone:
        final result = ValidationUtils.validatePhoneNumber(value);
        if (!result.isValid) {
          return result.errorMessage;
        }
        break;

      case ContactType.email:
        final result = ValidationUtils.validateEmail(value);
        if (!result.isValid) {
          return result.errorMessage;
        }
        break;

      case ContactType.website:
        final result = ValidationUtils.validateUrl(
          value,
          requireHttps: false, // Allow http or https
          allowedSchemes: ['http', 'https'],
        );
        if (!result.isValid) {
          return result.errorMessage;
        }
        break;
    }
    return null;
  }

  /// Get formatted value for display
  String get formattedValue {
    if (type == ContactType.website) {
      return value.replaceAll('https://', '').replaceAll('http://', '');
    }
    return value;
  }

  /// Get URL for launching
  String get launchUrl {
    if (value.startsWith('http') ||
        value.startsWith('mailto') ||
        value.startsWith('tel')) {
      return value;
    }
    return '${type.urlPrefix}$value';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'value': value,
    'isPrimary': isPrimary,
    'sortOrder': sortOrder,
  };

  factory ContactDraft.fromJson(Map<String, dynamic> json) {
    return ContactDraft(
      id: json['id'] as String,
      type: ContactType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ContactType.phone,
      ),
      value: json['value'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  ContactDraft copyWith({String? value, bool? isPrimary, int? sortOrder}) {
    return ContactDraft(
      id: id,
      type: type,
      value: value ?? this.value,
      isPrimary: isPrimary ?? this.isPrimary,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, type, value, isPrimary, sortOrder];
}
