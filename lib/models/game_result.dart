import 'game_question.dart';

enum GameMode { normal, rank }

class GameResult {
  final GamePlayer player;
  final GamePlayer opponent;
  final bool isPlayerWon;
  final List<QuestionResult> playerResults;
  final List<QuestionResult> opponentResults;
  final int totalQuestions;
  final GameMode gameMode;

  GameResult({
    required this.player,
    required this.opponent,
    required this.isPlayerWon,
    required this.playerResults,
    required this.opponentResults,
    required this.totalQuestions,
    required this.gameMode,
  });
}

class QuestionResult {
  final String question;
  final String correctAnswer;
  final String? userAnswer;
  final bool isCorrect;
  final QuestionType type;
  final String? explanation;

  QuestionResult({
    required this.question,
    required this.correctAnswer,
    this.userAnswer,
    required this.isCorrect,
    required this.type,
    this.explanation,
  });
}
