import 'dart:async';
import 'package:flutter/material.dart';
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

  // ✅ Get the singleton instance
  final _service = WalkerLiveLocationService.instance;
  
  bool _tracking = false;
  String _status = 'Ready to start';
  String? _errorMessage;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    debugPrint("🔍 [SCREEN] initState - walkId: ${widget.walkId}");
    debugPrint("🔍 [SCREEN] Service active: ${_service.isActive}");
    debugPrint("🔍 [SCREEN] Current walk: ${_service.currentWalkId}");
    
    // Check if service is already tracking this walk
    if (_service.isTrackingWalk(widget.walkId)) {
      debugPrint("✅ [SCREEN] Resuming active walk");
      _resumeActiveWalk();
    } else if (widget.isActive) {
      debugPrint("⚠️ [SCREEN] Walk marked active but service not tracking - restarting");
      _start();
    }
  }

  void _resumeActiveWalk() {
    setState(() {
      _tracking = true;
      _status = 'Walk in progress';
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  Future<void> _start() async {
    debugPrint("▶️ [SCREEN] Start button pressed");
    
    setState(() {
      _errorMessage = null;
      _status = 'Starting...';
    });

    try {
      // ✅ Start the service
      await _service.startWalk(widget.walkId);
      
      // Update Firestore
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
            content: Text('Walk started! GPS tracking active ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }

      debugPrint("✅ [SCREEN] Walk started successfully");

    } catch (e) {
      debugPrint("❌ [SCREEN] Failed to start: $e");
      
      setState(() {
        _errorMessage = e.toString();
        _status = 'Failed to start';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stop() async {
    debugPrint("⏹️ [SCREEN] Stop button pressed");
    
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

    // ✅ Stop the service
    await _service.stopWalk();
    _timer?.cancel();

    await FirebaseFirestore.instance
        .collection('walks')
        .doc(widget.walkId)
        .update({
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
      
      Navigator.pop(context);
    }

    debugPrint("✅ [SCREEN] Walk ended successfully");
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
          SnackBar(content: Text('$activity logged')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
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
    debugPrint("🗑️ [SCREEN] dispose called - but service keeps running!");
    _timer?.cancel();
    // ⚠️ DO NOT stop the service here!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop && _tracking) {
          debugPrint("⬅️ [SCREEN] Going back - service still running");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Walk continues in background 📍'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
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
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.radio_button_checked, size: 12, color: Colors.green[700]),
                              const SizedBox(width: 6),
                              Text(
                                'Running in background',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
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
                                  style: const TextStyle(fontSize: 13, color: Colors.red),
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

                // Quick actions
                if (_tracking) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction('Photo', Icons.camera_alt, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon 📸')),
                          );
                        }),
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
                          () => _logActivity('Playing 🎾'),
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
                              ? 'Location shared in real-time. Safe to close this screen.'
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
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: _ink.withOpacity(0.2)),
      ),
      onPressed: onTap,
      icon: Icon(icon, color: _ink, size: 20),
      label: Text(
        label,
        style: const TextStyle(color: _ink, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}