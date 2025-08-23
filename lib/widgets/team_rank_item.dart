import 'package:flutter/material.dart';
import '../models/rank_user.dart';

class TeamRankItem extends StatelessWidget {
  final RankUser team;
  final bool isCurrentTeam;

  const TeamRankItem({Key? key, required this.team, this.isCurrentTeam = false})
    : super(key: key);

  // 순위 변화 상태 (임시로 랜덤하게 설정, 실제로는 데이터에서 가져와야 함)
  String _getRankChange() {
    // 실제 구현에서는 team 객체에서 순위 변화 정보를 가져와야 함
    final changes = ['up', 'down', 'same'];
    return changes[team.rank % 3]; // 임시로 순위에 따라 결정
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
          // 순위 변화 아이콘
          _buildRankChangeIcon(_getRankChange()),
          const SizedBox(width: 8),

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
                        team.affiliation.isNotEmpty ? team.affiliation[0] : '?',
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
