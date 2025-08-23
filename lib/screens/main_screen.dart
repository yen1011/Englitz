import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'home_screen.dart';
import 'rank_screen.dart';
import 'review_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentNavIndex = 1; // 홈 탭이 기본

  final List<Widget> _screens = [
    const RankScreen(),
    const HomeScreen(),
    const ReviewScreen(),
  ];

  // 리뷰 탭으로 이동하는 메서드
  void navigateToReview() {
    setState(() {
      _currentNavIndex = 2; // 리뷰 탭 인덱스
    });
  }

  // 전역 접근을 위한 static 변수
  static MainScreenState? _instance;

  @override
  void initState() {
    super.initState();
    _instance = this;
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  // 전역에서 접근할 수 있는 메서드
  static void navigateToReviewTab() {
    _instance?.navigateToReview();
  }

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
