import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// TRUE Singleton service - lives for the entire app lifetime
class WalkerLiveLocationService {
  // Private constructor
  WalkerLiveLocationService._();
  
  // Single instance
  static final WalkerLiveLocationService instance = WalkerLiveLocationService._();
  
  // State
  StreamSubscription<Position>? _positionSubscription;
  String? _currentWalkId;
  bool _isActive = false;

  // Public getters
  bool get isActive => _isActive;
  String? get currentWalkId => _currentWalkId;

  /// Start tracking a walk
  Future<void> startWalk(String walkId) async {
    debugPrint("🚀 [SERVICE] startWalk called for: $walkId");
    
    // Already tracking this walk
    if (_isActive && _currentWalkId == walkId) {
      debugPrint("✅ [SERVICE] Already tracking this walk");
      return;
    }

    // Stop any existing walk first
    if (_isActive) {
      debugPrint("⚠️ [SERVICE] Stopping previous walk first");
      await stopWalk();
    }

    try {
      // 1. Check location services
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services disabled. Enable GPS.');
      }

      // 2. Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      // 3. Start location stream
      debugPrint("📡 [SERVICE] Starting GPS stream...");
      
      _currentWalkId = walkId;
      _isActive = true;

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // meters
        ),
      ).listen(
        (position) {
          _onLocationUpdate(position);
        },
        onError: (error) {
          debugPrint("❌ [SERVICE] GPS Error: $error");
        },
        cancelOnError: false, // Keep running even on errors
      );

      debugPrint("✅ [SERVICE] Walk tracking started successfully");

    } catch (e) {
      debugPrint("❌ [SERVICE] Failed to start: $e");
      _isActive = false;
      _currentWalkId = null;
      rethrow;
    }
  }

  /// Internal: Handle location updates
  void _onLocationUpdate(Position position) {
    if (!_isActive || _currentWalkId == null) return;

    debugPrint("📍 [SERVICE] Location: ${position.latitude}, ${position.longitude}");

    // Update Firestore (fire and forget - don't await)
    FirebaseFirestore.instance
        .collection('walks')
        .doc(_currentWalkId!)
        .set({
      'walkerLat': position.latitude,
      'walkerLng': position.longitude,
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).then((_) {
      debugPrint("✅ [SERVICE] Location saved to Firestore");
    }).catchError((error) {
      debugPrint("❌ [SERVICE] Firestore error: $error");
    });
  }

  /// Stop tracking
  Future<void> stopWalk() async {
    debugPrint("🛑 [SERVICE] Stopping walk: $_currentWalkId");

    if (!_isActive) {
      debugPrint("⚠️ [SERVICE] No active walk to stop");
      return;
    }

    // Cancel GPS stream
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    // Update Firestore
    if (_currentWalkId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('walks')
            .doc(_currentWalkId!)
            .update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
        debugPrint("✅ [SERVICE] Walk marked as completed");
      } catch (e) {
        debugPrint("❌ [SERVICE] Error completing walk: $e");
      }
    }

    _currentWalkId = null;
    _isActive = false;

    debugPrint("✅ [SERVICE] Service stopped");
  }

  /// Check if tracking a specific walk
  bool isTrackingWalk(String walkId) {
    return _isActive && _currentWalkId == walkId;
  }
}