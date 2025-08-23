import '../models/review_word.dart';
import '../models/game_question.dart';

class ReviewService {
  static List<ReviewWord> _wrongWords = [];

  // 오답 단어 추가
  static void addWrongWord(String question, String correctAnswer, QuestionType type) {
    print('ReviewService: Processing question - "$question", correct: "$correctAnswer", type: $type');
    
    String english = '';
    String korean = '';
    
    // 문제 타입에 따라 영어와 한국어 추출
    switch (type) {
      case QuestionType.word:
        // "word"의 뜻은? 형태에서 word 추출
        final wordMatch = RegExp(r'"([^"]+)"').firstMatch(question);
        if (wordMatch != null) {
          english = wordMatch.group(1) ?? '';
          korean = correctAnswer;
        }
        break;
      case QuestionType.grammar:
        // 문법 문제는 원래 문제 문장을 영어로, 정답을 한국어로
        english = question;
        korean = correctAnswer;
        break;
      case QuestionType.dialog:
        // 대화 표현도 단어와 동일하게 처리
        final wordMatch = RegExp(r'"([^"]+)"').firstMatch(question);
        if (wordMatch != null) {
          english = wordMatch.group(1) ?? '';
          korean = correctAnswer;
        }
        break;
    }
    
    // 유효한 데이터가 있는 경우에만 추가
    if (english.isNotEmpty && korean.isNotEmpty) {
      print('ReviewService: Extracted - English: "$english", Korean: "$korean", Type: $type');
      print('ReviewService: Adding wrong word - English: $english, Korean: $korean, Type: $type');
      
      // 이미 있는 단어인지 확인
      final existingIndex = _wrongWords.indexWhere(
        (word) => word.english == english,
      );

      if (existingIndex != -1) {
        // 이미 있는 단어면 상태를 urgent로 업데이트
        _wrongWords[existingIndex] = ReviewWord(
          english: english,
          korean: korean,
          status: ReviewStatus.urgent,
          lastReviewed: DateTime.now(),
          type: type,
        );
        print('ReviewService: Updated existing word');
      } else {
        // 새로운 단어면 urgent 상태로 추가
        _wrongWords.add(
          ReviewWord(
            english: english,
            korean: korean,
            status: ReviewStatus.urgent,
            lastReviewed: DateTime.now(),
            type: type,
          ),
        );
        print('ReviewService: Added new word. Total words: ${_wrongWords.length}');
      }
    } else {
      print('ReviewService: Invalid data - English: $english, Korean: $korean');
    }
  }

  // 모든 오답 단어 가져오기
  static List<ReviewWord> getAllWrongWords() {
    print('ReviewService: getAllWrongWords called, total words: ${_wrongWords.length}');
    for (var word in _wrongWords) {
      print('ReviewService: Word in list - ${word.english} (${word.type})');
    }
    return List.from(_wrongWords);
  }

  // 단어 상태 업데이트 (복습 완료 시)
  static void updateWordStatus(String english, ReviewStatus newStatus) {
    final index = _wrongWords.indexWhere((word) => word.english == english);
    if (index != -1) {
      _wrongWords[index] = ReviewWord(
        english: _wrongWords[index].english,
        korean: _wrongWords[index].korean,
        status: newStatus,
        lastReviewed: DateTime.now(),
        type: _wrongWords[index].type,
      );
    }
  }

  // 오답 단어 개수 가져오기
  static int getWrongWordsCount() {
    return _wrongWords.length;
  }

  // urgent 상태 단어 개수 가져오기
  static int getUrgentWordsCount() {
    return _wrongWords
        .where((word) => word.status == ReviewStatus.urgent)
        .length;
  }

  // 테스트용 데이터 추가 (개발 중에만 사용)
  static void addTestData() {
    addWrongWord('"Hello"의 뜻은?', '안녕하세요', QuestionType.word);
    addWrongWord('"Thank you"의 뜻은?', '감사합니다', QuestionType.word);
    addWrongWord('빈칸에 들어갈 단어는?\nI ____ a student.', 'am', QuestionType.grammar);
    addWrongWord('"Sorry"의 뜻은?', '죄송합니다', QuestionType.dialog);
  }
}
