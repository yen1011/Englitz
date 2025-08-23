import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../services/user_service.dart';
import 'home_screen.dart';
import 'rank_screen.dart';
import 'review_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentNavIndex = 1; // 홈 탭이 기본

  final List<Widget> _screens = [
    const RankScreen(),
    HomeScreen(key: _homeScreenKey),
    const ReviewScreen(),
  ];

  // 홈 화면에 접근하기 위한 GlobalKey
  static final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();

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
          
                    // 홈 탭으로 이동할 때 StatsCard 새로고침 및 새로운 게임 결과가 있으면 티어 업데이트
          if (index == 1) {
            // 홈 화면의 StatsCard 새로고침
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                _homeScreenKey.currentState?.setState(() {});
                
                // 새로운 게임 결과가 있을 때만 티어 업데이트
                if (UserService.hasNewGameResult) {
                  _homeScreenKey.currentState?.updateTierProgress();
                  UserService.hasNewGameResult = false; // 플래그 리셋
                }
              }
            });
          }
          
          // 리뷰 탭으로 이동할 때 ReviewScreen 새로고침
          if (index == 2) {
            // 리뷰 화면 새로고침을 위해 약간의 지연 후 실행
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {});
              }
            });
          }
        },
      ),
    );
  }
}
