import 'package:flutter/material.dart';
import '../models/game_result.dart';
import '../models/game_question.dart';

class GameResultDetailScreen extends StatefulWidget {
  final GameResult gameResult;

  const GameResultDetailScreen({Key? key, required this.gameResult})
    : super(key: key);

  @override
  State<GameResultDetailScreen> createState() => _GameResultDetailScreenState();
}

class _GameResultDetailScreenState extends State<GameResultDetailScreen> {
  int _currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildResultContent()),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 20, color: Color(0xFF666666)),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '일반 결과',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // 균형을 위한 빈 공간
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    return Column(
      children: [
        // 상대방 결과 섹션
        Expanded(child: _buildOpponentSection()),
        const SizedBox(height: 20),
        // 내 결과 섹션
        Expanded(child: _buildPlayerSection()),
      ],
    );
  }

  Widget _buildOpponentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Column(
        children: [
          // 상대방 정보
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Text(
                    widget.gameResult.opponent.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (!widget.gameResult.isPlayerWon) ...[
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/icons/crown.png',
                      width: 20,
                      height: 20,
                    ),
                  ],
                ],
              ),
              const Spacer(),
              Text(
                '${widget.gameResult.opponent.score}/${widget.gameResult.totalQuestions}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF788CC3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 상대방 문제풀이 캐러셀
          Expanded(
            child: _buildQuestionCarousel(
              widget.gameResult.opponentResults,
              true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Column(
        children: [
          // 내 정보
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF788CC3), Color(0xFF6A7BB8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Text(
                    widget.gameResult.player.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (widget.gameResult.isPlayerWon) ...[
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/icons/crown.png',
                      width: 20,
                      height: 20,
                    ),
                  ],
                ],
              ),
              const Spacer(),
              Text(
                '${widget.gameResult.player.score}/${widget.gameResult.totalQuestions}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF788CC3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 내 문제풀이 캐러셀
          Expanded(
            child: _buildQuestionCarousel(
              widget.gameResult.playerResults,
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCarousel(List<QuestionResult> results, bool isOpponent) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          '결과가 없습니다.',
          style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
        ),
      );
    }

    return PageView.builder(
      controller: PageController(
        viewportFraction: 0.8, // 좌우 카드가 살짝 보이도록
        initialPage: _currentQuestionIndex,
      ),
      onPageChanged: (index) {
        setState(() {
          _currentQuestionIndex = index;
        });
      },
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildQuestionCard(
          result,
          index + 1,
          results.length,
          isOpponent,
        );
      },
    );
  }

  Widget _buildQuestionCard(
    QuestionResult result,
    int questionNumber,
    int totalQuestions,
    bool isOpponent,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result.isCorrect
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : const Color(0xFFF44336).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: result.isCorrect
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : const Color(0xFFF44336).withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문제 번호와 상태
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 문제 번호
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF788CC3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '문제 $questionNumber',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF788CC3),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getQuestionTypeColor(result.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getQuestionTypeIcon(result.type),
                      color: _getQuestionTypeColor(result.type),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getQuestionTypeText(result.type),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getQuestionTypeColor(result.type),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: result.isCorrect
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : const Color(0xFFF44336).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      result.isCorrect ? Icons.check : Icons.close,
                      color: result.isCorrect
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.isCorrect ? '정답' : '오답',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: result.isCorrect
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 문제 내용
          Text(
            result.question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // 정답 (더 크게)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '정답',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.correctAnswer,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),

          // 사용자 답안 (오답인 경우에만 표시)
          if (!result.isCorrect && result.userAnswer != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF44336).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '내 답안',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF44336),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.userAnswer!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // 복습 페이지로 이동
            Navigator.pop(context);
            // TODO: 복습 페이지로 이동하는 로직 추가
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF788CC3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            '복습하러가기',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
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
