import 'package:flutter/material.dart';
import '../models/rank_user.dart';

class TopRankers extends StatelessWidget {
  final List<RankUser> topUsers;

  const TopRankers({super.key, required this.topUsers});

  @override
  Widget build(BuildContext context) {
    if (topUsers.length < 3) return const SizedBox.shrink();

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // 1위 (정확히 중앙)
          Positioned(
            left: 0,
            right: 0,
            top: 20,
            child: Center(child: _buildRanker(topUsers[0], 1, isFirst: true)),
          ),

          // 2위 (1등 기준 왼쪽 일정 간격)
          Positioned(
            left: 23, // 1등 중앙에서 왼쪽으로 190px
            top: 60,
            child: _buildRanker(topUsers[1], 2, isSecond: true),
          ),

          // 3위 (1등 기준 오른쪽 일정 간격)
          Positioned(
            left: 275, // 1등 중앙에서 오른쪽으로 190px
            top: 60,
            child: _buildRanker(topUsers[2], 3, isThird: true),
          ),
        ],
      ),
    );
  }

  Widget _buildRanker(
    RankUser user,
    int rank, {
    bool isFirst = false,
    bool isSecond = false,
    bool isThird = false,
  }) {
    double avatarSize = isFirst ? 90 : 74; // 1등은 더 크게
    double badgeSize = isFirst ? 32 : 28; // 1등 배지도 더 크게

    // 순위별 테두리 색상과 크기 차별화
    Color borderColor;
    double borderWidth;
    if (isFirst) {
      borderColor = const Color(0xFFF4C135); // 금색
      borderWidth = 4.0; // 더 두꺼운 테두리
    } else if (isSecond) {
      borderColor = const Color(0xFFC6C6C6); // 은색
      borderWidth = 3.0;
    } else {
      borderColor = const Color(0xFFAC865F); // 동색
      borderWidth = 2.0;
    }

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
                border: Border.all(color: borderColor, width: borderWidth),
                image: user.avatarUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(user.avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isFirst ? 0.25 : 0.15),
                    blurRadius: isFirst ? 15 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: user.avatarUrl.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF788CC3),
                            const Color(0xFFAEB4D8),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0] : '?',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
                  color: borderColor, // 테두리 색상과 동일하게
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

            // 1등 왕관 (가장 위에 표시)
            if (isFirst)
              Positioned(
                top: -15,
                left: avatarSize / 2 - 20,
                child: Container(
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/icons/crown.png',
                    width: 40,
                    height: 30,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // 이름
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        // 소속
        Text(
          user.affiliation,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
