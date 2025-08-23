import 'package:flutter/material.dart';
import '../models/rank_user.dart';

class TeamRankItem extends StatelessWidget {
  final RankUser team;
  final bool isCurrentTeam;

  const TeamRankItem({Key? key, required this.team, this.isCurrentTeam = false})
    : super(key: key);

  int _getTeamMemberCount(String affiliation) {
    // 각 소속별 인원수 (실제 데이터에 맞게 조정 가능)
    switch (affiliation) {
      case '삼성전자':
        return 45;
      case 'LG전자':
        return 38;
      case '현대자동차':
        return 32;
      case '이화여자대학교':
        return 28;
      case 'SK하이닉스':
        return 41;
      case '넥슨':
        return 25;
      case '카카오':
        return 52;
      case '네이버':
        return 48;
      case '쿠팡':
        return 35;
      case '배달의민족':
        return 29;
      case '삼성SDS':
        return 33;
      case 'KT':
        return 27;
      case '토스':
        return 31;
      case '당근마켓':
        return 24;
      case '라인':
        return 36;
      default:
        return 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTeam ? const Color(0xFFFDEC83) : Colors.white,
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
                '${team.rank}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrentTeam
                      ? const Color(0xFF303030)
                      : const Color(0xFF4F4F4F),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 팀 아바타
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: team.avatarUrl.isNotEmpty
                ? NetworkImage(team.avatarUrl)
                : null,
            child: team.avatarUrl.isEmpty
                ? Text(
                    team.affiliation.isNotEmpty ? team.affiliation[0] : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // 팀 정보 (소속 이름만 표시)
          Expanded(
            child: Text(
              team.affiliation,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrentTeam
                    ? const Color(0xFF303030)
                    : const Color(0xFF4F4F4f),
              ),
            ),
          ),

          // 소속 인원수
          Text(
            '${_getTeamMemberCount(team.affiliation)}명',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
