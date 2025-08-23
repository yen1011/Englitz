import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_question.dart';
import '../models/game_result.dart';
import '../services/question_service.dart';
import '../services/review_service.dart';
import '../widgets/game_result_popup.dart';
import 'game_result_detail_screen.dart';

class NormalGameScreen extends StatefulWidget {
  const NormalGameScreen({Key? key}) : super(key: key);

  @override
  State<NormalGameScreen> createState() => _NormalGameScreenState();
}

class _NormalGameScreenState extends State<NormalGameScreen>
    with TickerProviderStateMixin {
  List<GameQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  double _timeLeft = 0.0;
  Timer? _timer;
  bool _isAnswered = false;
  int? _selectedAnswerIndex;
  bool _isCorrect = false;
  bool _isGameFinished = false;
  bool _isPlayerWon = false;

  // 게임 결과 저장용
  List<QuestionResult> _playerResults = [];
  List<QuestionResult> _opponentResults = [];

  // 애니메이션 컨트롤러
  late AnimationController _timerAnimationController;
  late AnimationController _questionAnimationController;
  late Animation<double> _timerAnimation;
  late Animation<double> _questionAnimation;

  // 상대방 정보 (실제로는 매칭 시스템에서 받아와야 함)
  GamePlayer _opponent = GamePlayer(name: '김철수', tier: '실버 2', score: 0);
  GamePlayer _player = GamePlayer(name: '서연수', tier: '실버 1', score: 0);

  // 상대방 점수 업데이트 타이머
  Timer? _opponentScoreTimer;

  // 팝업 표시 상태
  bool _showResultPopup = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGame();
    _startOpponentScoreUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _opponentScoreTimer?.cancel();
    _timerAnimationController.dispose();
    _questionAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeGame() async {
    await QuestionService.initializeData();

    // 20문제 생성 (실제로는 플레이어의 티어에 맞는 난이도로)
    _questions = QuestionService.generateQuestions(
      count: 20,
      difficulty: QuestionDifficulty.silver1,
    );

    _startQuestion();
  }

  void _startOpponentScoreUpdates() {
    _opponentScoreTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isGameFinished && mounted) {
        setState(() {
          // 상대방 점수 랜덤 업데이트 (실제로는 실시간으로 받아와야 함)
          final random = Random();
          if (random.nextDouble() < 0.3 && _opponent.score < 20) {
            // 30% 확률로 점수 증가, 최대 20개까지만
            _opponent = GamePlayer(
              name: _opponent.name,
              tier: _opponent.tier,
              score: _opponent.score + 1,
            );
          }
        });
      }
    });
  }

  void _startQuestion() {
    if (_currentQuestionIndex >= _questions.length) {
      _finishGame();
      return;
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    _timeLeft = currentQuestion.timeLimit.toDouble();
    _isAnswered = false;
    _selectedAnswerIndex = null;
    _isCorrect = false;

    // 타이머 애니메이션 시작
    _timerAnimation =
        Tween<double>(
          begin: currentQuestion.timeLimit.toDouble(),
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _timerAnimationController,
            curve: Curves.linear,
          ),
        );

    _timerAnimationController.duration = Duration(
      seconds: currentQuestion.timeLimit,
    );
    _timerAnimationController.reset();
    _timerAnimationController.forward();

    // 문제 애니메이션 시작
    _questionAnimationController.reset();
    _questionAnimationController.forward();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _timeLeft = _timerAnimation.value;
        });

        if (_timeLeft <= 0) {
          timer.cancel();
          _handleTimeout();
        }
      }
    });
  }

  void _handleTimeout() {
    if (!_isAnswered) {
      _selectAnswer(-1); // 시간 초과
    }
  }

  void _selectAnswer(int answerIndex) {
    if (_isAnswered) return;

    _timer?.cancel();
    _timerAnimationController.stop();
    _isAnswered = true;
    _selectedAnswerIndex = answerIndex;

    final currentQuestion = _questions[_currentQuestionIndex];
    _isCorrect = answerIndex == currentQuestion.correctAnswerIndex;

    // 플레이어 결과 저장
    _playerResults.add(
      QuestionResult(
        question: currentQuestion.question,
        correctAnswer:
            currentQuestion.options[currentQuestion.correctAnswerIndex],
        userAnswer: answerIndex >= 0
            ? currentQuestion.options[answerIndex]
            : null,
        isCorrect: _isCorrect,
        type: currentQuestion.type,
        explanation: currentQuestion.explanation,
      ),
    );

    if (_isCorrect) {
      _correctAnswers++;
      _player = GamePlayer(
        name: _player.name,
        tier: _player.tier,
        score: _player.score + 1,
      );
    } else {
      _wrongAnswers++;
      // 오답 단어를 ReviewService에 추가
      ReviewService.addWrongWord(
        currentQuestion.question,
        currentQuestion.options[currentQuestion.correctAnswerIndex],
        currentQuestion.type,
      );
    }

    // 상대방 결과 시뮬레이션 (랜덤)
    final random = Random();
    final opponentIsCorrect = random.nextBool();
    _opponentResults.add(
      QuestionResult(
        question: currentQuestion.question,
        correctAnswer:
            currentQuestion.options[currentQuestion.correctAnswerIndex],
        userAnswer: opponentIsCorrect
            ? currentQuestion.options[currentQuestion.correctAnswerIndex]
            : currentQuestion.options[random.nextInt(
                currentQuestion.options.length,
              )],
        isCorrect: opponentIsCorrect,
        type: currentQuestion.type,
        explanation: currentQuestion.explanation,
      ),
    );

    // 상대방 점수는 기존 랜덤 업데이트 로직 사용 (중복 방지)
    // 여기서는 점수를 올리지 않고, 기존 _startOpponentScoreUpdates() 로직만 사용

    setState(() {});

    // 1.5초 후 다음 문제로 자동 전환
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _currentQuestionIndex++;
        _startQuestion();
      }
    });
  }

  void _finishGame() {
    _isGameFinished = true;
    _isPlayerWon = _player.score > _opponent.score;
    _opponentScoreTimer?.cancel();

    // 팝업 표시
    setState(() {
      _showResultPopup = true;
    });
  }

  void _showResultDetail() {
    final gameResult = GameResult(
      player: _player,
      opponent: _opponent,
      isPlayerWon: _isPlayerWon,
      playerResults: _playerResults,
      opponentResults: _opponentResults,
      totalQuestions: _questions.length,
      gameMode: GameMode.normal,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameResultDetailScreen(gameResult: gameResult),
      ),
    );
  }

  void _onPopupClose() {
    setState(() {
      _showResultPopup = false;
    });
    // 팝업이 사라진 후 결과 상세 화면으로 이동
    _showResultDetail();
  }

  void _exitGame() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF788CC3)),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F9FF),
          body: SafeArea(
            child: _isGameFinished
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF788CC3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '결과를 확인하는 중...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildHeader(),
                      _buildPlayerInfo(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: AnimatedBuilder(
                            animation: _questionAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 0.8 + (_questionAnimation.value * 0.2),
                                child: Opacity(
                                  opacity: _questionAnimation.value,
                                  child: Column(
                                    children: [
                                      _buildQuestionArea(),
                                      _buildAnswerOptions(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      _buildTimer(),
                    ],
                  ),
          ),
        ),
        // 게임 결과 팝업
        if (_showResultPopup)
          GameResultPopup(
            player: _player,
            opponent: _opponent,
            playerScore: _player.score,
            opponentScore: _opponent.score,
            totalQuestions: _questions.length,
            isRankGame: false,
            onClose: _onPopupClose,
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF788CC3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_currentQuestionIndex + 1}/20',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // 플레이어 정보
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF788CC3), Color(0xFF6A7BB8)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF788CC3).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _player.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Text(
                        _player.tier,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF788CC3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_player.score}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          const SizedBox(width: 16),
          // 상대방 정보
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_opponent.score}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _opponent.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Text(
                        _opponent.tier,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea() {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getQuestionTypeColor(
                currentQuestion.type,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getQuestionTypeIcon(currentQuestion.type),
                  color: _getQuestionTypeColor(currentQuestion.type),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _getQuestionTypeText(currentQuestion.type),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getQuestionTypeColor(currentQuestion.type),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            currentQuestion.question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions() {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          currentQuestion.options.length,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildAnswerButton(index, currentQuestion.options[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(int index, String option) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == currentQuestion.correctAnswerIndex;

    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFFE8E8E8);
    Color textColor = const Color(0xFF333333);

    if (_isAnswered) {
      if (isCorrect) {
        backgroundColor = const Color(0xFF4CAF50);
        borderColor = const Color(0xFF4CAF50);
        textColor = Colors.white;
      } else if (isSelected && !isCorrect) {
        backgroundColor = const Color(0xFFF44336);
        borderColor = const Color(0xFFF44336);
        textColor = Colors.white;
      }
    } else if (isSelected) {
      backgroundColor = const Color(0xFF788CC3);
      borderColor = const Color(0xFF788CC3);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_timeLeft / currentQuestion.timeLimit).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.timer,
              color: _timeLeft <= 3
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF4CAF50),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '${_timeLeft.toInt()}초',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _timeLeft <= 3
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _timeLeft <= 3
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getQuestionTypeText(QuestionType type) {
    switch (type) {
      case QuestionType.word:
        return '단어';
      case QuestionType.grammar:
        return '문법';
      case QuestionType.dialog:
        return '대화';
    }
  }

  IconData _getQuestionTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.word:
        return Icons.translate;
      case QuestionType.grammar:
        return Icons.book;
      case QuestionType.dialog:
        return Icons.chat_bubble;
    }
  }

  Color _getQuestionTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.word:
        return const Color(0xFF4CAF50);
      case QuestionType.grammar:
        return const Color(0xFF2196F3);
      case QuestionType.dialog:
        return const Color(0xFFFF9800);
    }
  }
}
