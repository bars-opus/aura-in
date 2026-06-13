// lib/features/shop/creation/domain/entities/document_draft.dart

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum DocumentType {
  license('Business License', Icons.business_center),
  certification('Certification', Icons.verified),
  insurance('Insurance', Icons.security),
  tax('Tax Document', Icons.receipt),
  id('Identification', Icons.badge),
  permit('Permit', Icons.assignment_turned_in),
  other('Other', Icons.description);

  const DocumentType(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

class DocumentDraft extends Equatable {
  final String id;
  final DocumentType type;
  final String? title;
  final File file; // Local file
  final DateTime? expiryDate;
  final bool isVerified; // Will always be false initially
  final int sortOrder;

  DocumentDraft({
    String? id,
    required this.type,
    this.title,
    required this.file,
    this.expiryDate,
    this.isVerified = false,
    this.sortOrder = 0,
  }) : id = id ?? const Uuid().v4();

  /// Get file name from path
  String get fileName => file.path.split('/').last;

  /// Get file size in readable format
  String get fileSize {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Check if document is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'filePath': file.path,
    'expiryDate': expiryDate?.toIso8601String(),
    'isVerified': isVerified,
    'sortOrder': sortOrder,
  };

  factory DocumentDraft.fromJson(Map<String, dynamic> json) {
    return DocumentDraft(
      id: json['id'] as String,
      type: DocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DocumentType.other,
      ),
      title: json['title'] as String?,
      file: File(json['filePath'] as String),
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'] as String)
              : null,
      isVerified: json['isVerified'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  /// Creates a copy of this DocumentDraft with optional new values.
  DocumentDraft copyWith({
    String? id,
    DocumentType? type,
    String? title,
    File? file,
    DateTime? expiryDate,
    bool? isVerified,
    int? sortOrder,
  }) {
    return DocumentDraft(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      file: file ?? this.file,
      expiryDate: expiryDate ?? this.expiryDate,
      isVerified: isVerified ?? this.isVerified,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    file.path,
    expiryDate,
    isVerified,
    sortOrder,
  ];
}
