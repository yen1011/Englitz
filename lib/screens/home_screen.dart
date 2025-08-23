import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/user_profile_header.dart';
import '../widgets/game_mode_buttons.dart';
import '../models/recent_match.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<RecentMatch> _recentMatches = generateDummyMatches();

  // 사용자가 선택할 수 있는 배경 이미지
  // TODO: 여기에 원하는 배경 이미지 경로를 설정하세요
  // 예: 'assets/images/background1.jpg', 'assets/images/background2.png' 등
  final String _userBackgroundImage = 'assets/images/default_avatar.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. 프로필/랭크/플레이 버튼 (스크롤되며 사라짐)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // 상단 배경 이미지가 있는 영역 (프로필 중간지점부터 위쪽)
                  Stack(
                    children: [
                      // 사용자 선택 배경 이미지 (프로필 중간지점까지만)
                      Container(
                        height: 140, // 프로필 중간지점까지의 높이 (70px + 상단 여백)
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_userBackgroundImage),
                            fit: BoxFit.cover,
                            opacity: 0.8, // 배경 이미지 투명도
                          ),
                        ),
                      ),
                      // 그라데이션 오버레이 (가독성을 위한 어두운 오버레이)
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                      // 상단 콘텐츠
                      Column(
                        mainAxisSize: MainAxisSize.min,
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
                  // 프로필 하단부 배경색 영역
                  Container(
                    height: 16, // 프로필과 게임 모드 버튼 사이 간격
                    color: const Color(0xFFF5F6FA),
                  ),
                  const SizedBox(height: 16),
                  // 게임 모드 버튼들
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: GameModeButtons(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // 2. 전체 전적 분석 카드 (Sticky Header)
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: StatsHeaderDelegate(),
            ),

            // 3. 최근 전적 리스트
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      '최근 전적',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 4. 최근 전적 리스트 아이템들
            _recentMatches.isEmpty
                ? SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverToBoxAdapter(
                      child: _buildEmptyMatchesWidget(),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildMatchCard(_recentMatches[index]);
                      }, childCount: _recentMatches.length),
                    ),
                  ),

            // 5. 하단 여백 (탭바와 겹치지 않도록)
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).viewPadding.bottom + 100,
              ),
            ),
          ],
        ),
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

// SliverPersistentHeader Delegate for Stats Card
class StatsHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 140.0;

  @override
  double get maxExtent => 180.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // shrinkOffset 기반으로 애니메이션 진행률 계산
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // pinned 상태일 때 그림자 효과
    final elevation = overlapsContent ? 12.0 + (progress * 4.0) : 0.0;
    final shadowOpacity = overlapsContent ? 0.12 + (progress * 0.06) : 0.05;

    return Container(
      color: const Color(0xFFF5F6FA), // 배경색으로 오버레이 방지
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 8.0 * (1 - progress * 0.5), // 고정시 여백 조금 줄임
        ),
        decoration: BoxDecoration(
          // 원래 그라데이션 배경 복원
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF788CC3), Color(0xFF9FA9D1)],
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(shadowOpacity),
              blurRadius: elevation,
              offset: Offset(0, elevation * 0.5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // 승률 원형 차트
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    // 배경 원
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    // 승률 원형 차트
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: CircularProgressPainter(
                        percentage: 0.75, // 75%
                        strokeWidth: 6,
                        progressColor: const Color(0xFF4A90E2),
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    // 중앙 텍스트
                    const Center(
                      child: Text(
                        '75%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // 승부 기록
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '15승 5패',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatItem('Word', '120', Colors.white),
                        const SizedBox(width: 16),
                        _buildStatItem('Grammar', '72', Colors.white),
                        const SizedBox(width: 16),
                        _buildStatItem('Dialog', '15', Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

// 원형 진행률 페인터
class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행률 호
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 시작 각도 (12시 방향)
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
