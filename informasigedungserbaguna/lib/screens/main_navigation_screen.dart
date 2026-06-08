import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:informasigedungserbaguna/providers/app_provider.dart';
import 'package:informasigedungserbaguna/screens/user_home_screen.dart';
import 'package:informasigedungserbaguna/screens/favorite_screen.dart';
import 'package:informasigedungserbaguna/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UserHomeScreen(),
    const FavoriteScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isEnglish =
        Provider.of<AppProvider>(context).locale.languageCode == 'en';
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.7),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: isEnglish ? 'Home' : 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: isEnglish ? 'Favorite' : 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: isEnglish ? 'Profile' : 'Profil',
          ),
        ],
      ),
    );
  }
}
