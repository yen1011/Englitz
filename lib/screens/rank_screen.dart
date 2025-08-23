import 'package:flutter/material.dart';
import '../models/rank_user.dart';
import '../widgets/rank_item.dart';
import '../widgets/team_rank_item.dart';
import '../widgets/top_rankers.dart';
import '../widgets/top_teams.dart';
import '../widgets/bottom_navigation.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({Key? key}) : super(key: key);

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  int _selectedTabIndex = 0; // 0: 개인, 1: 팀
  int _currentNavIndex = 1; // 리더보드 탭

  // 샘플 데이터
  final List<RankUser> _individualUsers = [
    RankUser(
      rank: 1,
      name: 'Bryan Wolf',
      affiliation: '삼성전자',
      tier: 'G',
      tierColor: 'G',
      avatarUrl: '',
    ),
    RankUser(
      rank: 2,
      name: 'Meghan Jes...',
      affiliation: 'LG전자',
      tier: 'S',
      tierColor: 'S',
      avatarUrl: '',
    ),
    RankUser(
      rank: 3,
      name: 'Alex Turner',
      affiliation: '현대자동차',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 4,
      name: 'Tamara Schmidt',
      affiliation: 'SK하이닉스',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 5,
      name: '민예은',
      affiliation: 'LG전자',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 6,
      name: 'Tamara Schmidt',
      affiliation: '넥슨',
      tier: 'S',
      tierColor: 'S',
      avatarUrl: '',
    ),
    RankUser(
      rank: 7,
      name: 'Tamara Schmidt',
      affiliation: '카카오',
      tier: 'P',
      tierColor: 'P',
      avatarUrl: '',
    ),
    RankUser(
      rank: 8,
      name: 'Tamara Schmidt',
      affiliation: '네이버',
      tier: 'M',
      tierColor: 'M',
      avatarUrl: '',
    ),
    RankUser(
      rank: 9,
      name: 'Tamara Schmidt',
      affiliation: '쿠팡',
      tier: 'G',
      tierColor: 'G',
      avatarUrl: '',
    ),
    RankUser(
      rank: 10,
      name: 'Tamara Schmidt',
      affiliation: '배달의민족',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 11,
      name: '김철수',
      affiliation: '삼성SDS',
      tier: 'S',
      tierColor: 'S',
      avatarUrl: '',
    ),
    RankUser(
      rank: 12,
      name: '이영희',
      affiliation: 'KT',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 13,
      name: '서연수',
      affiliation: '이화여자대학교',
      tier: 'G',
      tierColor: 'G',
      avatarUrl: '',
      isCurrentUser: true,
    ),
    RankUser(
      rank: 14,
      name: '박민수',
      affiliation: '네이버',
      tier: 'C',
      tierColor: 'C',
      avatarUrl: '',
    ),
    RankUser(
      rank: 15,
      name: '최지영',
      affiliation: '카카오',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 16,
      name: '정현우',
      affiliation: '쿠팡',
      tier: 'S',
      tierColor: 'S',
      avatarUrl: '',
    ),
    RankUser(
      rank: 17,
      name: '김서연',
      affiliation: '배달의민족',
      tier: 'C',
      tierColor: 'C',
      avatarUrl: '',
    ),
    RankUser(
      rank: 18,
      name: '이준호',
      affiliation: '토스',
      tier: 'G',
      tierColor: 'G',
      avatarUrl: '',
    ),
    RankUser(
      rank: 19,
      name: '박수진',
      affiliation: '당근마켓',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 20,
      name: '최동현',
      affiliation: '라인',
      tier: 'S',
      tierColor: 'S',
      avatarUrl: '',
    ),
  ];

  final List<RankUser> _teamUsers = [
    RankUser(
      rank: 1,
      name: 'Team Alpha',
      affiliation: '삼성전자',
      tier: 'G',
      tierColor: 'G',
      avatarUrl: '',
    ),
    RankUser(
      rank: 2,
      name: 'Team Beta',
      affiliation: 'LG전자',
      tier: 'S',
      tierColor: 'S',
      avatarUrl: '',
    ),
    RankUser(
      rank: 3,
      name: 'Team Gamma',
      affiliation: '현대자동차',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 4,
      name: 'Team Delta',
      affiliation: '이화여자대학교',
      tier: 'G',
      tierColor: 'G',
      avatarUrl: '',
      isCurrentUser: true,
    ),
    RankUser(
      rank: 5,
      name: 'Team Epsilon',
      affiliation: '넥슨',
      tier: 'S',
      tierColor: 'S',
      avatarUrl: '',
    ),
    RankUser(
      rank: 6,
      name: 'Team Zeta',
      affiliation: '카카오',
      tier: 'P',
      tierColor: 'P',
      avatarUrl: '',
    ),
    RankUser(
      rank: 7,
      name: 'Team Eta',
      affiliation: '네이버',
      tier: 'M',
      tierColor: 'M',
      avatarUrl: '',
    ),
    RankUser(
      rank: 8,
      name: 'Team Theta',
      affiliation: '쿠팡',
      tier: 'G',
      tierColor: 'G',
      avatarUrl: '',
    ),
    RankUser(
      rank: 9,
      name: 'Team Iota',
      affiliation: '배달의민족',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 10,
      name: 'Team Kappa',
      affiliation: '삼성SDS',
      tier: 'S',
      tierColor: 'S',
      avatarUrl: '',
    ),
    RankUser(
      rank: 11,
      name: 'Team Lambda',
      affiliation: 'KT',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 12,
      name: 'Team Mu',
      affiliation: 'SK하이닉스',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 13,
      name: 'Team Nu',
      affiliation: '토스',
      tier: 'C',
      tierColor: 'C',
      avatarUrl: '',
    ),
    RankUser(
      rank: 14,
      name: 'Team Xi',
      affiliation: '당근마켓',
      tier: 'B',
      tierColor: 'B',
      avatarUrl: '',
    ),
    RankUser(
      rank: 15,
      name: 'Team Omicron',
      affiliation: '라인',
      tier: 'S',
      tierColor: 'S',
      avatarUrl: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUsers = _selectedTabIndex == 0 ? _individualUsers : _teamUsers;
    final topUsers = currentUsers.take(3).toList();
    final otherUsers = currentUsers.skip(3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 탭
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0
                              ? const Color(0xFF788CC3)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '개인',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _selectedTabIndex == 0
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1
                              ? const Color(0xFF788CC3)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '팀',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _selectedTabIndex == 1
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 상위 3명/3팀
            if (_selectedTabIndex == 0)
              TopRankers(topUsers: topUsers)
            else
              TopTeams(topTeams: topUsers),

            // 배경색이 있는 영역
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFCCD0EC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 현재 사용자/팀 순위
                    if (otherUsers.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: _selectedTabIndex == 0
                            ? RankItem(
                                user: otherUsers.firstWhere(
                                  (user) => user.isCurrentUser,
                                  orElse: () => otherUsers.first,
                                ),
                                isCurrentUser: true,
                              )
                            : TeamRankItem(
                                team: otherUsers.firstWhere(
                                  (team) => team.isCurrentUser,
                                  orElse: () => otherUsers.first,
                                ),
                                isCurrentTeam: true,
                              ),
                      ),

                    // 나머지 순위 목록
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: otherUsers.length,
                        itemBuilder: (context, index) {
                          final user = otherUsers[index];
                          return _selectedTabIndex == 0
                              ? RankItem(
                                  user: user,
                                  isCurrentUser: user.isCurrentUser,
                                )
                              : TeamRankItem(
                                  team: user,
                                  isCurrentTeam: user.isCurrentUser,
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          // 여기서 실제 네비게이션 처리
        },
      ),
    );
  }
}
