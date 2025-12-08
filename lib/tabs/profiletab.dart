import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const _ink   = Color.fromARGB(255, 10, 51, 92);
  static const _brown = Color(0xFF6B3E22);
  static const _teal  = Color(0xFF6FB3A9);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _ProfileHeader(),
        const SizedBox(height: 24),

        // --- Your dogs ---
        const Text(
          'Your dogs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _DogCard(
                name: 'Luna',
                breed: 'Golden Retriever',
                age: '2 yrs',
              ),
              SizedBox(width: 12),
              _DogCard(
                name: 'Milo',
                breed: 'Mixed',
                age: '3 yr',
              ),
              SizedBox(width: 12),
              _AddDogCard(),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // --- Account section ---
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        const SizedBox(height: 10),

        Container(
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
          child: const Column(
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Edit profile',
                subtitle: 'Name, photo, contact info',
              ),
              Divider(height: 0),
              _SettingsTile(
                icon: Icons.pets_outlined,
                title: 'Dog profiles',
                subtitle: 'Add or update your dogs',
              ),
              Divider(height: 0),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Push, email & SMS alerts',
              ),
              Divider(height: 0),
              _SettingsTile(
                icon: Icons.payment_outlined,
                title: 'Payment methods',
                subtitle: 'Cards & receipts',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // --- Support section ---
        const Text(
          'Support',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        const SizedBox(height: 10),

        Container(
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
          child: const Column(
            children: [
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Help & FAQ',
              ),
              Divider(height: 0),
              _SettingsTile(
                icon: Icons.mail_outline,
                title: 'Contact support',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // --- Logout ---
        Center(
          child: TextButton.icon(
            onPressed: () {
              // TODO: hook up to auth sign-out
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out (demo)')),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text(
              'Log out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ------------ header ------------

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  static const _ink = Color.fromARGB(255, 10, 51, 92);
  static const _teal = Color(0xFF6FB3A9);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 38,
          backgroundColor: Color(0xFFE9DED0),
          child: Text(
            'A',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: _ink,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Aya Abbadi', // later: read from logged-in user
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'aya@example.com',
          style: TextStyle(
            fontSize: 13,
            color: _ink.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _teal.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.verified, size: 16, color: _teal),
              SizedBox(width: 6),
              Text(
                'Pet parent since 2024',
                style: TextStyle(
                  fontSize: 12,
                  color: _teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------ dog cards ------------

class _DogCard extends StatelessWidget {
  final String name;
  final String breed;
  final String age;

  const _DogCard({
    required this.name,
    required this.breed,
    required this.age,
  });

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFE9DED0),
                child: Icon(Icons.pets, color: _ink),
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
                  Text(
                    breed,
                    style: TextStyle(
                      fontSize: 11,
                      color: _ink.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            age,
            style: TextStyle(
              fontSize: 12,
              color: _ink.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddDogCard extends StatelessWidget {
  const _AddDogCard();

  @override
  Widget build(BuildContext context) {
    const ink = Color.fromARGB(255, 10, 51, 92);
    const teal = Color(0xFF6FB3A9);

    return InkWell(
      onTap: () {
        // TODO: open "Add dog" flow
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add dog (demo)')),
        );
      },
      child: DottedBorderContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: teal),
            SizedBox(height: 4),
            Text(
              'Add dog',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------ dotted container ------------

class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  const DottedBorderContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromARGB(60, 10, 51, 92);

    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: 1,
          style: BorderStyle.solid, // placeholder; real dotted needs package
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}

// ------------ settings tiles ------------

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFE9DED0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _ink, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _ink,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: _ink.withOpacity(0.7),
              ),
            ),
      onTap: () {
      },
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: Colors.grey,
      ),
    );
  }
}
