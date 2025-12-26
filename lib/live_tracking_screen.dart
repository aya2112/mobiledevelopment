import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';



class LiveTrackingMapScreen extends StatefulWidget {
  final String walkId;        // Firestore doc id
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

  GoogleMapController? _mapCtrl;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  LatLng? _walkerPos;
  Marker? _walkerMarker;

  @override
  void initState() {
    super.initState();

    _sub = FirebaseFirestore.instance
        .collection('walks')
        .doc(widget.walkId)
        .snapshots()
        .listen((doc) {
      final data = doc.data();
      if (data == null) return;

      final lat = (data['walkerLat'] as num?)?.toDouble();
      final lng = (data['walkerLng'] as num?)?.toDouble();
      if (lat == null || lng == null) return;

      final pos = LatLng(lat, lng);

      setState(() {
        _walkerPos = pos;
        _walkerMarker = Marker(
          markerId: const MarkerId('walker'),
          position: pos,
          infoWindow: InfoWindow(title: widget.walkerName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
      });

      // Smoothly move camera
      _mapCtrl?.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _mapCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initial = _walkerPos ?? const LatLng(31.9539, 35.9106); // Amman default

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        iconTheme: const IconThemeData(color: _ink),
        title: const Text(
          'Live Tracking',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _ink.withOpacity(0.08)),
              ),
              child: Row(
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
                  if (_walkerPos == null)
                    const Text(
                      'Connecting…',
                      style: TextStyle(color: _ink),
                    ),
                ],
              ),
            ),
          ),

          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initial,
                zoom: 15,
              ),
              onMapCreated: (c) => _mapCtrl = c,
              markers: {
                if (_walkerMarker != null) _walkerMarker!,
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
        ],
      ),
    );
  }
}
