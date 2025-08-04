import 'package:flutter/material.dart';
import '../../features/home/home_screen.dart';
import '../../features/plan/plan_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/more/more_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    PlanScreen(),
    FavoritesScreen(),
    MoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'ابدأ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: 'خطط',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'المفضل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'المزيد',
          ),
        ],
      ),
    );
  }
} 