import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class WalkerLiveLocationService {
  final String walkId;
  StreamSubscription<Position>? _sub;

  WalkerLiveLocationService({required this.walkId});

  Future<void> start() async {
    // 1) Location services ON?
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled');
    }

    // 2) Permission
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    // 3) Start streaming GPS
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters (updates when moving)
      ),
    ).listen((pos) async {
      await FirebaseFirestore.instance.collection('walks').doc(walkId).set({
        'walkerLat': pos.latitude,
        'walkerLng': pos.longitude,
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;

    await FirebaseFirestore.instance.collection('walks').doc(walkId).set({
      'status': 'ended',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
