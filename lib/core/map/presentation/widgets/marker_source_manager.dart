import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:nano_embryo/core/map/config/feature/marker_style.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/core/map/presentation/widgets/canvas_marker_builder.dart';

/// Manages the GeoJSON source + symbol layers that render clustered +
/// individual pins on the Mapbox map.
///
/// Replaces `AnimatedMarkerManager` (PointAnnotationManager-based).
/// Mapbox handles clustering natively at the source level; we layer
/// individual pin images on top via on-demand-registered style images.
class MarkerSourceManager {
  static const String _sourceId = 'engine-pins';
  static const String _layerIndividual = 'engine-pins-individual';
  static const String _layerClusterBubble = 'engine-pins-cluster-bubble';
  static const String _layerClusterCount = 'engine-pins-cluster-count';
  static const String _imageCluster = 'engine-pin-cluster';

  final MapboxMap _mapboxMap;
  final double _clusterRadius;
  final double _clusterMaxZoom;
  final BuildContext _context;
  final MarkerStyleResolver _resolveStyle;
  final void Function(String pinId) _onPinTap;

  final Set<String> _registeredImages = {};
  final Map<String, Uint8List> _imageBytesCache = {};

  bool _layersAdded = false;
  String? _selectedPinId;
  List<MapPin> _currentPins = const [];

  MarkerSourceManager({
    required MapboxMap mapboxMap,
    required double clusterRadius,
    required double clusterMaxZoom,
    required BuildContext context,
    required MarkerStyleResolver resolveStyle,
    required void Function(String pinId) onPinTap,
  })  : _mapboxMap = mapboxMap,
        _clusterRadius = clusterRadius,
        _clusterMaxZoom = clusterMaxZoom,
        _context = context,
        _resolveStyle = resolveStyle,
        _onPinTap = onPinTap;

  /// Build the source, register the cluster bubble image, and add the
  /// three layers. Idempotent — safe to call once per map lifecycle.
  Future<void> initialize() async {
    if (_layersAdded) return;

    // 1. Register the cluster-bubble image (single image; text overlays count).
    final primaryColor = Theme.of(_context).colorScheme.primary;
    final clusterBytes = await CanvasMarkerBuilder.drawClusterMarker(
      color: primaryColor,
      size: 56,
    );
    await _mapboxMap.style.addStyleImage(
      _imageCluster,
      1.0,
      MbxImage(width: 56, height: 56, data: clusterBytes),
      false,
      const [],
      const [],
      null,
    );

    // 2. Add the GeoJSON source with clustering enabled.
    await _mapboxMap.style.addSource(GeoJsonSource(
      id: _sourceId,
      data: '{"type":"FeatureCollection","features":[]}',
      cluster: true,
      clusterRadius: _clusterRadius,
      clusterMaxZoom: _clusterMaxZoom,
    ));

    // 3. Cluster bubble layer — shown only when point_count property is present.
    await _mapboxMap.style.addLayer(SymbolLayer(
      id: _layerClusterBubble,
      sourceId: _sourceId,
      iconImage: _imageCluster,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
      filter: ['has', 'point_count'],
    ));

    // 4. Cluster count overlay — text on top of the cluster bubble.
    await _mapboxMap.style.addLayer(SymbolLayer(
      id: _layerClusterCount,
      sourceId: _sourceId,
      textFieldExpression: ['get', 'point_count_abbreviated'],
      textSize: 14.0,
      textColor: Colors.white.toARGB32(),
      textAllowOverlap: true,
      textIgnorePlacement: true,
      filter: ['has', 'point_count'],
    ));

    // 5. Individual pin layer — shown only when point_count is absent.
    // iconImage and iconSize are driven by expressions using feature properties
    // and feature-state respectively.
    await _mapboxMap.style.addLayer(SymbolLayer(
      id: _layerIndividual,
      sourceId: _sourceId,
      iconImageExpression: ['get', 'iconImage'],
      iconSizeExpression: [
        'case',
        ['boolean', ['feature-state', 'selected'], false],
        1.4,
        1.0,
      ],
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
      filter: ['!', ['has', 'point_count']],
    ));

    _layersAdded = true;

    // Wire up the tap listener. OnMapTapListener receives MapContentGestureContext.
    _mapboxMap.onMapTapListener = _handleMapTap;
  }

  // ── updatePins + image registration ──────────────────────────────────────

  /// Push a new list of pins to the source.
  Future<void> updatePins(List<MapPin> pins) async {
    if (!_layersAdded) return;

    _currentPins = pins;

    // 1. Lazy-register style images for every unique style + selected variant.
    for (final pin in pins) {
      final style = _resolveStyle(pin);
      await _ensureStyleImageRegistered(style, isSelected: false);
      await _ensureStyleImageRegistered(style, isSelected: true);
    }

    // 2. Build the GeoJSON FeatureCollection.
    final features = pins.map((pin) {
      final style = _resolveStyle(pin);
      return {
        'type': 'Feature',
        'id': pin.id,
        'properties': {
          'pinId': pin.id,
          'iconImage': _imageNameFor(style, isSelected: false),
          'iconImageSelected': _imageNameFor(style, isSelected: true),
        },
        'geometry': {
          'type': 'Point',
          'coordinates': [pin.longitude, pin.latitude],
        },
      };
    }).toList();

    final geojson = jsonEncode({
      'type': 'FeatureCollection',
      'features': features,
    });

    // updateGeoJSON sends the JSON string directly to the native source.
    final source = await _mapboxMap.style.getSource(_sourceId);
    if (source is GeoJsonSource) {
      await source.updateGeoJSON(geojson);
    }

    if (_selectedPinId != null) {
      await _applySelectionState(_selectedPinId!);
    }
  }

