import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shoporbit/screens/user/order_history_screen.dart';
import 'package:shoporbit/screens/user/profile_screen.dart';
import 'package:shoporbit/screens/user/home_screen.dart';
import 'package:shoporbit/screens/user/wishlist_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const UserHomeScreen(),
    const WishlistScreen(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _iconColor(int index) {
    return _selectedIndex == index ? Colors.white : Colors.white54;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Theme.of(context).colorScheme.onPrimary,
        buttonBackgroundColor: Theme.of(context).colorScheme.onPrimary,
        height: 60,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: _iconColor(0)),
          Icon(Icons.favorite, size: 30, color: _iconColor(1)),
          Icon(Icons.history, size: 30, color: _iconColor(2)),
          Icon(Icons.person, size: 30, color: _iconColor(3)),
        ],
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        onTap: _onItemTapped,
        index: _selectedIndex,
      ),
    );
  }
}

