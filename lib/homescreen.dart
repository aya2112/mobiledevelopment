import 'package:flutter/material.dart';
import 'colors.dart';
import 'tabs/hometab.dart';
import 'tabs/booktab.dart';
import 'tabs/messagestab.dart';
import 'tabs/profiletab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  final _pages = const [
    HomeTab(),
    BookTab(),
    MessagesTab(),
    ProfileTab(),
  ];

  final _titles = const [
    'PawPals',
    'Book a Walk',
    'Messages',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          _titles[_index],
          style: const TextStyle(
            color: _ink,
            fontWeight: FontWeight.bold,
          ),
        ),
       actions: [
  Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Image.asset(
      'assets/images/pawpals_logo.png',   // your existing logo file
      height: 34,                         // adjust size
      fit: BoxFit.contain,
    ),
  ),
],


      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.cream,
        indicatorColor: AppColors.mutedTeal.withOpacity(0.15),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Book',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