  Future<void> _ensureStyleImageRegistered(
    MarkerStyle style, {
    required bool isSelected,
  }) async {
    final name = _imageNameFor(style, isSelected: isSelected);
    if (_registeredImages.contains(name)) return;

    final bytes = await _drawMarkerImage(style, isSelected: isSelected);
    final width = 100.h.toInt();
    final height = 80.w.toInt();

    await _mapboxMap.style.addStyleImage(
      name,
      1.0,
      MbxImage(width: width, height: height, data: bytes),
      false,
      const [],
      const [],
      null,
    );
    _registeredImages.add(name);
  }

  Future<Uint8List> _drawMarkerImage(
    MarkerStyle style, {
    required bool isSelected,
  }) async {
    final cacheKey = _imageNameFor(style, isSelected: isSelected);
    final cached = _imageBytesCache[cacheKey];
    if (cached != null) return cached;

    final bytes = await CanvasMarkerBuilder.drawSimpleMarker(
      typeCode: style.label,
      accentColor: style.color,
      shape: style.shape,
      context: _context,
      isSelected: isSelected,
      width: 100.h,
      height: 80.w,
    );
    _imageBytesCache[cacheKey] = bytes;
    return bytes;
  }

  String _imageNameFor(MarkerStyle style, {required bool isSelected}) {
    return 'engine-pin'
        '-${style.label}'
        '-${style.color.toARGB32()}'
        '-${style.shape.name}'
        '-${isSelected ? 'sel' : 'norm'}';
  }

  // ── Selection state ───────────────────────────────────────────────────────

  /// Update the active selection. Either pinId or null (clear).
  Future<void> selectPin(String? pinId) async {
    if (_selectedPinId == pinId) return;

    if (_selectedPinId != null) {
      // setFeatureState takes positional args: sourceId, sourceLayerId, featureId, state (JSON string)
      await _mapboxMap.setFeatureState(
        _sourceId,
        null,
        _selectedPinId!,
        '{"selected": false}',
      );
    }

    _selectedPinId = pinId;

    if (pinId != null) {
      await _applySelectionState(pinId);
    }
  }

  Future<void> _applySelectionState(String pinId) async {
    await _mapboxMap.setFeatureState(
      _sourceId,
      null,
      pinId,
      '{"selected": true}',
    );
  }

  // ── Tap routing ───────────────────────────────────────────────────────────

  /// Tap routing: cluster taps zoom in; pin taps emit the callback.
  /// [context] is MapContentGestureContext from the OnMapTapListener typedef.
  Future<void> _handleMapTap(MapContentGestureContext context) async {
    final screenCoord = context.touchPosition;

    // Build a small ±10 px bounding box around the tap for hit testing.
    final box = ScreenBox(
      min: ScreenCoordinate(x: screenCoord.x - 10, y: screenCoord.y - 10),
      max: ScreenCoordinate(x: screenCoord.x + 10, y: screenCoord.y + 10),
    );
    final geometry = RenderedQueryGeometry.fromScreenBox(box);

    // 1. Check cluster bubble layer first.
    final clusterFeatures = await _mapboxMap.queryRenderedFeatures(
      geometry,
      RenderedQueryOptions(layerIds: [_layerClusterBubble], filter: null),
    );

    if (clusterFeatures.isNotEmpty) {
      final feature = clusterFeatures.first;
      if (feature != null) {
        final geom =
            feature.queriedFeature.feature['geometry'] as Map<Object?, Object?>?;
        final coordsList = (geom?['coordinates'] as List?)?.cast<num>();
        if (coordsList != null && coordsList.length >= 2) {
          final cameraState = await _mapboxMap.getCameraState();
          await _mapboxMap.flyTo(
            CameraOptions(
              center: Point(
                coordinates: Position(
                  coordsList[0].toDouble(),
                  coordsList[1].toDouble(),
                ),
              ),
              zoom: cameraState.zoom + 2.0,
            ),
            MapAnimationOptions(duration: 600),
          );
        }
      }
      return;
    }

    // 2. Check individual pin layer.
    final pinFeatures = await _mapboxMap.queryRenderedFeatures(
      geometry,
      RenderedQueryOptions(layerIds: [_layerIndividual], filter: null),
    );

    if (pinFeatures.isNotEmpty) {
      final first = pinFeatures.first;
      if (first != null) {
        final feature = first.queriedFeature.feature;
        final properties = feature['properties'];
        final propertyPinId = properties is Map ? properties['pinId'] : null;
        final pinId = (propertyPinId ?? feature['id'])?.toString();

        if (pinId != null && _currentPins.any((pin) => pin.id == pinId)) {
          _onPinTap(pinId);
        }
      }
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    _mapboxMap.onMapTapListener = null;
    try {
      await _mapboxMap.style.removeStyleLayer(_layerIndividual);
    } catch (_) {}
    try {
      await _mapboxMap.style.removeStyleLayer(_layerClusterCount);
    } catch (_) {}
    try {
      await _mapboxMap.style.removeStyleLayer(_layerClusterBubble);
    } catch (_) {}
    try {
      await _mapboxMap.style.removeStyleSource(_sourceId);
    } catch (_) {}
    _registeredImages.clear();
    _imageBytesCache.clear();
    _currentPins = const [];
    _selectedPinId = null;
    _layersAdded = false;
  }
}
