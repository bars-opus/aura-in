import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:nano_embryo/core/map/config/feature/marker_style.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/core/map/presentation/widgets/canvas_marker_builder.dart';

/// Generic animated marker manager driven by [MapPin] and a
/// [MarkerStyleResolver]. Manages Mapbox point annotations with
/// staggered appearance, bounce-on-tap, and zoom-responsive sizing.
///
/// Usage:
/// ```dart
/// final manager = AnimatedMarkerManager(mapboxMap, context, tickerProvider);
/// await manager.initialize();
/// await manager.updateMarkers(pins, onTap, resolveStyle);
/// ```
class AnimatedMarkerManager {
  final MapboxMap _mapboxMap;
  final Map<String, String> _annotationIdToPinId = {};
  final Map<String, MapPin> _pinIdToPin = {};
  PointAnnotationManager? _annotationManager;
  Function(MapPin)? _onMarkerTap;
  List<MapPin> _currentPins = [];
  Cancelable? _tapEventsCancelable;
  final Map<String, Uint8List> _imageCache = {};
  double _currentZoom = 12.0;
  String? _selectedAnnotationId;
  final BuildContext context;
  final TickerProvider _tickerProvider;

  /// Per-pin resolver — set on every [updateMarkers] call.
  MarkerStyleResolver? _resolveStyle;

  // Animation controllers for each marker
  final Map<String, AnimationController> _animationControllers = {};
  late AnimationController _globalAppearController;

  // Debounce map updates to prevent glitches
  Timer? _updateDebounceTimer;
  bool _isUpdating = false;

  static const double _minIconSize = 0.5;
  static const double _maxIconSize = 2.0;
  static const double _selectedScale = 1.2;

  /// Called whenever zoom changes — wire this up in the map screen to also
  /// trigger a viewport fetch (zoom changes the visible area).
  VoidCallback? onViewportChangeNeeded;

  AnimatedMarkerManager(this._mapboxMap, this.context, this._tickerProvider);

  Future<void> initialize() async {
    _globalAppearController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: _tickerProvider,
    );

    _annotationManager =
        await _mapboxMap.annotations.createPointAnnotationManager();

    _tapEventsCancelable = _annotationManager?.tapEvents(
      onTap: (annotation) {
        final pinId = _annotationIdToPinId[annotation.id];
        if (pinId != null && _onMarkerTap != null) {
          final pin = _currentPins.firstWhere(
            (p) => p.id == pinId,
            orElse: () => throw Exception('Pin not found'),
          );
          _animateMarkerTap(annotation.id);
          _onMarkerTap!(pin);
        }
      },
    );

