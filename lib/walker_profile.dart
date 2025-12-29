import 'package:flutter/material.dart';

class WalkerProfile extends StatelessWidget {
  final String name;
  final double rating;
  final double distance;
  final int price;
  final bool verified;
  final Color avatarColor;

  const WalkerProfile({
    super.key,
    required this.name,
    required this.rating,
    required this.distance,
    required this.price,
    this.verified = false,
    required this.avatarColor,
  });

  static const _ink = Color.fromARGB(255, 10, 51, 92);
  

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
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _ink.withOpacity(0.08)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border),
                          color: _ink,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to favorites! ❤️')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: avatarColor,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "🐕",
                                        style: TextStyle(fontSize: 50),
                                      ),
                                    ),
                                  ),
                                  if (verified)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.verified,
                                          color: _ink,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: _ink,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("⭐", style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 4),
                                  Text(
                                    "$rating",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: _ink,
                                    ),
                                  ),
                                  Text(
                                    " • ${distance.toStringAsFixed(1)} mi away",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _ink.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Stats Cards
                        Row(
                          children: [
                            _buildStatCard("156", "Walks", Icons.directions_walk),
                            const SizedBox(width: 12),
                            _buildStatCard("4.5", "Rating", Icons.star),
                            const SizedBox(width: 12),
                            _buildStatCard("3 yrs", "Experience", Icons.calendar_today),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // About Section
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _ink.withOpacity(0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    "About me",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: _ink,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text("✨", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "I'm a passionate dog lover with over 3 years of experience. I treat every pup like my own and ensure they get the exercise and attention they deserve. I'm available most afternoons and weekends!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _ink.withOpacity(0.8),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Services Section
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _ink.withOpacity(0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    "Services",
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
                              const SizedBox(height: 16),
                              _buildServiceItem("30-minute walk", "\$$price"),
                              _buildServiceItem("45-minute walk", "\$${(price * 1.5).toInt()}"),
                              _buildServiceItem("60-minute walk", "\$${price * 2}"),
                              _buildServiceItem("Multiple dogs", "+\$${(price * 0.5).toInt()} per dog"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reviews Section
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _ink.withOpacity(0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    "Reviews",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: _ink,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text("💬", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildReviewItem(
                                "John D.",
                                5,
                                "Amazing walker! My dog loves her.",
                                "2 days ago",
                              ),
                              const SizedBox(height: 12),
                              _buildReviewItem(
                                "Emma K.",
                                5,
                                "Very professional and caring.",
                                "1 week ago",
                              ),
                              const SizedBox(height: 12),
                              _buildReviewItem(
                                "Mike R.",
                                4,
                                "Great service, highly recommend!",
                                "2 weeks ago",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _ink.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          color: _ink,
                          iconSize: 24,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Opening chat with $name...')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _ink,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Booking with $name...')),
                              );
                            },
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ink.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _ink, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: _ink.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String service, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            service,
            style: TextStyle(
              fontSize: 14,
              color: _ink.withOpacity(0.8),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, int stars, String comment, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(
              5,
              (index) => Icon(
                index < stars ? Icons.star : Icons.star_border,
                size: 14,
                color: Colors.amber[700],
              ),
            ),
            const Spacer(),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: _ink.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          comment,
          style: TextStyle(
            fontSize: 13,
            color: _ink.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}