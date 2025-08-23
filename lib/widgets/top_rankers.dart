import 'package:flutter/material.dart';
import '../models/rank_user.dart';

class TopRankers extends StatelessWidget {
  final List<RankUser> topUsers;

  const TopRankers({Key? key, required this.topUsers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topUsers.length < 3) return const SizedBox.shrink();

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // 1위 (중앙, 더 크게)
          Positioned(
            left:
                (MediaQuery.of(context).size.width - 84) /
                2.2, // 정확한 중앙 정렬 (아바타 크기 84px 고려)
            top: 20,
            child: _buildRanker(topUsers[0], 1, isFirst: true),
          ),

          // 2위 (왼쪽, 더 아래)
          Positioned(
            left: 20,
            top: 60,
            child: _buildRanker(topUsers[1], 2, isSecond: true),
          ),

          // 3위 (오른쪽, 더 아래)
          Positioned(
            left:
                MediaQuery.of(context).size.width -
                144, // 60 + 74(2위 아바타 크기) = 134
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
                image: user.avatarUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(user.avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user.avatarUrl.isEmpty
                  ? Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0] : '?',
                        style: const TextStyle(
                          fontSize: 32,
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
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        // 소속
        Text(
          user.affiliation,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
