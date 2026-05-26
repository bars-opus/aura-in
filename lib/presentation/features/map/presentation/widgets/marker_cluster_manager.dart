import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nano_embryo/presentation/features/map/data/models/shop_location_dto.dart';
import 'package:nano_embryo/core/map/presentation/widgets/canvas_marker_builder.dart';

class MarkerClusterManager {
  final MapboxMap _mapboxMap;
  final Map<String, List<ShopLocationDTO>> _clusters = {};
  final Map<String, PointAnnotation> _clusterAnnotations = {};
  PointAnnotationManager? _annotationManager;
  Function(List<ShopLocationDTO>)? _onClusterTap;
  double _currentZoom = 12.0;
  Cancelable? _tapEventsCancelable;

  // Cluster settings
  static const int _clusterRadius = 60; // pixels
  static const int _clusterMinPoints = 3;
  static const int _clusterMaxZoom = 14;

  MarkerClusterManager(this._mapboxMap);

  Future<void> initialize() async {
    _annotationManager =
        await _mapboxMap.annotations.createPointAnnotationManager();

    // Set up tap listener for clusters
    _tapEventsCancelable = _annotationManager?.tapEvents(
      onTap: (annotation) {
        String? clusterKey;
        for (final entry in _clusterAnnotations.entries) {
          if (entry.value.id == annotation.id) {
            clusterKey = entry.key;
            break;
          }
        }

        if (clusterKey != null && _onClusterTap != null) {
          final shops = _clusters[clusterKey];
          if (shops != null) {
            _onClusterTap!(shops);
          }
        }
      },
    );

    // Listen to zoom to recalculate clusters
    _mapboxMap.onMapZoomListener = (MapContentGestureContext context) {
      _mapboxMap.getCameraState().then((cameraState) {
        _currentZoom = cameraState.zoom;
        if (_currentZoom > _clusterMaxZoom) {
          _showIndividualMarkers();
        } else {
          _recalculateClusters();
        }
      });
    };
  }

  Future<void> updateMarkers(List<ShopLocationDTO> shops) async {
    if (_annotationManager == null) return;

    await _annotationManager?.deleteAll();
    _clusters.clear();
    _clusterAnnotations.clear();

    if (_currentZoom > _clusterMaxZoom) {
      await _showIndividualMarkers(shops);
    } else {
      _calculateClusters(shops);
      await _showClusterMarkers();
    }
  }

  void _calculateClusters(List<ShopLocationDTO> shops) {
    _clusters.clear();

    // Simple grid-based clustering
    final gridSize =
        _clusterRadius / (1000 * _currentZoom); // Convert to degrees

    for (final shop in shops) {
      final gridX = (shop.latitude / gridSize).floor();
      final gridY = (shop.longitude / gridSize).floor();
      final clusterKey = '$gridX,$gridY';

      _clusters.putIfAbsent(clusterKey, () => []).add(shop);
    }

    // Remove clusters with fewer than min points
    _clusters.removeWhere((key, shops) => shops.length < _clusterMinPoints);
  }

  Future<void> _showClusterMarkers() async {
    for (final entry in _clusters.entries) {
      final shops = entry.value;
      final center = _calculateClusterCenter(shops);

      final clusterSize = shops.length;
      final imageBytes = await _buildClusterImage(clusterSize);

      final annotationOptions = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(center.coordinates.lng, center.coordinates.lat),
        ),
        image: imageBytes,
        iconSize: 1.0,
        symbolSortKey: 5,
      );

      final created = await _annotationManager?.create(annotationOptions);
      if (created != null) {
        _clusterAnnotations[created.id] = created;
      }
    }
  }

  /// ✅ Build cluster marker image using CanvasMarkerBuilder
  Future<Uint8List> _buildClusterImage(int count) async {
    return await CanvasMarkerBuilder.drawClusterMarker(
      count: count,
      size: 44, // Slightly larger for better visibility
    );
  }

  Point _calculateClusterCenter(List<ShopLocationDTO> shops) {
    double sumLat = 0;
    double sumLng = 0;
    for (final shop in shops) {
      sumLat += shop.latitude;
      sumLng += shop.longitude;
    }
    return Point(
      coordinates: Position(sumLng / shops.length, sumLat / shops.length),
    );
  }

  Future<void> _showIndividualMarkers([List<ShopLocationDTO>? shops]) async {
    // Clear clusters when zoomed in - individual markers handled by main manager
    await _annotationManager?.deleteAll();
    _clusterAnnotations.clear();
  }

  Future<void> _recalculateClusters() async {
    // Trigger recalculation - parent should call updateMarkers with current shops
  }

  void setOnClusterTap(Function(List<ShopLocationDTO>) onTap) {
    _onClusterTap = onTap;
  }

  void dispose() {
    _tapEventsCancelable?.cancel();
    _annotationManager?.deleteAll();
    _clusters.clear();
    _clusterAnnotations.clear();
  }
}
