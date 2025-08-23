import 'package:flutter/material.dart';
import 'dart:math';
import '../models/review_word.dart';
import '../models/game_question.dart';
import '../services/review_service.dart';
import 'review_game_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> with WidgetsBindingObserver {
  int _selectedTabIndex = 0; // 0: 단어, 1: 문법
  List<ReviewWord> _words = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWords();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadWords();
    }
  }

  void _loadWords() {
    setState(() {
      _words = ReviewService.getAllWrongWords();
      print('ReviewScreen: Loaded ${_words.length} words');
      for (var word in _words) {
        print('ReviewScreen: Word - ${word.english} (${word.type})');
      }
    });
  }

  void _startReview() {
    // 완벽 상태가 아닌 단어들만 필터링
    final reviewWords = _words.where((word) => word.status != ReviewStatus.mastered).toList();
    
    if (reviewWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('복습할 단어가 없습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 랜덤으로 15개 선택 (최대 15개)
    final random = Random();
    final selectedWords = reviewWords.length > 15 
        ? (reviewWords.take(15).toList()..shuffle(random))
        : (reviewWords..shuffle(random));

    // 복습 게임 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewGameScreen(
          reviewWords: selectedWords,
          onGameComplete: () {
            // 게임 완료 후 리뷰 화면 새로고침
            _loadWords();
          },
        ),
      ),
    );
  }

  Color _getStatusColor(ReviewStatus status) {
    switch (status) {
      case ReviewStatus.mastered:
        return const Color(0xFF4CAF50); // 초록색
      case ReviewStatus.needsReview:
        return const Color(0xFFFF9800); // 주황색
      case ReviewStatus.urgent:
        return const Color(0xFFF44336); // 빨간색
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 탭과 새로고침 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // 왼쪽 여백
                  const Spacer(),
                  // 중앙에 위치한 탭 버튼들
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 92,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedTabIndex = 0);
                            _loadWords();
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0
                                  ? const Color(0xFF788CC3)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: _selectedTabIndex == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '단어',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedTabIndex == 0
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 92,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedTabIndex = 1);
                            _loadWords();
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1
                                  ? const Color(0xFF788CC3)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: _selectedTabIndex == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '문법',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedTabIndex == 1
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 오른쪽 여백
                  const Spacer(),
                ],
              ),
            ),

            // 단어 목록
            if (_selectedTabIndex == 0) ...[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: _words.where((word) => word.type == QuestionType.word || word.type == QuestionType.dialog).length,
                    itemBuilder: (context, index) {
                      final wordList = _words.where((word) => word.type == QuestionType.word || word.type == QuestionType.dialog).toList();
                      final word = wordList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE6E6E6),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  word.english,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    word.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  word.status.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(word.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              word.korean,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ),
                          trailing: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(word.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 복습 시작 버튼
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF788CC3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '복습 시작',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // 문법 탭
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: _words.where((word) => word.type == QuestionType.grammar).length,
                    itemBuilder: (context, index) {
                      final grammarWords = _words.where((word) => word.type == QuestionType.grammar).toList();
                      final word = grammarWords[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE6E6E6),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  word.english,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    word.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  word.status.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(word.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              word.korean,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ),
                          trailing: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(word.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 복습 시작 버튼
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF788CC3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '복습 시작',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
