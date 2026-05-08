// lib/core/routing/routing_notifier.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoutingNotifier extends ChangeNotifier {
  User? _user;
  Profile? _profile;
  bool _isFirstLaunch = false;
  Timer? _debounceTimer;

  String? _pendingDeepLinkSlug;
  bool _deepLinkProcessed = false;
  String? _currentLocation;
  bool _isRecoveryMode = false;

  User? get user => _user;
  Profile? get profile => _profile;
  bool get isFirstLaunch => _isFirstLaunch;
  String? get currentLocation => _currentLocation;
  String? get pendingDeepLinkSlug => _pendingDeepLinkSlug;
  bool get hasPendingDeepLink => _pendingDeepLinkSlug != null && !_deepLinkProcessed;
  bool get isFullyAuthenticated => _user != null && _profile?.hasUsername == true;
  bool get isRecoveryMode => _isRecoveryMode;

  void setRecoveryMode(bool value) {
    if (_isRecoveryMode != value) {
      _isRecoveryMode = value;
      notifyListeners();
    }
  }

  // ==================== LOCATION ====================

  void updateLocation(String location) {
    if (_currentLocation != location) {
      _currentLocation = location;
      notifyListeners();
    }
  }

  // ==================== DEEP LINK HANDLING ====================

  void setPendingDeepLink(String slug) {
    _pendingDeepLinkSlug = slug;
    _deepLinkProcessed = false;
    notifyListeners();
  }

  String? consumePendingDeepLink() {
    final slug = _pendingDeepLinkSlug;
    if (slug != null) {
      _pendingDeepLinkSlug = null;
      _deepLinkProcessed = true;
    }
    return slug;
  }

  void clearPendingDeepLink() {
    _pendingDeepLinkSlug = null;
    _deepLinkProcessed = false;
    notifyListeners();
  }

  // ==================== PROFILE ====================

  void updateProfile(Profile? profile) {
    if (profile != _profile) {
      _profile = profile;
      notifyListeners();
    }
  }

  // ==================== CORE UPDATE ====================

  void update({User? user, Profile? profile, bool? isFirstLaunch}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      bool changed = false;
      if (user != _user) {
        _user = user;
        changed = true;
      }
      if (profile != _profile) {
        _profile = profile;
        changed = true;
      }
      if (isFirstLaunch != null && isFirstLaunch != _isFirstLaunch) {
        _isFirstLaunch = isFirstLaunch;
        changed = true;
      }
      if (changed) notifyListeners();
    });
  }

  // ==================== CLEANUP ====================

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
