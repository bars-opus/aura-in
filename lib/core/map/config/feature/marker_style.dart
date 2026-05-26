import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

/// Visual shape of a marker. The default `pill` preserves the existing
/// rectangle-with-tail look drawn by `CanvasMarkerBuilder`.
enum MarkerShape { pill, circle, square }

/// Resolved marker visual derived from a [MapPin].
class MarkerStyle extends Equatable {
  /// Text shown inside the marker (e.g. 'SAL.', '$45', 'TODAY').
  final String label;

  /// Background color of the marker body.
  final Color color;

  /// Visual shape. Defaults to the current pill-with-tail look.
  final MarkerShape shape;

  const MarkerStyle({
    required this.label,
    required this.color,
    this.shape = MarkerShape.pill,
  });

  @override
  List<Object?> get props => [label, color, shape];
}

/// Resolver function: per-pin, return how the marker should look.
typedef MarkerStyleResolver = MarkerStyle Function(MapPin pin);
