import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6D3), Color(0xFFEAD5BE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          color: const Color(0x20B67845),
          child: SafeArea(
            child: Column(
              children: [
                // --- Header ---
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _ink.withOpacity(0.08)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: _ink,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'My Walks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Live Booking List ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('walks')
                        .where('ownerId', isEqualTo: user?.uid) // <--- THIS FIXES THE ERROR
                        .orderBy('createdAt', descending: true) // Sort by newest first
                        .snapshots(),
                    builder: (context, snapshot) {
                      // 1. Loading State
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // 2. Error State
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "Error loading walks:\n${snapshot.error}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }

                      // 3. Empty State
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets, size: 60, color: _ink.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text(
                                "No walks booked yet",
                                style: TextStyle(
                                  color: _ink.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // 4. Data List
                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return _buildBookingCard(data);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> data) {
    // Safely handle data types
    final String walkerName = data['walkerName'] ?? 'Unknown Walker';
    final String date = data['date'] ?? 'Unknown Date';
    final String time = data['scheduledTime'] ?? ''; // Fixed key to match your upload
    final String status = data['status'] ?? 'Scheduled';
    final String dogNames = data['dogName'] ?? 'Dogs';
    
    // Determine status color
    Color statusColor = Colors.blue;
    Color statusBg = Colors.blue.withOpacity(0.1);
    if (status == 'Completed') {
      statusColor = Colors.green;
      statusBg = Colors.green.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ink.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Walker Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5CC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🐕', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              
              // Walker Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      walkerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$date • $time',
                      style: TextStyle(
                        fontSize: 13,
                        color: _ink.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Divider
          Divider(color: _ink.withOpacity(0.08)),
          
          const SizedBox(height: 8),
          
          // Dogs info
          Row(
            children: [
              Icon(Icons.pets, size: 16, color: _ink.withOpacity(0.5)),
              const SizedBox(width: 8),
              Text(
                dogNames,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _ink.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}