import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'memberships_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    MembershipsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.creditCard), label: 'Članarine'),
          NavigationDestination(icon: Icon(LucideIcons.user), label: 'Profil'),
        ],
      ),
    );
  }
}