    _mapboxMap.onMapZoomListener = (MapContentGestureContext context) async {
      final cameraState = await _mapboxMap.getCameraState();
      final newZoom = cameraState.zoom;
      if (_currentZoom != newZoom) {
        _currentZoom = newZoom;
        _onZoomChanged();
        // Notify the map screen so it can also fetch pins for the new viewport.
        onViewportChangeNeeded?.call();
      }
    };

  }

  void _onZoomChanged() {
    // Debounce zoom updates to prevent flickering
    _updateDebounceTimer?.cancel();
    _updateDebounceTimer = Timer(const Duration(milliseconds: 50), () {
      for (final annotationId in _annotationIdToPinId.keys) {
        _updateSingleMarkerSize(annotationId);
      }
    });
  }

  Future<void> _animateMarkerTap(String annotationId) async {
    if (_selectedAnnotationId != null &&
        _selectedAnnotationId != annotationId) {
      await _resetMarkerAnimation(_selectedAnnotationId!);
    }
    _selectedAnnotationId = annotationId;

    final pinId = _annotationIdToPinId[annotationId];
    if (pinId == null) return;
    final pin = _pinIdToPin[pinId];
    if (pin == null) return;

    final baseSize = _getIconSizeForZoom(_currentZoom);
    final selectedSize = baseSize * _selectedScale;

    // Smooth bounce animation using AnimationController
    final bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: _tickerProvider,
    );

    bounceController.addListener(() async {
      final progress = bounceController.value;
      // Use easeOut elastic curve for bounce effect
      final bounceCurve = Curves.easeOutBack.transform(progress);
      final currentSize =
          selectedSize + (selectedSize * 0.1 * (1 - bounceCurve));
      await _updateSingleMarkerSize(annotationId, currentSize);
    });

    bounceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        bounceController.dispose();
      }
    });

    bounceController.forward();
  }

  Future<void> _resetMarkerAnimation(String annotationId) async {
    final controller = _animationControllers[annotationId];
    if (controller != null && controller.isAnimating) {
      controller.stop();
    }
    await _updateSingleMarkerSize(annotationId);
  }

  Future<void> resetSelectedMarker() async {
    if (_selectedAnnotationId != null) {
      await _resetMarkerAnimation(_selectedAnnotationId!);
      _selectedAnnotationId = null;
    }
  }

  double _getIconSizeForZoom(double zoom) {
    return (zoom / 12).clamp(_minIconSize, _maxIconSize);
  }

  Future<void> _updateSingleMarkerSize(
    String annotationId, [
    double? customSize,
  ]) async {
    final pinId = _annotationIdToPinId[annotationId];
    if (pinId == null) return;
    final pin = _pinIdToPin[pinId];
    if (pin == null) return;

    final isSelected = _selectedAnnotationId == annotationId;
    final baseSize = _getIconSizeForZoom(_currentZoom);
    final iconSize =
        customSize ?? (isSelected ? baseSize * _selectedScale : baseSize);

    final imageBytes = await _getHighResMarkerImage(pin, isSelected);

    final updatedAnnotation = PointAnnotation(
      id: annotationId,
      geometry: Point(coordinates: Position(pin.longitude, pin.latitude)),
      image: imageBytes,
      iconSize: iconSize,
      symbolSortKey: isSelected ? 100 : 10,
    );

    await _annotationManager?.update(updatedAnnotation);
  }

  Future<Uint8List> _getHighResMarkerImage(
    MapPin pin,
    bool isSelected,
  ) async {
    final style = _resolveStyle!(pin);

    // Cache key derived from the resolved style (not the pin) so the
    // cache stays correct across resolver swaps.
    final cacheKey =
        '${pin.id}_${style.label}_${style.color.toARGB32()}_${style.shape.name}_${isSelected ? 'selected' : 'normal'}';

    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey]!;
    }

    // `context` is a constructor-injected field (not a widget-tree context),
    // so there is no mount-lifecycle concern here.
    // ignore: use_build_context_synchronously
    final imageBytes = await CanvasMarkerBuilder.drawSimpleMarker(
      typeCode: style.label,
      accentColor: style.color,
      shape: style.shape,
      context: context,
      isSelected: isSelected,
      width: 100.h,
      height: 80.w,
    );

    _imageCache[cacheKey] = imageBytes;
    return imageBytes;
  }

  /// Update the markers shown on the map.
  ///
  /// [pins] — the new set of pins to display.
  /// [onMarkerTap] — called with the tapped [MapPin].
  /// [resolveStyle] — maps each [MapPin] to its [MarkerStyle].
  Future<void> updateMarkers(
    List<MapPin> pins,
    Function(MapPin) onMarkerTap,
    MarkerStyleResolver resolveStyle,
  ) async {
    if (_isUpdating) return;
    _isUpdating = true;

    debugPrint('updateMarkers called with ${pins.length} pins');

    if (_annotationManager == null) {
      debugPrint('_annotationManager is null');
      _isUpdating = false;
      return;
    }

    _onMarkerTap = onMarkerTap;
    _resolveStyle = resolveStyle;
    _currentPins = pins;
    _pinIdToPin.clear();
    for (final pin in pins) {
      _pinIdToPin[pin.id] = pin;
    }

    // Cancel any pending updates
    _updateDebounceTimer?.cancel();

    // Clear existing animation controllers
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    _animationControllers.clear();

    await _annotationManager?.deleteAll();
    _annotationIdToPinId.clear();
    _selectedAnnotationId = null;

    final iconSize = _getIconSizeForZoom(_currentZoom);
    for (int i = 0; i < pins.length; i++) {
      final pin = pins[i];

      // Generate marker image
      final imageBytes = await _getHighResMarkerImage(pin, false);

      // Create annotation
      final annotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(pin.longitude, pin.latitude)),
        image: imageBytes,
        iconSize: 0, // Start at 0 for animation
        symbolSortKey: 10,
      );

      final annotation = await _annotationManager?.create(annotationOptions);
      if (annotation != null) {
        _annotationIdToPinId[annotation.id] = pin.id;

        // Create animation controller for this marker
        final animationController = AnimationController(
          duration: const Duration(milliseconds: 400),
          vsync: _tickerProvider,
        );
        _animationControllers[annotation.id] = animationController;

        // Calculate delay based on index (stagger effect)
        final delay = i * 0.03;

        // Animate marker appearance
        animationController.addListener(() async {
          final scale = Curves.easeOutBack.transform(animationController.value);
          final currentSize = iconSize * scale;

          final updatedAnnotation = PointAnnotation(
            id: annotation.id,
            geometry: Point(
              coordinates: Position(pin.longitude, pin.latitude),
            ),
            image: imageBytes,
            iconSize: currentSize,
            symbolSortKey: 10,
          );

          await _annotationManager?.update(updatedAnnotation);
        });

        // Start animation with delay
        Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () {
          if (animationController.status != AnimationStatus.forward) {
            animationController.forward();
          }
        });
      }
    }

    // Wait a bit for markers to appear
    await Future.delayed(const Duration(milliseconds: 500));

    _isUpdating = false;
    debugPrint('Done! Total markers: ${_annotationIdToPinId.length}');
  }

  // Enhanced marker tap with spring animation
  Future<void> animateMarkerSelection(String annotationId) async {
    final controller = _animationControllers[annotationId];
    if (controller != null && !controller.isAnimating) {
      controller.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 200));
      controller.reverse();
    }
  }

  Future<void> clear() async {
    _updateDebounceTimer?.cancel();

    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    _animationControllers.clear();

    await _annotationManager?.deleteAll();
    _annotationIdToPinId.clear();
    _pinIdToPin.clear();
    _currentPins.clear();
    _selectedAnnotationId = null;

    if (_globalAppearController.isAnimating) {
      _globalAppearController.stop();
    }
  }

  void dispose() {
    _updateDebounceTimer?.cancel();
    _tapEventsCancelable?.cancel();

    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    _animationControllers.clear();

    _globalAppearController.dispose();
    _annotationManager?.deleteAll();
    _annotationIdToPinId.clear();
    _pinIdToPin.clear();
    _imageCache.clear();
    _onMarkerTap = null;
  }
}
