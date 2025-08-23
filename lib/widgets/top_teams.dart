import 'package:flutter/material.dart';
import '../models/rank_user.dart';

class TopTeams extends StatelessWidget {
  final List<RankUser> topTeams;

  const TopTeams({Key? key, required this.topTeams}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topTeams.length < 3) return const SizedBox.shrink();

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // 1위 (중앙, 더 크게)
          Positioned(
            left:
                (MediaQuery.of(context).size.width - 84) /
                2.15, // 정확한 중앙 정렬 (아바타 크기 84px 고려)
            top: 20,
            child: _buildTeam(topTeams[0], 1, isFirst: true),
          ),

          // 2위 (왼쪽, 더 아래)
          Positioned(
            left: 40,
            top: 60,
            child: _buildTeam(topTeams[1], 2, isSecond: true),
          ),

          // 3위 (오른쪽, 더 아래)
          Positioned(
            left:
                MediaQuery.of(context).size.width -
                134, // 60 + 74(2위 아바타 크기) = 134
            top: 60,
            child: _buildTeam(topTeams[2], 3, isThird: true),
          ),
        ],
      ),
    );
  }

  Widget _buildTeam(
    RankUser team,
    int rank, {
    bool isFirst = false,
    bool isSecond = false,
    bool isThird = false,
  }) {
    double avatarSize = isFirst ? 84 : 74;
    double badgeSize = isFirst ? 28 : 28;

    return Column(
      children: [
        // 아바타와 순위 배지를 겹치게 표시
        Stack(
          clipBehavior: Clip.none, // 순위 배지가 잘리지 않도록
          children: [
            // 아바타
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF788CC3), width: 2),
                image: team.avatarUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(team.avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: team.avatarUrl.isEmpty
                  ? Center(
                      child: Text(
                        team.affiliation.isNotEmpty ? team.affiliation[0] : '?',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),

            // 순위 배지 (아바타와 살짝 겹치게)
            Positioned(
              bottom: isFirst ? -10 : -10, // 1위는 다른 위치
              right: isFirst ? 29 : 24, // 1위는 다른 위치
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF788CC3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 팀 이름 (소속 이름)
        Text(
          team.affiliation,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
