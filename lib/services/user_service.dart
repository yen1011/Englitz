class UserService {
  static String _userName = '김명수';
  static String _userOrganization = '서울대학교 영어영문학과';
  static String _currentTier = 'GOLD1';
  
  // 게임 통계
  static int _totalWins = 0;
  static int _totalLosses = 0;
  static int _wordCorrect = 0;
  static int _grammarCorrect = 0;
  static int _dialogCorrect = 0;
  
  // 티어 진행률 (0.0 ~ 1.0)
  static double _tierProgress = 0.0;
  
  // 게임 결과가 기록되었는지 추적
  static bool _hasNewGameResult = false;

  // 사용자 정보 getter
  static String get userName => _userName;
  static String get userOrganization => _userOrganization;
  static String get currentTier => _currentTier;

  // 사용자 정보 업데이트
  static void updateUserInfo(String name, String organization) {
    _userName = name;
    _userOrganization = organization;
  }

  // 티어 업데이트
  static void updateTier(String tier) {
    _currentTier = tier;
  }

  // 현재 사용자 정보를 RecentMatch에서 사용할 수 있도록 제공
  static Map<String, dynamic> getCurrentUserInfo() {
    return {
      'name': _userName,
      'organization': _userOrganization,
      'tier': _currentTier,
    };
  }

  // 게임 통계 getter
  static int get totalWins => _totalWins;
  static int get totalLosses => _totalLosses;
  static int get wordCorrect => _wordCorrect;
  static int get grammarCorrect => _grammarCorrect;
  static int get dialogCorrect => _dialogCorrect;
  
  // 티어 진행률 getter/setter
  static double get tierProgress => _tierProgress;
  static set tierProgress(double value) => _tierProgress = value;
  
  // 게임 결과 플래그 getter/setter
  static bool get hasNewGameResult => _hasNewGameResult;
  static set hasNewGameResult(bool value) => _hasNewGameResult = value;

  // 승률 계산
  static double get winRate {
    final total = _totalWins + _totalLosses;
    if (total == 0) return 0.0;
    return _totalWins / total;
  }

  // 게임 결과 기록
  static void recordGameResult(bool isWin, Map<String, int> questionStats) {
    if (isWin) {
      _totalWins++;
    } else {
      _totalLosses++;
    }
    
    _wordCorrect += questionStats['word'] ?? 0;
    _grammarCorrect += questionStats['grammar'] ?? 0;
    _dialogCorrect += questionStats['dialog'] ?? 0;
    
    // 새로운 게임 결과가 있음을 표시
    _hasNewGameResult = true;
    
    // 디버그 로그
    print('UserService: Game result recorded - Win: $isWin, Stats: $questionStats');
    print('UserService: Total wins: $_totalWins, Total losses: $_totalLosses');
    print('UserService: Word correct: $_wordCorrect, Grammar correct: $_grammarCorrect, Dialog correct: $_dialogCorrect');
  }

  // 티어 하락 (패배 시)
  static void decreaseTierProgress() {
    // 현재 티어에서 10% 하락
    // 실제로는 더 복잡한 로직이 필요할 수 있음
    print('UserService: Tier progress decreased by 10%');
  }

  // 티어 상승 (승리 시)
  static void increaseTierProgress() {
    // 현재 진행률에서 10% 증가
    _tierProgress = (_tierProgress + 0.1).clamp(0.0, 1.0);
    print('UserService: Tier progress increased by 10% to $_tierProgress');
  }
}
