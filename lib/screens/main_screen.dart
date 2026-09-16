import 'package:expense_tracker/screens/home/home_screen.dart';
import 'package:expense_tracker/screens/profile/profile_screen.dart';
import 'package:expense_tracker/screens/stats/statistics_screen.dart';
import 'package:expense_tracker/screens/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const StatisticsScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF00885d),
        unselectedItemColor: Colors.grey,

        selectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
