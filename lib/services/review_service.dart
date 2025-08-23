import '../models/review_word.dart';
import '../models/game_question.dart';

class ReviewService {
  static List<ReviewWord> _wrongWords = [];

  // 오답 단어 추가
  static void addWrongWord(String english, String korean, QuestionType type) {
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
      );
    } else {
      // 새로운 단어면 urgent 상태로 추가
      _wrongWords.add(
        ReviewWord(
          english: english,
          korean: korean,
          status: ReviewStatus.urgent,
          lastReviewed: DateTime.now(),
        ),
      );
    }
  }

  // 모든 오답 단어 가져오기
  static List<ReviewWord> getAllWrongWords() {
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
}
