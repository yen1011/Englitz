import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'home_screen.dart';
import 'rank_screen.dart';
import 'review_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentNavIndex = 1; // 홈 탭이 기본

  final List<Widget> _screens = [
    const RankScreen(),
    const HomeScreen(),
    const ReviewScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentNavIndex, children: _screens),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }
}
