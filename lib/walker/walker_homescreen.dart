import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawpals/welcomescreen.dart';
import 'walker_tracking_screen.dart';

class WalkerHomeScreen extends StatelessWidget {
  const WalkerHomeScreen({super.key});

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        title: const Text(
          'My Walks',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: _ink),
            onPressed: () async {
              Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => WelcomeScreen()),
);

            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ Get walks assigned to this walker
        stream: FirebaseFirestore.instance
            .collection('walks')
            .where('walkerId', isEqualTo: user.uid)
            .where('status', whereIn: ['scheduled', 'active', 'completed'])
            .orderBy('scheduledTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final walks = snapshot.data?.docs ?? [];

          if (walks.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: walks.length,
            itemBuilder: (context, index) {
              final walk = walks[index].data() as Map<String, dynamic>;
              final walkId = walks[index].id;
              return _buildWalkCard(context, walkId, walk);
            },
          );
        },
      ),
    );
  }

  Widget _buildWalkCard(BuildContext context, String walkId, Map<String, dynamic> walk) {
    final status = walk['status'] as String? ?? 'scheduled';
    final dogName = walk['dogName'] as String? ?? 'Unknown';
    final ownerName = walk['ownerName'] as String? ?? 'Owner';
    final duration = walk['duration'] as int? ?? 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ink.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5CC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🐕', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dogName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    Text(
                      'Owner: $ownerName',
                      style: TextStyle(
                        fontSize: 13,
                        color: _ink.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'active' 
                      ? Colors.green.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status == 'active' ? 'In Progress' : 'Scheduled',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: status == 'active' ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: _ink.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text(
                '$duration minutes',
                style: TextStyle(
                  fontSize: 13,
                  color: _ink.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'active' ? Colors.red : _ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WalkerTrackingScreen(
                      walkId: walkId,
                      dogName: dogName,
                      isActive: status == 'active',
                    ),
                  ),
                );
              },
              child: Text(
                status == 'active' ? 'Continue Walk' : 'Start Walk',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _ink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.calendar_today,
              size: 60,
              color: _ink,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No walks scheduled',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new bookings',
            style: TextStyle(
              fontSize: 14,
              color: _ink.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}