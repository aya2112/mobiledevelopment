import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawpals/walker_profile.dart';
import 'package:pawpals/notifications_screen.dart';
import 'package:pawpals/booking_history.dart';
import 'package:pawpals/favorites_screen.dart';
import 'package:pawpals/live_tracking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeTab extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const HomeTab({super.key, this.onNavigateToTab});

  static const _ink = Color.fromARGB(255, 10, 51, 92);
  static const _warmOverlay = Color(0x20B67845);
 

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!.split(' ')[0];
    }
    return 'Guest';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF5E6D3),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _ink.withOpacity(0.08)),
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: _ink,
                          iconSize: 22,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Text(
                    "Hi, ${_getUserName()}! 👋",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _ink.withOpacity(0.08)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/pawpals_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5E6D3),
              Color(0xFFEAD5BE),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          color: _warmOverlay,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            "Ready to book a walk?",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _ink,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "🐾",
                            style: TextStyle(fontSize: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Find trusted walkers and keep your pup happy.",
                        style: TextStyle(
                          fontSize: 14,
                          color: _ink.withOpacity(0.85),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _PrimaryCard(
                  onPressed: () {
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(1); // Navigate to Book tab
                    }
                  },
                ),

                const SizedBox(height: 24),

                StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('walks')
        .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('status', whereIn: ['scheduled', 'active'])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const SizedBox.shrink(); // Hide the card if there's no booking
      }

      final walkDoc = snapshot.data!.docs.first;
      final data = walkDoc.data() as Map<String, dynamic>;

      return _UpcomingWalkCard(
        walkId: walkDoc.id,
        date: data['date'] ?? 'Today',
        time: data['scheduledTime'] ?? '4:00 PM',
        walkerName: data['walkerName'] ?? 'Sarah M.',
        dogName: data['dogName'] ?? 'Luna',
      );
    },
  ),

  const SizedBox(height: 24),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Text(
                          "Available today",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _ink,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text("🦴", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Showing all walkers...")),
                        );
                      },
                      child: Text(
                        "See all",
                        style: TextStyle(
                          color: _ink.withOpacity(0.8),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _WalkerTile(
                  name: "Sarah M.",
                  rating: 4.5,
                  distance: 0.9,
                  price: 20,
                  verified: true,
                  avatarColor: const Color(0xFFFFE5CC),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalkerProfile(
                          name: "Sarah M.",
                          rating: 4.5,
                          distance: 0.9,
                          price: 20,
                          verified: true,
                          avatarColor: Color(0xFFFFE5CC),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _WalkerTile(
                  name: "Michael L.",
                  rating: 4.7,
                  distance: 3.2,
                  price: 21,
                  verified: true,
                  avatarColor: const Color(0xFFCCE5FF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalkerProfile(
                          name: "Michael L.",
                          rating: 4.7,
                          distance: 3.2,
                          price: 21,
                          verified: true,
                          avatarColor: Color(0xFFCCE5FF),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _WalkerTile(
                  name: "Emily R.",
                  rating: 4.9,
                  distance: 1.5,
                  price: 25,
                  verified: false,
                  avatarColor: const Color(0xFFFFCCE5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalkerProfile(
                          name: "Emily R.",
                          rating: 4.9,
                          distance: 1.5,
                          price: 25,
                          verified: false,
                          avatarColor: Color(0xFFFFCCE5),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  children: const [
                    Text(
                      "Quick actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text("⚡", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.calendar_today_rounded,
                        label: "Appointments",
                        emoji: "📅",
                        onTap: () {
                          if (onNavigateToTab != null) {
                            onNavigateToTab!(1); // Navigate to Book tab
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: "Messages",
                        emoji: "💬",
                        onTap: () {
                          if (onNavigateToTab != null) {
                            onNavigateToTab!(2); // Navigate to Messages tab
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.history_rounded,
                        label: "History",
                        emoji: "📜",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookingHistoryScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.favorite_outline_rounded,
                        label: "Favorites",
                        emoji: "❤️",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FavoritesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryCard extends StatelessWidget {
  final VoidCallback onPressed;
  const _PrimaryCard({required this.onPressed});

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _ink,
            _ink.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                "🐕",
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Busy afternoon?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "We can take them for a walk.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              onPressed: onPressed,
              child: const Text(
                "Book Now",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingWalkCard extends StatelessWidget {
  final String date;
  final String time;
  final String walkerName;
  final String dogName;
  final String walkId;

  const _UpcomingWalkCard({
    super.key,
    required this.date,
    required this.time,
    required this.walkerName,
    required this.dogName,
    required this.walkId,
  });

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5CC).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD4A3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "⏰",
                  style: TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Upcoming Walk",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$date at $time",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "with $walkerName",
                          style: const TextStyle(
                            fontSize: 14,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: _ink.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveTrackingMapScreen(
                        walkId: walkId, 
                        walkerName: walkerName,
                        dogName: dogName,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _ink,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "View",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalkerTile extends StatelessWidget {
  final String name;
  final double rating;
  final double distance;
  final int price;
  final bool verified;
  final Color avatarColor;
  final VoidCallback onTap;

  const _WalkerTile({
    required this.name,
    required this.rating,
    required this.distance,
    required this.price,
    this.verified = false,
    required this.avatarColor,
    required this.onTap,
  });

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      "🐕",
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                if (verified)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified,
                        color: _ink,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "⭐ $rating • ${distance.toStringAsFixed(1)} mi away",
                    style: TextStyle(
                      fontSize: 13,
                      color: _ink.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$price/hr",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _ink.withOpacity(0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String emoji;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ink.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _ink,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}