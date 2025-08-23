import 'package:flutter/material.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/game_mode_buttons.dart';
import '../widgets/stats_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 설정 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      // 설정 화면으로 이동
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Color(0xFF666666),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // 사용자 프로필 헤더
            const UserProfileHeader(),

            const SizedBox(height: 32),

            // 게임 모드 버튼들
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: GameModeButtons(),
            ),

            const SizedBox(height: 40),

            // 승률 통계 카드
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: StatsCard(),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
