import '../services/user_service.dart';

class RecentMatch {
  final String opponentName;
  final String opponentTier;
  final int opponentRank;
  final String opponentOrganization;
  final int myCorrectAnswers;
  final int totalQuestions;
  final bool isWin;
  final DateTime matchDate;

  RecentMatch({
    required this.opponentName,
    required this.opponentTier,
    required this.opponentRank,
    required this.opponentOrganization,
    required this.myCorrectAnswers,
    required this.totalQuestions,
    required this.isWin,
    required this.matchDate,
  });

  double get correctRate => myCorrectAnswers / totalQuestions;
}

// 실제 데이터 생성 함수
List<RecentMatch> generateRecentMatches() {
  final recentMatchesData = UserService.recentMatches;
  
  if (recentMatchesData.isEmpty) {
    // 실제 데이터가 없으면 빈 리스트 반환
    return [];
  }
  
  return recentMatchesData.map((matchData) {
    return RecentMatch(
      opponentName: matchData['opponentName'] as String,
      opponentTier: matchData['opponentTier'] as String,
      opponentRank: matchData['opponentRank'] as int,
      opponentOrganization: matchData['opponentOrganization'] as String,
      myCorrectAnswers: matchData['myCorrectAnswers'] as int,
      totalQuestions: matchData['totalQuestions'] as int,
      isWin: matchData['isWin'] as bool,
      matchDate: matchData['matchDate'] as DateTime,
    );
  }).toList();
}
