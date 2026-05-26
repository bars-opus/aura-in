import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/marker_code_generator.dart';
import 'package:nano_embryo/presentation/features/map/data/models/shop_location_dto.dart';
import 'package:nano_embryo/core/map/presentation/widgets/canvas_marker_builder.dart';

class AnimatedMarkerManager {
  final MapboxMap _mapboxMap;
  final Map<String, String> _annotationIdToShopId = {};
  final Map<String, ShopLocationDTO> _shopIdToShop = {};
  PointAnnotationManager? _annotationManager;
  Function(ShopLocationDTO)? _onMarkerTap;
  List<ShopLocationDTO> _currentShops = [];
  Cancelable? _tapEventsCancelable;
  final Map<String, Uint8List> _imageCache = {};
  double _currentZoom = 12.0;
  String? _selectedAnnotationId;
  final BuildContext context;
  final TickerProvider _tickerProvider;

  // Animation controllers for each marker
  final Map<String, AnimationController> _animationControllers = {};
  late AnimationController _globalAppearController;
  bool _isInitialized = false;

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
        final shopId = _annotationIdToShopId[annotation.id];
        if (shopId != null && _onMarkerTap != null) {
          final shop = _currentShops.firstWhere(
            (s) => s.id == shopId,
            orElse: () => throw Exception('Shop not found'),
          );
          _animateMarkerTap(annotation.id);
          _onMarkerTap!(shop);
        }
      },
    );

    _mapboxMap.onMapZoomListener = (MapContentGestureContext context) async {
      final cameraState = await _mapboxMap.getCameraState();
      final newZoom = cameraState.zoom;
      if (_currentZoom != newZoom) {
        _currentZoom = newZoom;
        _onZoomChanged();
        // Notify the map screen so it can also fetch shops for the new viewport.
        onViewportChangeNeeded?.call();
      }
    };

    _isInitialized = true;
  }

  void _onZoomChanged() {
    // Debounce zoom updates to prevent flickering
    _updateDebounceTimer?.cancel();
    _updateDebounceTimer = Timer(const Duration(milliseconds: 50), () {
      for (final annotationId in _annotationIdToShopId.keys) {
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

    final shopId = _annotationIdToShopId[annotationId];
    if (shopId == null) return;
    final shop = _shopIdToShop[shopId];
    if (shop == null) return;

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
    final shopId = _annotationIdToShopId[annotationId];
    if (shopId == null) return;
    final shop = _shopIdToShop[shopId];
    if (shop == null) return;

    final isSelected = _selectedAnnotationId == annotationId;
    final baseSize = _getIconSizeForZoom(_currentZoom);
    final iconSize =
        customSize ?? (isSelected ? baseSize * _selectedScale : baseSize);

    final imageBytes = await _getHighResMarkerImage(shop, isSelected, context);

    final updatedAnnotation = PointAnnotation(
      id: annotationId,
      geometry: Point(coordinates: Position(shop.longitude, shop.latitude)),
      image: imageBytes,
      iconSize: iconSize,
      symbolSortKey: isSelected ? 100 : 10,
    );

    await _annotationManager?.update(updatedAnnotation);
  }

  Future<Uint8List> _getHighResMarkerImage(
    ShopLocationDTO shop,
    bool isSelected,
    BuildContext context,
  ) async {
    final cacheKey =
        '${shop.id}_${shop.luxuryLevel}_${shop.shopType}_${isSelected ? 'selected' : 'normal'}';
    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey]!;
    }

    final typeCode = MarkerCodeGenerator.getTypeCode(shop.shopType);
    final luxuryColor = MarkerCodeGenerator.getLuxuryColor(shop.luxuryLevel);

    final imageBytes = await CanvasMarkerBuilder.drawSimpleMarker(
      typeCode: typeCode,
      accentColor: luxuryColor,
      context: context,
      isSelected: isSelected,
      width: 100.h,
      height: 80.w,
    );

    _imageCache[cacheKey] = imageBytes;
    return imageBytes;
  }

  Future<void> updateMarkers(
    List<ShopLocationDTO> shops,
    Function(ShopLocationDTO) onMarkerTap,
  ) async {
    if (_isUpdating) return;
    _isUpdating = true;

    debugPrint('🎯 updateMarkers called with ${shops.length} shops');

    if (_annotationManager == null) {
      debugPrint('❌ _annotationManager is null');
      _isUpdating = false;
      return;
    }

    _onMarkerTap = onMarkerTap;
    _currentShops = shops;
    _shopIdToShop.clear();
    for (final shop in shops) {
      _shopIdToShop[shop.id] = shop;
    }

    // Cancel any pending updates
    _updateDebounceTimer?.cancel();

    // Clear existing animation controllers
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    _animationControllers.clear();

    await _annotationManager?.deleteAll();
    _annotationIdToShopId.clear();
    _selectedAnnotationId = null;

    final iconSize = _getIconSizeForZoom(_currentZoom);

    // Add markers with staggered animation
    final List<Future> addFutures = [];

    for (int i = 0; i < shops.length; i++) {
      final shop = shops[i];

      // Generate marker image
      final imageBytes = await _getHighResMarkerImage(shop, false, context);

      // Create annotation
      final annotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(shop.longitude, shop.latitude)),
        image: imageBytes,
        iconSize: 0, // Start at 0 for animation
        symbolSortKey: 10,
      );

      final annotation = await _annotationManager?.create(annotationOptions);
      if (annotation != null) {
        _annotationIdToShopId[annotation.id] = shop.id;

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
              coordinates: Position(shop.longitude, shop.latitude),
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
    debugPrint('✅ Done! Total markers: ${_annotationIdToShopId.length}');
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
    _annotationIdToShopId.clear();
    _shopIdToShop.clear();
    _currentShops.clear();
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
    _annotationIdToShopId.clear();
    _shopIdToShop.clear();
    _imageCache.clear();
    _onMarkerTap = null;
  }
}
