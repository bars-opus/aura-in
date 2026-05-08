// lib/features/dashboard/presentation/controllers/export_controller.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/export_report.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/services/export_service.dart';
import 'package:share_plus/share_plus.dart';

class ExportState extends Equatable {
  final bool isExporting;
  final String? error;
  final ExportResult? lastExport;
  final String? filePath;

  const ExportState({
    this.isExporting = false,
    this.error,
    this.lastExport,
    this.filePath,
  });

  factory ExportState.initial() {
    return const ExportState();
  }

  ExportState copyWith({
    bool? isExporting,
    String? error,
    ExportResult? lastExport,
    String? filePath,
  }) {
    return ExportState(
      isExporting: isExporting ?? this.isExporting,
      error: error,
      lastExport: lastExport ?? this.lastExport,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  List<Object?> get props => [isExporting, error, lastExport, filePath];
}

class ExportController extends StateNotifier<ExportState> {
  final ExportService _exportService;
  bool _disposed = false;

  ExportController({required ExportService exportService})
    : _exportService = exportService,
      super(ExportState.initial());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> exportReport(ExportConfig config) async {
    if (_disposed) return;

    state = state.copyWith(isExporting: true, error: null);

    try {
      final result = await _exportService.exportReport(config);

      if (_disposed) return;

      state = state.copyWith(
        isExporting: false,
        lastExport: result,
        filePath: result.filePath,
        error: result.error,
      );
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isExporting: false, error: e.toString());
    }
  }

  Future<void> shareFile() async {
    if (_disposed || state.filePath == null || state.filePath!.isEmpty) return;

    try {
      await Share.shareXFiles([
        XFile(state.filePath!),
      ], text: 'Here is your exported report from NanoEmbryo');
    } catch (e) {
      state = state.copyWith(error: 'Failed to share file: $e');
    }
  }

  void reset() {
    if (_disposed) return;
    state = ExportState.initial();
  }
}
