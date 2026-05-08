// lib/features/dashboard/data/models/export_report.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ReportType {
  bookings,
  revenue,
  clients,
  workers,
  services;

  String get displayName {
    switch (this) {
      case ReportType.bookings:
        return 'Bookings Report';
      case ReportType.revenue:
        return 'Revenue Report';
      case ReportType.clients:
        return 'Clients Report';
      case ReportType.workers:
        return 'Workers Report';
      case ReportType.services:
        return 'Services Report';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.bookings:
        return Icons.calendar_today;
      case ReportType.revenue:
        return Icons.attach_money;
      case ReportType.clients:
        return Icons.people;
      case ReportType.workers:
        return Icons.person;
      case ReportType.services:
        return Icons.spa;
    }
  }
}

enum ExportFormat {
  csv,
  excel,
  pdf;

  String get displayName {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.pdf:
        return 'PDF';
    }
  }

  String get extension {
    switch (this) {
      case ExportFormat.csv:
        return '.csv';
      case ExportFormat.excel:
        return '.xlsx';
      case ExportFormat.pdf:
        return '.pdf';
    }
  }
}

class ExportConfig extends Equatable {
  final ReportType reportType;
  final ExportFormat format;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool includeDetails;

  const ExportConfig({
    required this.reportType,
    this.format = ExportFormat.csv,
    this.startDate,
    this.endDate,
    this.includeDetails = true,
  });

  String get fileName {
    final dateStr = DateTime.now().toIso8601String().split('T').first;
    return '${_getFileNamePrefix()}_$dateStr${format.extension}';
  }

  String _getFileNamePrefix() {
    switch (reportType) {
      case ReportType.bookings:
        return 'bookings';
      case ReportType.revenue:
        return 'revenue';
      case ReportType.clients:
        return 'clients';
      case ReportType.workers:
        return 'workers';
      case ReportType.services:
        return 'services';
    }
  }

  @override
  List<Object?> get props => [reportType, format, startDate, endDate, includeDetails];
}

class ExportResult extends Equatable {
  final ExportConfig config;
  final String filePath;
  final int recordCount;
  final DateTime exportedAt;
  final String? error;
  final List<List<dynamic>>? data;
  final List<String>? headers;

  const ExportResult({
    required this.config,
    required this.filePath,
    required this.recordCount,
    required this.exportedAt,
    this.error,
    this.data,
    this.headers,
  });

  bool get isSuccess => error == null;

  @override
  List<Object?> get props => [config, filePath, recordCount, exportedAt, error];
}
