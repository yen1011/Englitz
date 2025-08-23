class ReviewWord {
  final String english;
  final String korean;
  final ReviewStatus status;
  final DateTime lastReviewed;

  ReviewWord({
    required this.english,
    required this.korean,
    required this.status,
    required this.lastReviewed,
  });
}

enum ReviewStatus {
  mastered, // 초록색 - 잘 외운 단어
  needsReview, // 주황색 - 더 복습이 필요한 단어
  urgent, // 빨간색 - 무조건 복습해야 하는 단어
}

extension ReviewStatusExtension on ReviewStatus {
  String get displayName {
    switch (this) {
      case ReviewStatus.mastered:
        return '완벽';
      case ReviewStatus.needsReview:
        return '복습 필요';
      case ReviewStatus.urgent:
        return '긴급 복습';
    }
  }
}
