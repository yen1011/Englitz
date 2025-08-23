import 'package:flutter/material.dart';
import '../models/rank_user.dart';
import 'tier_badge.dart';

class RankItem extends StatelessWidget {
  final RankUser user;
  final bool isCurrentUser;

  const RankItem({Key? key, required this.user, this.isCurrentUser = false})
    : super(key: key);

  // 순위 변화 상태 (임시로 랜덤하게 설정, 실제로는 데이터에서 가져와야 함)
  String _getRankChange() {
    // 실제 구현에서는 user 객체에서 순위 변화 정보를 가져와야 함
    final changes = ['up', 'down', 'same'];
    return changes[user.rank % 3]; // 임시로 순위에 따라 결정
  }

  Color _getRankChangeColor(String change) {
    switch (change) {
      case 'up':
        return const Color(0xFF4CAF50); // 초록색
      case 'down':
        return const Color(0xFFF44336); // 빨간색
      case 'same':
        return const Color(0xFF9E9E9E); // 회색
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Widget _buildRankChangeIcon(String change) {
    IconData iconData;
    switch (change) {
      case 'up':
        iconData = Icons.keyboard_arrow_up;
        break;
      case 'down':
        iconData = Icons.keyboard_arrow_down;
        break;
      case 'same':
        iconData = Icons.remove;
        break;
      default:
        iconData = Icons.remove;
    }

    return Icon(iconData, color: _getRankChangeColor(change), size: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFFDEC83) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 순위 변화 아이콘
          _buildRankChangeIcon(_getRankChange()),
          const SizedBox(width: 8),

          // 순위 번호
          Container(
            width: 32,
            height: 32,
            child: Center(
              child: Text(
                '${user.rank}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser
                      ? const Color(0xFF303030)
                      : const Color(0xFF4F4F4F),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 아바타
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser
                        ? const Color(0xFF303030)
                        : const Color(0xFF4F4F4f),
                  ),
                ),
                if (user.affiliation.isNotEmpty)
                  Text(
                    user.affiliation,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),

          // 티어 뱃지
          TierBadge(tier: user.tier, tierColor: user.tierColor, size: 24),
        ],
      ),
    );
  }
}
