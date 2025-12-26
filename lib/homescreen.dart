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

  late final List<Widget> _pages;

  final _titles = const [
    'PawPals',
    'Book a Walk',
    'Messages',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();

    // ✅ Pass callback to tabs that need to switch bottom-nav index
    _pages = [
      HomeTab(onNavigateToTab: _navigateToTab),
      BookTab(onNavigateToTab: _navigateToTab),
      const MessagesTab(),
      const ProfileTab(),
    ];
  }

  void _navigateToTab(int index) {
    if (index < 0 || index > 3) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,

      // ✅ Hide AppBar on Home (0) and Book (1) because those screens have their own design/header
      appBar: (_index == 0 || _index == 1)
          ? null
          : AppBar(
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
                    'assets/images/pawpals_logo.png',
                    height: 34,
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
        onDestinationSelected: _navigateToTab,
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
