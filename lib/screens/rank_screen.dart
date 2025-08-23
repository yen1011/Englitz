import 'package:flutter/material.dart';
import '../models/rank_user.dart';
import '../widgets/rank_item.dart';
import '../widgets/team_rank_item.dart';
import '../widgets/top_rankers.dart';
import '../widgets/top_teams.dart';
import '../services/user_service.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({Key? key}) : super(key: key);

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  int _selectedTabIndex = 0; // 0: 개인, 1: 팀

  // 샘플 데이터
  List<RankUser> get _individualUsers {
    final currentUserInfo = UserService.getCurrentUserInfo();
    final currentUserName = currentUserInfo['name'] as String;
    final currentUserOrg = currentUserInfo['organization'] as String;
    final currentUserTier = currentUserInfo['tier'] as String;
    
    return [
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
      // 현재 사용자 정보로 업데이트된 항목
      RankUser(
        rank: 135,
        name: currentUserName,
        affiliation: currentUserOrg,
        tier: currentUserTier.isNotEmpty ? currentUserTier[0] : 'G',
        tierColor: currentUserTier.isNotEmpty ? currentUserTier[0] : 'G',
        avatarUrl: '',
        isCurrentUser: true,
      ),
    ];
  }

  List<RankUser> get _teamUsers {
    final currentUserInfo = UserService.getCurrentUserInfo();
    final currentUserOrg = currentUserInfo['organization'] as String;
    
    return [
      RankUser(
        rank: 1,
        name: '삼성전자',
        affiliation: '삼성전자',
        tier: 'G',
        tierColor: 'G',
        avatarUrl: '',
      ),
      RankUser(
        rank: 2,
        name: 'LG전자',
        affiliation: 'LG전자',
        tier: 'S',
        tierColor: 'S',
        avatarUrl: '',
      ),
      RankUser(
        rank: 3,
        name: '현대자동차',
        affiliation: '현대자동차',
        tier: 'B',
        tierColor: 'B',
        avatarUrl: '',
      ),
      RankUser(
        rank: 4,
        name: 'SK하이닉스',
        affiliation: 'SK하이닉스',
        tier: 'B',
        tierColor: 'B',
        avatarUrl: '',
      ),
      RankUser(
        rank: 5,
        name: 'LG전자',
        affiliation: 'LG전자',
        tier: 'B',
        tierColor: 'B',
        avatarUrl: '',
      ),
      RankUser(
        rank: 6,
        name: '넥슨',
        affiliation: '넥슨',
        tier: 'S',
        tierColor: 'S',
        avatarUrl: '',
      ),
      RankUser(
        rank: 7,
        name: '카카오',
        affiliation: '카카오',
        tier: 'P',
        tierColor: 'P',
        avatarUrl: '',
      ),
      RankUser(
        rank: 8,
        name: '네이버',
        affiliation: '네이버',
        tier: 'M',
        tierColor: 'M',
        avatarUrl: '',
      ),
      RankUser(
        rank: 9,
        name: '쿠팡',
        affiliation: '쿠팡',
        tier: 'G',
        tierColor: 'G',
        avatarUrl: '',
      ),
      RankUser(
        rank: 10,
        name: '배달의민족',
        affiliation: '배달의민족',
        tier: 'B',
        tierColor: 'B',
        avatarUrl: '',
      ),
      // 현재 사용자 소속으로 업데이트된 항목
      RankUser(
        rank: 15,
        name: currentUserOrg,
        affiliation: currentUserOrg,
        tier: 'G',
        tierColor: 'G',
        avatarUrl: '',
        isCurrentUser: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final users = _selectedTabIndex == 0 ? _individualUsers : _teamUsers;
    
    // 상위 3명/3팀
    final topUsers = users.take(3).toList();
    
    // 나머지 사용자들
    final otherUsers = users.skip(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 타이틀과 탭
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [


                  // 탭 버튼들
                  Row(
                    children: [
                      // 개인 탭
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = 0;
                            });
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0
                                  ? const Color(0xFF788CC3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _selectedTabIndex == 0
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF788CC3)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
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
                      const SizedBox(width: 12),

                      // 팀 탭
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = 1;
                            });
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1
                                  ? const Color(0xFF788CC3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _selectedTabIndex == 1
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF788CC3)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
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
    );
  }
}
