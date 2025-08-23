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

// 더미 데이터 생성 함수
List<RecentMatch> generateDummyMatches() {
  return [
    RecentMatch(
      opponentName: '김영희',
      opponentTier: 'GOLD 4',
      opponentRank: 135,
      opponentOrganization: '서울대학교',
      myCorrectAnswers: 26,
      totalQuestions: 30,
      isWin: true,
      matchDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RecentMatch(
      opponentName: '박철수',
      opponentTier: 'SILVER 2',
      opponentRank: 267,
      opponentOrganization: '삼성전자',
      myCorrectAnswers: 22,
      totalQuestions: 30,
      isWin: false,
      matchDate: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    RecentMatch(
      opponentName: '이지민',
      opponentTier: 'PLATINUM 1',
      opponentRank: 89,
      opponentOrganization: '연세대학교',
      myCorrectAnswers: 28,
      totalQuestions: 30,
      isWin: true,
      matchDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RecentMatch(
      opponentName: '최수진',
      opponentTier: 'GOLD 2',
      opponentRank: 156,
      opponentOrganization: 'LG화학',
      myCorrectAnswers: 18,
      totalQuestions: 30,
      isWin: false,
      matchDate: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    RecentMatch(
      opponentName: '한승우',
      opponentTier: 'SILVER 1',
      opponentRank: 201,
      opponentOrganization: '고려대학교',
      myCorrectAnswers: 25,
      totalQuestions: 30,
      isWin: true,
      matchDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RecentMatch(
      opponentName: '윤하늘',
      opponentTier: 'DIAMOND 3',
      opponentRank: 45,
      opponentOrganization: 'SK하이닉스',
      myCorrectAnswers: 20,
      totalQuestions: 30,
      isWin: false,
      matchDate: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
    ),
    RecentMatch(
      opponentName: '정민석',
      opponentTier: 'GOLD 1',
      opponentRank: 123,
      opponentOrganization: 'KAIST',
      myCorrectAnswers: 27,
      totalQuestions: 30,
      isWin: true,
      matchDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}
