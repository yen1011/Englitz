import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_question.dart';
import '../models/game_result.dart';

import '../services/question_service.dart';
import '../services/review_service.dart';
import '../widgets/game_result_popup.dart';
import 'game_result_detail_screen.dart';

class RankGameScreen extends StatefulWidget {
  const RankGameScreen({Key? key}) : super(key: key);

  @override
  State<RankGameScreen> createState() => _RankGameScreenState();
}

class _RankGameScreenState extends State<RankGameScreen>
    with TickerProviderStateMixin {
  // 게임 상태
  bool _isGameStarted = false;
  bool _isGameFinished = false;
  bool _isPlayerWon = false;
  bool _isPlayerTurn = true; // true: 플레이어 턴, false: 상대방 턴

  // 플레이어 정보
  GamePlayer _player = GamePlayer(name: '서연수', tier: 'Gold 2', score: 0);
  GamePlayer _opponent = GamePlayer(name: '김명수', tier: 'Gold 1', score: 0);

  // 팝업 표시 상태
  bool _showResultPopup = false;

  // 목숨
  int _playerLives = 3;
  int _opponentLives = 3;

  // 현재 문제
  GameQuestion? _currentQuestion;
  int _currentQuestionIndex = 0;
  int _currentDifficultyLevel =
      0; // 0: Bronze, 1: Silver, 2: Gold, 3: Platinum, 4: Diamond, 5: Master

  // 타이머
  Timer? _timer;
  double _timeLeft = 0.0;
  double _maxTime = 10.0; // 기본 10초

  // 답안 입력
  TextEditingController _answerController = TextEditingController();
  String _userAnswer = '';
  bool _isAnswered = false;
  bool _isCorrect = false;

  // 문제 유형 (객관식/주관식)
  bool _isMultipleChoice = false;
  int? _selectedOptionIndex;

  // 애니메이션
  late AnimationController _questionAnimationController;
  late AnimationController _turnAnimationController;
  late Animation<double> _questionAnimation;
  late Animation<double> _turnAnimation;

  // 게임 결과 저장
  List<QuestionResult> _playerResults = [];
  List<QuestionResult> _opponentResults = [];

  // 상대방 시뮬레이션
  Timer? _opponentTimer;
  bool _isOpponentThinking = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _opponentTimer?.cancel();
    _questionAnimationController.dispose();
    _turnAnimationController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _turnAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _turnAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _turnAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startGame() async {
    // 데이터 초기화
    await QuestionService.initializeData();

    setState(() {
      _isGameStarted = true;
    });
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    // 난이도 증가 (평균 5분 이내에 게임 종료되도록)
    if (_currentQuestionIndex > 0 && _currentQuestionIndex % 3 == 0) {
      _currentDifficultyLevel = min(_currentDifficultyLevel + 1, 5);
    }

    // 난이도에 따른 시간 조정
    _maxTime = 15.0 - (_currentDifficultyLevel * 1.5); // 15초에서 점점 줄어듦

    // 문제 생성
    final difficulties = [
      QuestionDifficulty.bronze1,
      QuestionDifficulty.silver1,
      QuestionDifficulty.gold1,
      QuestionDifficulty.platinum1,
      QuestionDifficulty.diamond1,
      QuestionDifficulty.master1,
    ];

    try {
      final questions = QuestionService.generateQuestions(
        count: 1,
        difficulty: difficulties[_currentDifficultyLevel],
      );

      if (questions.isNotEmpty) {
        // 첫 번째 문제는 주관식, 두 번째부터는 랜덤하게 객관식/주관식 결정
        if (_currentQuestionIndex == 0) {
          _isMultipleChoice = false;
          _currentQuestion = questions.first;
        } else {
          // 이전 문제와 동일한 유형 유지 (공정성)
          _currentQuestion = _isMultipleChoice
              ? QuestionService.generateMultipleChoiceQuestion(questions.first)
              : questions.first;
        }

        _timeLeft = _maxTime;
        _isAnswered = false;
        _userAnswer = '';
        _selectedOptionIndex = null;
        _answerController.clear();

        _questionAnimationController.reset();
        _questionAnimationController.forward();

        // 플레이어 턴일 때만 타이머 시작
        if (_isPlayerTurn) {
          _startTimer();
        }
      }
    } catch (e) {
      print('문제 생성 중 오류 발생: $e');
      // 오류 발생 시 기본 문제 생성
      _generateFallbackQuestion();
    }
  }

  void _generateFallbackQuestion() {
    // 기본 문제 생성 (JSON 파일 로드 실패 시 사용)
    final random = Random();
    final simpleQuestions = [
      GameQuestion(
        question: '"Hello"의 뜻은?',
        options: ['안녕하세요', '감사합니다', '죄송합니다', '안녕히 가세요'],
        correctAnswerIndex: 0,
        type: QuestionType.word,
        difficulty: QuestionDifficulty.bronze1,
        explanation: '안녕하세요',
      ),
      GameQuestion(
        question: '"Thank you"의 뜻은?',
        options: ['감사합니다', '안녕하세요', '죄송합니다', '안녕히 가세요'],
        correctAnswerIndex: 0,
        type: QuestionType.word,
        difficulty: QuestionDifficulty.bronze1,
        explanation: '감사합니다',
      ),
      GameQuestion(
        question: '"Sorry"의 뜻은?',
        options: ['죄송합니다', '안녕하세요', '감사합니다', '안녕히 가세요'],
        correctAnswerIndex: 0,
        type: QuestionType.word,
        difficulty: QuestionDifficulty.bronze1,
        explanation: '죄송합니다',
      ),
    ];

    _currentQuestion = simpleQuestions[random.nextInt(simpleQuestions.length)];
    _timeLeft = _maxTime;
    _isAnswered = false;
    _userAnswer = '';
    _answerController.clear();

    _questionAnimationController.reset();
    _questionAnimationController.forward();

    // 플레이어 턴일 때만 타이머 시작
    if (_isPlayerTurn) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _isPlayerTurn && !_isAnswered) {
        setState(() {
          _timeLeft -= 0.1;
        });

        if (_timeLeft <= 0) {
          timer.cancel();
          _handleTimeout();
        }
      }
    });
  }

  void _handleTimeout() {
    if (!_isAnswered && _isPlayerTurn) {
      if (_isMultipleChoice && _selectedOptionIndex != null) {
        _submitAnswer(_currentQuestion!.options[_selectedOptionIndex!]);
      } else {
        _submitAnswer(''); // 빈 답안으로 제출
      }
    }
  }

  void _submitAnswer(String answer) {
    if (_isAnswered || _currentQuestion == null) return;

    _timer?.cancel();
    _isAnswered = true;
    _userAnswer = answer;

    final isCorrect = _checkAnswer(answer);
    _isCorrect = isCorrect;

    // 결과 저장
    if (_isPlayerTurn) {
      _playerResults.add(
        QuestionResult(
          question: _currentQuestion!.question,
          correctAnswer:
              _currentQuestion!.options[_currentQuestion!.correctAnswerIndex],
          userAnswer: answer.isEmpty ? null : answer,
          isCorrect: isCorrect,
          type: _currentQuestion!.type,
          explanation: _currentQuestion!.explanation,
        ),
      );

      if (!isCorrect) {
        _playerLives--;
        // 오답 단어 저장
        ReviewService.addWrongWord(
          _currentQuestion!.question,
          _currentQuestion!.options[_currentQuestion!.correctAnswerIndex],
          _currentQuestion!.type,
        );
      }
    } else {
      _opponentResults.add(
        QuestionResult(
          question: _currentQuestion!.question,
          correctAnswer:
              _currentQuestion!.options[_currentQuestion!.correctAnswerIndex],
          userAnswer: answer.isEmpty ? null : answer,
          isCorrect: isCorrect,
          type: _currentQuestion!.type,
          explanation: _currentQuestion!.explanation,
        ),
      );

      if (!isCorrect) {
        _opponentLives--;
      }
    }

    setState(() {});

    // 2초 후 다음 턴으로
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _nextTurn();
      }
    });
  }

  bool _checkAnswer(String answer) {
    if (_currentQuestion == null) return false;

    final correctAnswer =
        _currentQuestion!.options[_currentQuestion!.correctAnswerIndex];

    // 대소문자 무시하고 비교
    return answer.trim().toLowerCase() == correctAnswer.toLowerCase();
  }

  void _nextTurn() {
    _currentQuestionIndex++;

    // 게임 종료 체크
    if (_playerLives <= 0 || _opponentLives <= 0) {
      _finishGame();
      return;
    }

    // 턴 전환
    setState(() {
      _isPlayerTurn = !_isPlayerTurn;
      _isOpponentThinking = false;
    });

    _turnAnimationController.reset();
    _turnAnimationController.forward();

    if (_isPlayerTurn) {
      // 플레이어 턴
      _generateNewQuestion();
    } else {
      // 상대방 턴
      _startOpponentTurn();
    }
  }

  void _startOpponentTurn() {
    _generateNewQuestion();

    if (_currentQuestion != null) {
      setState(() {
        _isOpponentThinking = true;
      });

      // 상대방이 3-7초 후에 답안 제출
      final random = Random();
      final thinkTime = 3.0 + random.nextDouble() * 4.0; // 3-7초

      _opponentTimer = Timer(
        Duration(milliseconds: (thinkTime * 1000).toInt()),
        () {
          if (mounted && !_isAnswered && _currentQuestion != null) {
            // 상대방 정답률 (난이도에 따라 조정)
            final correctRate =
                0.8 - (_currentDifficultyLevel * 0.1); // 80%에서 점점 줄어듦
            final isCorrect = random.nextDouble() < correctRate;

            String answer;
            if (isCorrect) {
              answer = _currentQuestion!
                  .options[_currentQuestion!.correctAnswerIndex];
            } else {
              // 틀린 답안 (랜덤하게 선택)
              final wrongOptions = List<String>.from(_currentQuestion!.options);
              wrongOptions.removeAt(_currentQuestion!.correctAnswerIndex);
              answer = wrongOptions[random.nextInt(wrongOptions.length)];
            }

            _submitAnswer(answer);
          }
        },
      );
    }
  }

  void _finishGame() {
    _isGameFinished = true;
    _isPlayerWon = _opponentLives <= 0;
    _timer?.cancel();
    _opponentTimer?.cancel();

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
      totalQuestions: _currentQuestionIndex,
      gameMode: GameMode.rank,
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

  @override
  Widget build(BuildContext context) {
    if (!_isGameStarted) {
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
                                      _buildAnswerInput(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (_isPlayerTurn) _buildTimer(),
                    ],
                  ),
          ),
        ),
        // 게임 결과 팝업
        if (_showResultPopup)
          GameResultPopup(
            player: _player,
            opponent: _opponent,
            playerScore: _playerLives,
            opponentScore: _opponentLives,
            totalQuestions: _currentQuestionIndex,
            isRankGame: true,
            onClose: _onPopupClose,
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8F9FF),
            const Color(0xFFF8F9FF).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // 귀여운 배틀 아이콘과 제목
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '랭크 배틀',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
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
                    gradient: LinearGradient(
                      colors: _isPlayerTurn
                          ? [const Color(0xFF788CC3), const Color(0xFF6A7BB8)]
                          : [Colors.grey[400]!, Colors.grey[500]!],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_isPlayerTurn
                                    ? const Color(0xFF788CC3)
                                    : Colors.grey[400]!)
                                .withOpacity(0.3),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isPlayerTurn
                              ? const Color(0xFF333333)
                              : Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _player.tier,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 목숨 표시
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.favorite,
                        color: index < _playerLives
                            ? (_isPlayerTurn
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.grey[600])
                            : Colors.grey[300],
                        size: 18,
                      ),
                    );
                  }),
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
                // 목숨 표시
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.favorite,
                        color: index < _opponentLives
                            ? (!_isPlayerTurn
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.grey[600])
                            : Colors.grey[300],
                        size: 18,
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _opponent.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: !_isPlayerTurn
                              ? const Color(0xFF333333)
                              : Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _opponent.tier,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: !_isPlayerTurn
                          ? [const Color(0xFFFF6B6B), const Color(0xFFFF5252)]
                          : [Colors.grey[400]!, Colors.grey[500]!],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (!_isPlayerTurn
                                    ? const Color(0xFFFF6B6B)
                                    : Colors.grey[400]!)
                                .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.computer,
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
    if (_currentQuestion == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 간단한 턴 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isPlayerTurn
                  ? const Color(0xFF788CC3).withOpacity(0.1)
                  : const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isPlayerTurn
                    ? const Color(0xFF788CC3)
                    : const Color(0xFFFF6B6B),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPlayerTurn ? Icons.person : Icons.computer,
                  color: _isPlayerTurn
                      ? const Color(0xFF788CC3)
                      : const Color(0xFFFF6B6B),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _isPlayerTurn ? '내 턴' : '상대 턴',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isPlayerTurn
                        ? const Color(0xFF788CC3)
                        : const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 16),

          // 문제 내용
          Text(
            _currentQuestion!.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    if (!_isPlayerTurn) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
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
            // 상대방 상태 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isOpponentThinking
                          ? '상대방이 답안을 입력하고 있습니다...'
                          : '상대방 턴입니다',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // 상대방 답안 결과 표시
            if (_isAnswered) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isCorrect
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : const Color(0xFFF44336).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isCorrect
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                (_isCorrect
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFF44336))
                                    .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _isCorrect ? Icons.check_circle : Icons.cancel,
                            color: _isCorrect
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFF44336),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isCorrect ? '상대방 정답!' : '상대방 오답',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _isCorrect
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFF44336),
                          ),
                        ),
                      ],
                    ),
                    if (_userAnswer.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '상대방 답안: $_userAnswer',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                    if (!_isCorrect) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '정답: ${_currentQuestion?.options[_currentQuestion!.correctAnswerIndex]}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          // 객관식인 경우
          if (_isMultipleChoice) ...[
            Text(
              '정답을 선택하세요',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(_currentQuestion!.options.length, (index) {
              final isCorrect = index == _currentQuestion!.correctAnswerIndex;
              final isSelected = index == _selectedOptionIndex;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: _isAnswered
                      ? null
                      : () {
                          setState(() {
                            _selectedOptionIndex = index;
                            _userAnswer = _currentQuestion!.options[index];
                          });
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isAnswered
                          ? (isCorrect
                                ? const Color(0xFF4CAF50).withOpacity(0.1)
                                : isSelected
                                ? const Color(0xFFF44336).withOpacity(0.1)
                                : Colors.white)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isAnswered
                            ? (isCorrect
                                  ? const Color(0xFF4CAF50)
                                  : isSelected
                                  ? const Color(0xFFF44336)
                                  : Colors.grey[200]!)
                            : Colors.grey[200]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isAnswered
                                ? (isCorrect
                                      ? const Color(0xFF4CAF50)
                                      : isSelected
                                      ? const Color(0xFFF44336)
                                      : Colors.grey[300])
                                : Colors.grey[300],
                          ),
                          child: _isAnswered
                              ? Icon(
                                  isCorrect
                                      ? Icons.check
                                      : isSelected
                                      ? Icons.close
                                      : null,
                                  color: Colors.white,
                                  size: 12,
                                )
                              : Text(
                                  String.fromCharCode(65 + index), // A, B, C, D
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _currentQuestion!.options[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _isAnswered
                                  ? (isCorrect
                                        ? const Color(0xFF4CAF50)
                                        : isSelected
                                        ? const Color(0xFFF44336)
                                        : const Color(0xFF666666))
                                  : const Color(0xFF333333),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ] else ...[
            // 주관식인 경우
            TextField(
              controller: _answerController,
              enabled: !_isAnswered,
              decoration: InputDecoration(
                hintText: '답안을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _isAnswered
                        ? (_isCorrect
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336))
                        : const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF788CC3),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: _isAnswered
                    ? (_isCorrect
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : const Color(0xFFF44336).withOpacity(0.1))
                    : Colors.grey[50],
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              onChanged: (value) {
                _userAnswer = value;
              },
              onSubmitted: (value) {
                if (!_isAnswered) {
                  _submitAnswer(value);
                }
              },
            ),
            const SizedBox(height: 16),
            if (!_isAnswered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _submitAnswer(_userAnswer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF788CC3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '답안 제출',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
          if (_isAnswered) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFFF44336).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isCorrect
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              (_isCorrect
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFF44336))
                                  .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isCorrect ? Icons.check_circle : Icons.cancel,
                          color: _isCorrect
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isCorrect ? '정답입니다!' : '틀렸습니다.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _isCorrect
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336),
                        ),
                      ),
                    ],
                  ),
                  if (!_isCorrect) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '정답: ${_currentQuestion?.options[_currentQuestion!.correctAnswerIndex]}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimer() {
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
              color: _timeLeft > _maxTime * 0.3
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFFF6B6B),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '${_timeLeft.toInt()}초',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _timeLeft > _maxTime * 0.3
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF6B6B),
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
                  widthFactor: (_timeLeft / _maxTime).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _timeLeft > _maxTime * 0.3
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF6B6B),
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
        return const Color(0xFF666666);
      case QuestionType.grammar:
        return const Color(0xFF888888);
      case QuestionType.dialog:
        return const Color(0xFF777777);
    }
  }
}
