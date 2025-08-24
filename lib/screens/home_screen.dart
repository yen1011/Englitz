import 'package:flutter/material.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/game_mode_buttons.dart';
import '../widgets/stats_card.dart';
import '../models/recent_match.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<RecentMatch> _recentMatches = generateRecentMatches();
  final GlobalKey<UserProfileHeaderState> _profileHeaderKey = GlobalKey<UserProfileHeaderState>();
  final GlobalKey<StatsCardState> _statsCardKey = GlobalKey<StatsCardState>();

  void updateRecentMatches() {
    setState(() {
      _recentMatches = generateRecentMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 배경 사각형 영역 (상태바 영역까지 포함)
            Stack(
              children: [
                // 배경 사각형 (최상단부터 프로필 이미지 중간까지)
                Container(
                  height: 230 + MediaQuery.of(context).padding.top, // 상태바 영역까지 포함
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white, // 흰색 배경
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x1A000000), // 10% 투명도의 검은색
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),

                // 상단 콘텐츠
                Column(
                  children: [
                    // 상태바 영역을 위한 패딩 (줄임)
                    SizedBox(height: MediaQuery.of(context).padding.top - 20),
                    // 상단 설정 버튼과 프로필 수정 버튼
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 프로필 수정 버튼
                          IconButton(
                            onPressed: () {
                              _showProfileEditDialog();
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFF666666),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 설정 버튼
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
                    Center(child: UserProfileHeader(key: _profileHeaderKey)),
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
                    Color(0xFFAEB4D8),
                    Color(0xFFB8BEDE),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: StatsCard(key: _statsCardKey),
                  ),

                  const SizedBox(height: 40),

                  // 최근 전적 섹션
                  _buildRecentMatchesSection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
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

  // 프로필 수정 다이얼로그 표시
  void _showProfileEditDialog() {
    final currentName = UserService.userName;
    final currentOrganization = UserService.userOrganization;
    
    final nameController = TextEditingController(text: currentName);
    final organizationController = TextEditingController(text: currentOrganization);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '프로필 수정',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF788CC3), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: organizationController,
                decoration: const InputDecoration(
                  labelText: '소속',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF788CC3), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Color(0xFF718096)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                final newOrganization = organizationController.text.trim();
                
                if (newName.isNotEmpty && newOrganization.isNotEmpty) {
                  _profileHeaderKey.currentState?.updateUserInfo(newName, newOrganization);
                  UserService.updateUserInfo(newName, newOrganization);
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('프로필이 수정되었습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('이름과 소속을 모두 입력해주세요.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF788CC3),
                foregroundColor: Colors.white,
              ),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 티어 하락 테스트용 메서드 (개발 중에만 사용)
  void _testTierDecrease() {
    _profileHeaderKey.currentState?.decreaseTierProgress();
  }

  // 티어 진행률 업데이트를 위한 public 메서드
  void updateTierProgress() {
    _profileHeaderKey.currentState?.increaseTierProgress();
  }
}
