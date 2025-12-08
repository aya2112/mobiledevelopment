import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const _ink   = Color.fromARGB(255, 10, 51, 92);
  static const _brown = Color(0xFF6B3E22);
  static const _teal  = Color(0xFF6FB3A9);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        // --- Greeting ---
        Text(
          'Good morning 👋',
          style: TextStyle(
            fontSize: 16,
            color: _ink.withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ready for today’s walks?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 20),

        // --- Next walk card ---
        const _NextWalkCard(),
        const SizedBox(height: 18),

        // --- Quick actions ---
        const Text(
          'Quick actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.search,
                label: 'Find walker',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.calendar_today_outlined,
                label: 'Schedule walk',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.my_location_outlined,
                label: 'Live tracking',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- Recommended walkers ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Recommended walkers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            Text(
              'See all',
              style: TextStyle(
                fontSize: 14,
                color: _teal,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _WalkerCard(
                name: 'Lina Qasem',
                rating: 4.9,
                walks: 120,
                pricePerWalk: 7,
              ),
              SizedBox(width: 12),
              _WalkerCard(
                name: 'Omar Haddad',
                rating: 4.8,
                walks: 98,
                pricePerWalk: 6,
              ),
              SizedBox(width: 12),
              _WalkerCard(
                name: 'Sara N.',
                rating: 4.7,
                walks: 87,
                pricePerWalk: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- Summary ---
        const Text(
          'Today’s summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(
              child: _StatPill(
                label: 'Walks booked',
                value: '2',
                icon: Icons.event_available,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatPill(
                label: 'Minutes walked',
                value: '45',
                icon: Icons.timer_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------- helper widgets ----------------

class _NextWalkCard extends StatelessWidget {
  const _NextWalkCard();

  static const _ink   = Color.fromARGB(255, 10, 51, 92);
  static const _brown = Color(0xFF6B3E22);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE9DED0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.pets, color: _ink, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next walk',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Today · 4:30 PM · with Luna 🐶',
                  style: TextStyle(
                    fontSize: 13,
                    color: _ink.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: _brown,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              // TODO: go to walk details
            },
            child: const Text(
              'Details',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: handle tap
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _ink),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink.withOpacity(0.9),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkerCard extends StatelessWidget {
  final String name;
  final double rating;
  final int walks;
  final int pricePerWalk;

  const _WalkerCard({
    required this.name,
    required this.rating,
    required this.walks,
    required this.pricePerWalk,
  });

  static const _ink   = Color.fromARGB(255, 10, 51, 92);
  static const _brown = Color(0xFF6B3E22);
  static const _teal  = Color(0xFF6FB3A9);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar + rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE9DED0),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: _ink,
                        ),
                      ),
                      Text(
                        ' · $walks walks',
                        style: TextStyle(
                          fontSize: 11,
                          color: _ink.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pricePerWalk JOD',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _brown,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Colors.white,
                  backgroundColor: _teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // TODO: book this walker
                },
                child: const Text(
                  'Book',
                  style: TextStyle(
                    fontSize: 11,
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

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE9DED0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 18, color: _ink),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: _ink.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
