import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'walker_live_location_service.dart';

class WalkerTrackingScreen extends StatefulWidget {
  final String walkId;
  final String dogName;
  final bool isActive;

  const WalkerTrackingScreen({
    super.key,
    required this.walkId,
    required this.dogName,
    this.isActive = false,
  });

  @override
  State<WalkerTrackingScreen> createState() => _WalkerTrackingScreenState();
}

class _WalkerTrackingScreenState extends State<WalkerTrackingScreen> {
  static const _ink = Color.fromARGB(255, 10, 51, 92);

  bool _tracking = false;
  String _status = 'Ready to start';
  String? _errorMessage;
  int _elapsedSeconds = 0;
  Timer? _timer;

  late final WalkerLiveLocationService _svc;

  @override
  void initState() {
    super.initState();
    _svc = WalkerLiveLocationService(walkId: widget.walkId);
    
    // If walk already active, resume it
    if (widget.isActive) {
      _resumeWalk();
    }
  }

  Future<void> _resumeWalk() async {
    setState(() {
      _tracking = true;
      _status = 'Walk resumed';
    });
    
    try {
      await _svc.start();
      _startTimer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resume: ${e.toString()}';
        _tracking = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  Future<void> _start() async {
    setState(() {
      _errorMessage = null;
      _status = 'Starting...';
    });

    try {
      // Start location tracking
      await _svc.start();
      
      // Update walk status in Firestore
      await FirebaseFirestore.instance
          .collection('walks')
          .doc(widget.walkId)
          .update({
        'status': 'active',
        'startedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _tracking = true;
        _status = 'Tracking active';
      });
      
      _startTimer();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Walk started! Location tracking active ✅'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _status = 'Failed to start';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _stop() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('End Walk?'),
        content: Text('Are you sure you want to end the walk with ${widget.dogName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Walk'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Stop tracking and update Firestore
    await _svc.stop();
    _timer?.cancel();

    await FirebaseFirestore.instance
        .collection('walks')
        .doc(widget.walkId)
        .update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'durationSeconds': _elapsedSeconds,
    });

    setState(() {
      _tracking = false;
      _status = 'Walk completed';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Walk completed! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Return to walker home
      Navigator.pop(context);
    }
  }

  Future<void> _logActivity(String activity) async {
    try {
      await FirebaseFirestore.instance
          .collection('walks')
          .doc(widget.walkId)
          .update({
        'lastActivity': activity,
        'lastActivityTime': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$activity logged'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _svc.stop();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        title: Text('Walking ${widget.dogName}'),
        backgroundColor: const Color(0xFFF5E6D3),
        foregroundColor: _ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Status card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _ink.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _tracking ? Icons.directions_walk : Icons.pets,
                      size: 56,
                      color: _tracking ? Colors.green : _ink,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_tracking) ...[
                      const SizedBox(height: 12),
                      Text(
                        _formatDuration(_elapsedSeconds),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.green[700],
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Walk Duration',
                        style: TextStyle(
                          fontSize: 13,
                          color: _ink.withOpacity(0.6),
                        ),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tracking ? Colors.red : _ink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _tracking ? _stop : _start,
                  child: Text(
                    _tracking ? 'End Walk' : 'Start Walk',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick actions (only when tracking)
              if (_tracking) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        'Photo',
                        Icons.camera_alt,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Photo feature coming soon 📸'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        'Bathroom',
                        Icons.local_cafe,
                        () => _logActivity('Bathroom break 💧'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        'Water',
                        Icons.water_drop,
                        () => _logActivity('Water break 💦'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        'Playing',
                        Icons.pets,
                        () => _logActivity('Playing at park 🎾'),
                      ),
                    ),
                  ],
                ),
              ],

              const Spacer(),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _tracking 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _tracking 
                        ? Colors.green.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _tracking ? Icons.location_on : Icons.info_outline,
                      color: _tracking ? Colors.green : Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _tracking
                            ? 'Your location is being shared with the owner in real-time'
                            : 'Press "Start Walk" to begin GPS tracking',
                        style: TextStyle(
                          fontSize: 13,
                          color: _tracking ? Colors.green[900] : Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: _ink.withOpacity(0.2)),
      ),
      onPressed: onTap,
      icon: Icon(icon, color: _ink, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          color: _ink,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}