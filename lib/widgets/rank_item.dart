import 'package:flutter/material.dart';
import '../models/rank_user.dart';
import 'tier_badge.dart';

class RankItem extends StatelessWidget {
  final RankUser user;
  final bool isCurrentUser;

  const RankItem({Key? key, required this.user, this.isCurrentUser = false})
    : super(key: key);

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
                ? Text(
                    user.name.isNotEmpty ? user.name[0] : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
