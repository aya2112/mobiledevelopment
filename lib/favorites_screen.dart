import 'package:flutter/material.dart';
import 'walker_profile.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const _ink = Color.fromARGB(255, 10, 51, 92);

  final List<Map<String, dynamic>> favorites = [
    {
      'name': 'Sarah M.',
      'rating': 4.5,
      'distance': 0.9,
      'price': 20,
      'verified': true,
      'color': Color(0xFFFFE5CC),
      'walks': 12,
    },
    {
      'name': 'Michael L.',
      'rating': 4.7,
      'distance': 3.2,
      'price': 21,
      'verified': true,
      'color': Color(0xFFCCE5FF),
      'walks': 8,
    },
    {
      'name': 'Emily R.',
      'rating': 4.9,
      'distance': 1.5,
      'price': 25,
      'verified': false,
      'color': Color(0xFFFFCCE5),
      'walks': 15,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          color: const Color(0x20B67845),
          child: SafeArea(
            child: Column(
              children: [
                // Custom AppBar
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Favorite Walkers',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                            Text(
                              '${favorites.length} walker${favorites.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: _ink.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: favorites.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final walker = favorites[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildWalkerCard(walker),
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

  Widget _buildWalkerCard(Map<String, dynamic> walker) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WalkerProfile(
              name: walker['name'],
              rating: walker['rating'],
              distance: walker['distance'],
              price: walker['price'],
              verified: walker['verified'],
              avatarColor: walker['color'],
            ),
          ),
        );
      },
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
                    color: walker['color'],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🐕', style: TextStyle(fontSize: 28)),
                  ),
                ),
                if (walker['verified'])
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: _ink,
                        size: 16,
                      ),
                    ),
                  ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 12,
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
                    walker['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "⭐ ${walker['rating']} • ${walker['distance']} mi away",
                    style: TextStyle(
                      fontSize: 13,
                      color: _ink.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${walker['walks']} walks completed",
                    style: TextStyle(
                      fontSize: 12,
                      color: _ink.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${walker['price']}/hr",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.favorite),
                  color: Colors.red,
                  iconSize: 20,
                  onPressed: () {
                    setState(() {
                      favorites.removeWhere((w) => w['name'] == walker['name']);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${walker['name']} removed from favorites'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
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
              Icons.favorite_border,
              size: 60,
              color: _ink,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add walkers to your favorites!',
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