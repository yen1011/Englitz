enum QuestionType { word, grammar, dialog }

enum QuestionDifficulty {
  bronze1,
  bronze2,
  bronze3,
  silver1,
  silver2,
  silver3,
  gold1,
  gold2,
  gold3,
  platinum1,
  platinum2,
  platinum3,
  diamond1,
  diamond2,
  diamond3,
  master1,
  master2,
  master3,
}

class GameQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final QuestionType type;
  final QuestionDifficulty difficulty;
  final String? explanation;

  GameQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.type,
    required this.difficulty,
    this.explanation,
  });

  int get timeLimit {
    switch (type) {
      case QuestionType.word:
        return 3; // 3초
      case QuestionType.grammar:
        return 8; // 8초 (3초 증가)
      case QuestionType.dialog:
        return 8; // 8초 (3초 증가)
    }
  }

  String get correctAnswer {
    return options[correctAnswerIndex];
  }
}

class GamePlayer {
  final String name;
  final String tier;
  int score;
  final String? avatarUrl;

  GamePlayer({
    required this.name,
    required this.tier,
    required this.score,
    this.avatarUrl,
  });
}

class GameState {
  final int currentQuestionIndex;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final GamePlayer player;
  final GamePlayer opponent;
  final bool isGameFinished;
  final bool isPlayerWon;

  GameState({
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.player,
    required this.opponent,
    required this.isGameFinished,
    required this.isPlayerWon,
  });

  GameState copyWith({
    int? currentQuestionIndex,
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    GamePlayer? player,
    GamePlayer? opponent,
    bool? isGameFinished,
    bool? isPlayerWon,
  }) {
    return GameState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      player: player ?? this.player,
      opponent: opponent ?? this.opponent,
      isGameFinished: isGameFinished ?? this.isGameFinished,
      isPlayerWon: isPlayerWon ?? this.isPlayerWon,
    );
  }
}
