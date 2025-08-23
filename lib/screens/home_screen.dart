import 'package:flutter/material.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/game_mode_buttons.dart';
import '../widgets/stats_card.dart';
import '../models/recent_match.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<RecentMatch> _recentMatches = generateDummyMatches();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 배경 이미지가 있는 영역
              Stack(
                children: [
                  // 배경 이미지
                  Container(
                    height: 200, // 프로필 중간 지점까지의 높이
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/default_avatar.png',
                        ), // 배경 이미지 경로
                        fit: BoxFit.cover,
                        opacity: 0.3, // 투명도 조절
                      ),
                    ),
                  ),
                  // 그라데이션 오버레이 (선택사항)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // 상단 콘텐츠
                  Column(
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
                      const Center(child: UserProfileHeader()),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 게임 모드 버튼들
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: GameModeButtons(),
              ),

              const SizedBox(height: 40),

              // 승률 통계 카드부터 그라데이션 배경 적용
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF788CC3),
                      Color(0xFF9FA9D1),
                      Color(0xFFC8D0E5),
                      Color(0xFFE8ECF4),
                      Color(0xFFF8F9FF),
                      Colors.white,
                    ],
                    stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // 승률 통계 카드
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: StatsCard(),
                    ),

                    const SizedBox(height: 40),

                    // 최근 전적 섹션
                    _buildRecentMatchesSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMatchesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 제목
          const Text(
            '최근 전적',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),

          // 전적 리스트
          _recentMatches.isEmpty
              ? _buildEmptyMatchesWidget()
              : _buildRecentMatchesList(),
        ],
      ),
    );
  }

  Widget _buildEmptyMatchesWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.history, size: 48, color: Color(0xFFCCCCCC)),
          SizedBox(height: 16),
          Text(
            '최근 전적이 없습니다',
            style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMatchesList() {
    return Column(
      children: [
        ..._recentMatches.map((match) => _buildMatchCard(match)),
        const SizedBox(height: 20), // 하단 여백
      ],
    );
  }

  Widget _buildMatchCard(RecentMatch match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 상대방 정보
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      match.opponentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      match.opponentOrganization,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: match.opponentTier,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTierColor(match.opponentTier),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(
                        text: ' · ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                      TextSpan(
                        text: '${match.opponentRank}위',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 결과 정보
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${match.myCorrectAnswers}/${match.totalQuestions}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF788CC3),
                  ),
                ),
                const SizedBox(height: 6),

                // 진행바
                Container(
                  width: 80,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: match.correctRate,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF788CC3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 승패 표시
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: Image.asset(
              'assets/icons/crown.png', // 같은 이미지 파일 사용
              width: 20,
              height: 20,
              color: match.isWin
                  ? null // 승리시 원본 색상 유지
                  : const Color(0xFF999999), // 패배시에만 그레이색
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    final tierName = tier.split(' ')[0].toUpperCase();
    switch (tierName) {
      case 'BRONZE':
        return const Color(0xFF8B5A3C);
      case 'SILVER':
        return const Color(0xFF8E9297);
      case 'GOLD':
        return const Color(0xFFD4AF37);
      case 'PLATINUM':
        return const Color(0xFF00E5FF);
      case 'DIAMOND':
        return const Color(0xFF8E24AA);
      case 'MASTER':
        return const Color(0xFFFF1744);
      case 'GRANDMASTER':
        return const Color(0xFF424242);
      case 'CHALLENGER':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF999999);
    }
  }
}
