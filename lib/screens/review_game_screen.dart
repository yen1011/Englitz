import 'package:flutter/material.dart';
import 'dart:math';
import '../models/review_word.dart';
import '../models/game_question.dart';
import '../services/review_service.dart';

class ReviewGameScreen extends StatefulWidget {
  final List<ReviewWord> reviewWords;
  final VoidCallback onGameComplete;

  const ReviewGameScreen({
    Key? key,
    required this.reviewWords,
    required this.onGameComplete,
  }) : super(key: key);

  @override
  State<ReviewGameScreen> createState() => _ReviewGameScreenState();
}

class _ReviewGameScreenState extends State<ReviewGameScreen>
    with TickerProviderStateMixin {
  late List<ReviewWord> _questions;
  int _currentQuestionIndex = 0;
  bool _isAnswered = false;
  bool _isCorrect = false;
  String _userAnswer = '';
  int? _selectedOptionIndex;
  int _correctCount = 0;
  int _totalQuestions = 0;
  bool _isGameFinished = false;

  late AnimationController _questionAnimationController;
  late Animation<double> _questionAnimation;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.reviewWords);
    _totalQuestions = _questions.length;
    
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _questionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _questionAnimationController.forward();
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    super.dispose();
  }

  void _submitAnswer(String answer) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _userAnswer = answer;
      
      final currentWord = _questions[_currentQuestionIndex];
      // 문법 문제의 경우 korean이 정답, 단어/대화 문제의 경우 english가 정답
      final correctAnswer = currentWord.type == QuestionType.grammar 
          ? currentWord.korean 
          : currentWord.english;
      _isCorrect = answer.toLowerCase().trim() == correctAnswer.toLowerCase().trim();
      
      if (_isCorrect) {
        _correctCount++;
        // 정답 시 상태 업데이트
        if (currentWord.status == ReviewStatus.urgent) {
          // 긴급복습 -> 복습필요
          ReviewService.updateWordStatus(currentWord.english, ReviewStatus.needsReview);
        } else if (currentWord.status == ReviewStatus.needsReview) {
          // 복습필요 -> 완벽
          ReviewService.updateWordStatus(currentWord.english, ReviewStatus.mastered);
        }
      }
      // 오답 시 상태 유지 (긴급복습은 계속 긴급복습)
    });

    // 2초 후 다음 문제로
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _isCorrect = false;
        _userAnswer = '';
        _selectedOptionIndex = null;
      });
      
      _questionAnimationController.reset();
      _questionAnimationController.forward();
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    setState(() {
      _isGameFinished = true;
    });
  }

  void _goBack() {
    widget.onGameComplete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameFinished) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 64,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '복습 완료!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '정답률: ${((_correctCount / _totalQuestions) * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF788CC3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_correctCount / $_totalQuestions',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _goBack,
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
                            '돌아가기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentWord = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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
                            _buildQuestionArea(currentWord),
                            _buildAnswerInput(currentWord),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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
                      Icons.book,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_currentQuestionIndex + 1}/$_totalQuestions',
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
          const SizedBox(height: 16),
          // 진행률 바
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentQuestionIndex + 1) / _totalQuestions,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF788CC3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea(ReviewWord word) {
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
          // 문제 타입 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF788CC3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF788CC3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  word.type == QuestionType.grammar ? Icons.edit : Icons.translate,
                  color: const Color(0xFF788CC3),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  word.type == QuestionType.grammar ? '문법' : '단어',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF788CC3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 문제 내용
          Text(
            word.type == QuestionType.grammar 
                ? '다음 문장에서 빈칸에 들어갈 단어는?'
                : '"${word.english}"의 뜻은?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          
          if (word.type == QuestionType.grammar) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: Text(
                word.english, // 문법 문장
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerInput(ReviewWord word) {
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
          // 주관식 입력
          TextField(
            enabled: !_isAnswered,
            decoration: InputDecoration(
              hintText: word.type == QuestionType.grammar ? '빈칸에 들어갈 단어를 입력하세요' : '답안을 입력하세요',
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
                          color: (_isCorrect
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
                        _isCorrect ? '정답!' : '오답',
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
                      '정답: ${word.type == QuestionType.grammar ? word.korean : word.english}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  if (word.korean.isNotEmpty) ...[
                    const SizedBox(height: 8),
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
                        '의미: ${word.korean}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
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
}
