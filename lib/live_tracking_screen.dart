import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveTrackingMapScreen extends StatefulWidget {
  final String walkId;
  final String walkerName;
  final String dogName;

  const LiveTrackingMapScreen({
    super.key,
    required this.walkId,
    required this.walkerName,
    required this.dogName,
  });

  @override
  State<LiveTrackingMapScreen> createState() => _LiveTrackingMapScreenState();
}

class _LiveTrackingMapScreenState extends State<LiveTrackingMapScreen> {
  static const _ink = Color.fromARGB(255, 10, 51, 92);

  GoogleMapController? _mapController;
  StreamSubscription<DocumentSnapshot>? _sub;

  LatLng _currentPosition = const LatLng(31.9539, 35.9106); // Amman default
  Set<Marker> _markers = {};
  int _updateCount = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("🆕 [MAP] Screen initialized for walkId: ${widget.walkId}");
    _startListening();
  }

  void _startListening() {
    debugPrint("👂 [MAP] Starting Firestore listener...");

    _sub = FirebaseFirestore.instance
        .collection('walks')
        .doc(widget.walkId)
        .snapshots()
        .listen(
      (DocumentSnapshot snapshot) {
        debugPrint("📡 [MAP] Firestore update received!");
        debugPrint("📄 [MAP] Document exists: ${snapshot.exists}");

        if (!snapshot.exists) {
          debugPrint("❌ [MAP] Document does not exist!");
          return;
        }

        final data = snapshot.data() as Map<String, dynamic>?;
        debugPrint("📊 [MAP] Data: $data");

        if (data == null) {
          debugPrint("❌ [MAP] Data is null!");
          return;
        }

        final lat = data['walkerLat'];
        final lng = data['walkerLng'];

        debugPrint("🔍 [MAP] walkerLat: $lat (type: ${lat.runtimeType})");
        debugPrint("🔍 [MAP] walkerLng: $lng (type: ${lng.runtimeType})");

        if (lat == null || lng == null) {
          debugPrint("⚠️ [MAP] Coordinates are null, skipping update");
          return;
        }

        final newLat = (lat as num).toDouble();
        final newLng = (lng as num).toDouble();
        final newPosition = LatLng(newLat, newLng);

        debugPrint("📍 [MAP] New position: $newLat, $newLng");
        debugPrint("📍 [MAP] Old position: ${_currentPosition.latitude}, ${_currentPosition.longitude}");

        final distance = _calculateDistance(_currentPosition, newPosition);
        debugPrint("📏 [MAP] Distance moved: ${distance.toStringAsFixed(2)} meters");

        // Update state
        setState(() {
          _updateCount++;
          _currentPosition = newPosition;
          
          debugPrint("🔄 [MAP] setState called (update #$_updateCount)");
          
          // Update marker
          _markers = {
            Marker(
              markerId: MarkerId('walker_$_updateCount'),
              position: newPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(
                title: widget.walkerName,
                snippet: 'Update #$_updateCount',
              ),
            ),
          };
          
          debugPrint("✅ [MAP] Marker updated to: $newPosition");
        });

        // Animate camera
        if (_mapController != null) {
          debugPrint("📷 [MAP] Animating camera...");
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(newPosition),
          );
          debugPrint("✅ [MAP] Camera animated");
        } else {
          debugPrint("⚠️ [MAP] Map controller is null, can't move camera");
        }

        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      },
      onError: (error) {
        debugPrint("❌ [MAP] Stream error: $error");
      },
      cancelOnError: false,
    );

    debugPrint("✅ [MAP] Listener started successfully");
  }

  double _calculateDistance(LatLng from, LatLng to) {
    // Rough distance calculation in meters
    const double earthRadius = 6371000; // meters
    final dLat = (to.latitude - from.latitude) * (3.14159 / 180);
    final dLon = (to.longitude - from.longitude) * (3.14159 / 180);
    final a = (dLat / 2) * (dLat / 2) + (dLon / 2) * (dLon / 2);
    final c = 2 * a;
    return earthRadius * c;
  }

  @override
  void dispose() {
    debugPrint("🗑️ [MAP] Disposing screen...");
    _sub?.cancel();
    _mapController?.dispose();
    debugPrint("✅ [MAP] Screen disposed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🏗️ [MAP] Building UI (markers count: ${_markers.length})");

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        iconTheme: const IconThemeData(color: _ink),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Tracking',
              style: TextStyle(color: _ink, fontWeight: FontWeight.w900, fontSize: 18),
            ),
            Text(
              'Updates: $_updateCount',
              style: TextStyle(color: _ink.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _ink.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_walk, color: _ink),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${widget.walkerName} is walking ${widget.dogName}',
                          style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _updateCount > 0
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _updateCount > 0 ? '🟢 Live' : '⏳ Waiting',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _updateCount > 0 ? Colors.green[700] : Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position: ${_currentPosition.latitude.toStringAsFixed(6)}, ${_currentPosition.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: _ink.withOpacity(0.6),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    debugPrint("🗺️ [MAP] GoogleMap created!");
                    _mapController = controller;
                    debugPrint("✅ [MAP] Controller saved");
                  },
                  markers: _markers,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          ),

          // Debug info
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black87,
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEBUG INFO',
                    style: TextStyle(
                      color: Colors.green[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Walk ID: ${widget.walkId}',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    'Updates received: $_updateCount',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    'Markers: ${_markers.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    'Controller: ${_mapController != null ? "✅" : "❌"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}