import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/game_question.dart';

class QuestionService {
  static Map<String, List<Map<String, dynamic>>>? _tierData;
  static String _currentTier = 'GOLD1'; // 현재 사용자 티어

  static Future<void> initializeData() async {
    if (_tierData == null) {
      _tierData = {};
      
      // 각 티어별 데이터 로드
      final tiers = ['bronze', 'silver', 'gold', 'platinum', 'diamond', 'master'];
      
      for (final tier in tiers) {
        try {
          final jsonString = await rootBundle.loadString('assets/datas/$tier.json');
          final data = json.decode(jsonString);
          _tierData![tier] = List<Map<String, dynamic>>.from(data['items']);
        } catch (e) {
          print('Failed to load $tier.json: $e');
        }
      }
    }
  }

  // 현재 티어 설정
  static void setCurrentTier(String tier) {
    _currentTier = tier;
  }

  // 현재 티어에 맞는 문제 난이도 범위 결정
  static List<String> _getTierRange(String currentTier) {
    final tierOrder = ['bronze', 'silver', 'gold', 'platinum', 'diamond', 'master'];
    final currentTierBase = currentTier.replaceAll(RegExp(r'\d+'), '').toLowerCase();
    
    final currentIndex = tierOrder.indexOf(currentTierBase);
    if (currentIndex == -1) return ['gold']; // 기본값
    
    final startIndex = (currentIndex - 1).clamp(0, tierOrder.length - 1);
    final endIndex = (currentIndex + 1).clamp(0, tierOrder.length - 1);
    
    return tierOrder.sublist(startIndex, endIndex + 1);
  }

  static List<GameQuestion> generateQuestions({
    required int count,
    required QuestionDifficulty difficulty,
    List<QuestionType>? types,
  }) {
    types ??= [QuestionType.word, QuestionType.grammar, QuestionType.dialog];

    List<GameQuestion> questions = [];
    final random = Random();

    for (int i = 0; i < count; i++) {
      final type = types[random.nextInt(types.length)];
      GameQuestion question;

      switch (type) {
        case QuestionType.word:
          question = _generateWordQuestion(difficulty);
          break;
        case QuestionType.grammar:
          question = _generateGrammarQuestion(difficulty);
          break;
        case QuestionType.dialog:
          question = _generateDialogQuestion(difficulty);
          break;
      }

      questions.add(question);
    }

    return questions;
  }

  // 객관식 문제 생성 (주관식과 동일한 문제를 객관식으로 변환)
  static GameQuestion generateMultipleChoiceQuestion(
    GameQuestion originalQuestion,
  ) {
    final random = Random();

    // 원본 문제의 정답
    final correctAnswer =
        originalQuestion.options[originalQuestion.correctAnswerIndex];

    // 객관식 옵션 생성 (4개)
    List<String> options = [correctAnswer];

    // 오답 생성 (3개)
    for (int i = 0; i < 3; i++) {
      String wrongAnswer;
      do {
        // 티어별 데이터에서 오답 생성
        wrongAnswer = _generateWrongAnswerFromTierData(originalQuestion.type);
      } while (options.contains(wrongAnswer));

      options.add(wrongAnswer);
    }

    // 옵션 섞기
    options.shuffle(random);
    final correctIndex = options.indexOf(correctAnswer);

    return GameQuestion(
      question: originalQuestion.question,
      options: options,
      correctAnswerIndex: correctIndex,
      type: originalQuestion.type,
      difficulty: originalQuestion.difficulty,
      explanation: originalQuestion.explanation,
    );
  }

  static String _generateWrongAnswerFromTierData(QuestionType type) {
    if (_tierData == null) {
      return _generateFallbackWrongAnswer(type);
    }

    final tierRange = _getTierRange(_currentTier);
    final random = Random();
    
    // 티어 범위에서 랜덤하게 선택
    final selectedTier = tierRange[random.nextInt(tierRange.length)];
    final tierItems = _tierData![selectedTier];
    
    if (tierItems == null || tierItems.isEmpty) {
      return _generateFallbackWrongAnswer(type);
    }

    // 해당 티어의 아이템에서 랜덤 선택
    final randomItem = tierItems[random.nextInt(tierItems.length)];
    
    switch (type) {
      case QuestionType.word:
        return randomItem['meaning']?.toString() ?? _generateFallbackWrongAnswer(type);
      case QuestionType.grammar:
        return randomItem['word']?.toString() ?? _generateFallbackWrongAnswer(type);
      case QuestionType.dialog:
        return randomItem['meaning']?.toString() ?? _generateFallbackWrongAnswer(type);
    }
  }

  static String _generateFallbackWrongAnswer(QuestionType type) {
    final random = Random();
    
    switch (type) {
      case QuestionType.word:
        // 실제 단어와 의미를 사용
        final wordMeanings = [
          '사과', '바나나', '오렌지', '포도', '딸기',
          '컴퓨터', '책상', '의자', '창문', '문',
          '자동차', '버스', '기차', '비행기', '배',
          '고양이', '강아지', '새', '물고기', '토끼'
        ];
        return wordMeanings[random.nextInt(wordMeanings.length)];
      case QuestionType.grammar:
        final grammarWords = ['am', 'is', 'are', 'be', 'go', 'goes', 'going', 'went', 'have', 'has', 'had', 'do', 'does', 'did'];
        return grammarWords[random.nextInt(grammarWords.length)];
      case QuestionType.dialog:
        // 실제 대화 표현을 사용
        final dialogExpressions = [
          '안녕하세요', '감사합니다', '죄송합니다', '안녕히 가세요',
          '좋은 아침입니다', '좋은 저녁입니다', '만나서 반갑습니다',
          '도와주세요', '괜찮습니다', '알겠습니다'
        ];
        return dialogExpressions[random.nextInt(dialogExpressions.length)];
    }
  }

  static GameQuestion _generateWordQuestion(QuestionDifficulty difficulty) {
    final random = Random();

    // 티어별 데이터가 없는 경우 기본 문제 생성
    if (_tierData == null) {
      return _generateSimpleWordQuestion(difficulty);
    }

    final tierRange = _getTierRange(_currentTier);
    final selectedTier = tierRange[random.nextInt(tierRange.length)];
    final tierItems = _tierData![selectedTier];
    
    if (tierItems == null || tierItems.isEmpty) {
      return _generateSimpleWordQuestion(difficulty);
    }

    // vocabulary 타입의 아이템만 필터링
    final vocabularyItems = tierItems.where((item) => 
      item['type'] == 'vocabulary'
    ).toList();

    if (vocabularyItems.isEmpty) {
      return _generateSimpleWordQuestion(difficulty);
    }

    final selectedItem = vocabularyItems[random.nextInt(vocabularyItems.length)];
    final word = selectedItem['word']?.toString() ?? '';
    final meaning = selectedItem['meaning']?.toString() ?? '';

    // 단어가 너무 길거나 의미가 없는 경우 제외
    if (word.isEmpty || meaning.isEmpty || word.length > 15 || meaning.length > 20) {
      return _generateSimpleWordQuestion(difficulty);
    }

    // 오답 생성
    List<String> wrongMeanings = [];
    for (int i = 0; i < 3; i++) {
      String wrongMeaning;
      do {
        wrongMeaning = _generateWrongAnswerFromTierData(QuestionType.word);
      } while (wrongMeaning == meaning || 
               wrongMeanings.contains(wrongMeaning) ||
               wrongMeaning.length > 20);
      wrongMeanings.add(wrongMeaning);
    }

    // 옵션 섞기
    List<String> options = [meaning, ...wrongMeanings];
    options.shuffle(random);
    final correctIndex = options.indexOf(meaning);

    return GameQuestion(
      question: '"$word"의 뜻은?',
      options: options,
      correctAnswerIndex: correctIndex,
      type: QuestionType.word,
      difficulty: difficulty,
      explanation: meaning,
    );
  }

  static GameQuestion _generateGrammarQuestion(QuestionDifficulty difficulty) {
    final random = Random();

    // 티어별 데이터가 없는 경우 기본 문제 생성
    if (_tierData == null) {
      return _generateFallbackGrammarQuestion(difficulty);
    }

    final tierRange = _getTierRange(_currentTier);
    final selectedTier = tierRange[random.nextInt(tierRange.length)];
    final tierItems = _tierData![selectedTier];
    
    if (tierItems == null || tierItems.isEmpty) {
      return _generateFallbackGrammarQuestion(difficulty);
    }

    // sentence 타입의 아이템만 필터링
    final sentenceItems = tierItems.where((item) => 
      item['type'] == 'sentence'
    ).toList();

    if (sentenceItems.isEmpty) {
      return _generateFallbackGrammarQuestion(difficulty);
    }

    final selectedItem = sentenceItems[random.nextInt(sentenceItems.length)];
    final englishSentences = selectedItem['english'] as List<dynamic>?;
    
    if (englishSentences == null || englishSentences.isEmpty) {
      return _generateFallbackGrammarQuestion(difficulty);
    }

    final englishSentence = englishSentences[0].toString();
    
    // <b> 태그로 강조된 단어 찾기
    final boldPattern = RegExp(r'<b>([^<]+)</b>');
    final matches = boldPattern.allMatches(englishSentence);
    
    if (matches.isEmpty) {
      return _generateFallbackGrammarQuestion(difficulty);
    }

    final selectedMatch = matches.elementAt(random.nextInt(matches.length));
    final correctWord = selectedMatch.group(1) ?? '';
    final questionSentence = englishSentence.replaceAll(boldPattern, '____');

    // 오답 생성
    List<String> wrongWords = [];
    for (int i = 0; i < 3; i++) {
      String wrongWord;
      do {
        wrongWord = _generateWrongAnswerFromTierData(QuestionType.grammar);
      } while (wrongWord == correctWord || 
               wrongWords.contains(wrongWord) ||
               wrongWord.length > 15);
      wrongWords.add(wrongWord);
    }

    // 옵션 섞기
    List<String> options = [correctWord, ...wrongWords];
    options.shuffle(random);
    final correctIndex = options.indexOf(correctWord);

    return GameQuestion(
      question: '빈칸에 들어갈 단어는?\n$questionSentence',
      options: options,
      correctAnswerIndex: correctIndex,
      type: QuestionType.grammar,
      difficulty: difficulty,
      explanation: correctWord,
    );
  }

  static GameQuestion _generateDialogQuestion(QuestionDifficulty difficulty) {
    final random = Random();

    // 티어별 데이터가 없는 경우 기본 문제 생성
    if (_tierData == null) {
      return _generateFallbackDialogQuestion(difficulty);
    }

    final tierRange = _getTierRange(_currentTier);
    final selectedTier = tierRange[random.nextInt(tierRange.length)];
    final tierItems = _tierData![selectedTier];
    
    if (tierItems == null || tierItems.isEmpty) {
      return _generateFallbackDialogQuestion(difficulty);
    }

    // vocabulary 타입에서 대화 표현 관련 단어 선택
    final vocabularyItems = tierItems.where((item) => 
      item['type'] == 'vocabulary'
    ).toList();

    if (vocabularyItems.isEmpty) {
      return _generateFallbackDialogQuestion(difficulty);
    }

    final selectedItem = vocabularyItems[random.nextInt(vocabularyItems.length)];
    final word = selectedItem['word']?.toString() ?? '';
    final meaning = selectedItem['meaning']?.toString() ?? '';

    // 단어가 너무 길거나 의미가 없는 경우 제외
    if (word.isEmpty || meaning.isEmpty || word.length > 15 || meaning.length > 20) {
      return _generateFallbackDialogQuestion(difficulty);
    }

    // 오답 생성
    List<String> wrongMeanings = [];
    for (int i = 0; i < 3; i++) {
      String wrongMeaning;
      do {
        wrongMeaning = _generateWrongAnswerFromTierData(QuestionType.dialog);
      } while (wrongMeaning == meaning || 
               wrongMeanings.contains(wrongMeaning) ||
               wrongMeaning.length > 20);
      wrongMeanings.add(wrongMeaning);
    }

    // 옵션 섞기
    List<String> options = [meaning, ...wrongMeanings];
    options.shuffle(random);
    final correctIndex = options.indexOf(meaning);

    return GameQuestion(
      question: '"$word"의 뜻은?',
      options: options,
      correctAnswerIndex: correctIndex,
      type: QuestionType.dialog,
      difficulty: difficulty,
      explanation: meaning,
    );
  }

  static GameQuestion _generateSimpleWordQuestion(
    QuestionDifficulty difficulty,
  ) {
    final random = Random();

    final simpleWords = [
      {'word': 'Happy', 'meaning': '행복한'},
      {'word': 'Sad', 'meaning': '슬픈'},
      {'word': 'Big', 'meaning': '큰'},
      {'word': 'Small', 'meaning': '작은'},
      {'word': 'Fast', 'meaning': '빠른'},
      {'word': 'Slow', 'meaning': '느린'},
      {'word': 'Hot', 'meaning': '뜨거운'},
      {'word': 'Cold', 'meaning': '차가운'},
      {'word': 'Good', 'meaning': '좋은'},
      {'word': 'Bad', 'meaning': '나쁜'},
      {'word': 'New', 'meaning': '새로운'},
      {'word': 'Old', 'meaning': '오래된'},
      {'word': 'Young', 'meaning': '젊은'},
      {'word': 'Beautiful', 'meaning': '아름다운'},
      {'word': 'Ugly', 'meaning': '못생긴'},
      {'word': 'Strong', 'meaning': '강한'},
      {'word': 'Weak', 'meaning': '약한'},
      {'word': 'Rich', 'meaning': '부유한'},
      {'word': 'Poor', 'meaning': '가난한'},
      {'word': 'Smart', 'meaning': '똑똑한'},
    ];

    final selected = simpleWords[random.nextInt(simpleWords.length)];
    final correctWord = selected['word']!;
    final correctMeaning = selected['meaning']!;

    // 간단한 오답들
    final wrongMeanings = ['잘못된', '틀린', '다른'];

    List<String> options = [correctMeaning, ...wrongMeanings];
    options.shuffle(random);
    final correctIndex = options.indexOf(correctMeaning);

    return GameQuestion(
      question: '"$correctWord"의 뜻은?',
      options: options,
      correctAnswerIndex: correctIndex,
      type: QuestionType.word,
      difficulty: difficulty,
      explanation: correctMeaning,
    );
  }

  static GameQuestion _generateFallbackGrammarQuestion(
    QuestionDifficulty difficulty,
  ) {
    final random = Random();

    final questions = [
      {
        'question': '다음 중 올바른 문장은?',
        'correct': 'I am going to school.',
        'wrong': <String>[
          'I going to school.',
          'I am go to school.',
          'I goes to school.',
        ],
      },
      {
        'question': '"나는 학생입니다"를 영어로 번역하면?',
        'correct': 'I am a student.',
        'wrong': <String>['I is a student.', 'I are a student.', 'I student.'],
      },
      {
        'question': '다음 중 과거형이 올바른 것은?',
        'correct': 'I went to the store.',
        'wrong': <String>[
          'I go to the store.',
          'I going to the store.',
          'I goes to the store.',
        ],
      },
    ];

    final selected = questions[random.nextInt(questions.length)];
    List<String> options = [
      selected['correct'] as String,
      ...(selected['wrong'] as List<String>),
    ];
    options.shuffle(random);
    final correctIndex = options.indexOf(selected['correct'] as String);

    return GameQuestion(
      question: selected['question'] as String,
      options: options,
      correctAnswerIndex: correctIndex,
      type: QuestionType.grammar,
      difficulty: difficulty,
      explanation: selected['correct'] as String,
    );
  }

  static GameQuestion _generateFallbackDialogQuestion(
    QuestionDifficulty difficulty,
  ) {
    final random = Random();

    final questions = [
      {
        'question': '"Hello"의 뜻은?',
        'correct': '안녕하세요',
        'wrong': <String>['감사합니다', '죄송합니다', '안녕히 가세요'],
      },
      {
        'question': '"Thank you"의 뜻은?',
        'correct': '감사합니다',
        'wrong': <String>['안녕하세요', '죄송합니다', '안녕히 가세요'],
      },
      {
        'question': '"Sorry"의 뜻은?',
        'correct': '죄송합니다',
        'wrong': <String>['안녕하세요', '감사합니다', '안녕히 가세요'],
      },
    ];

    final selected = questions[random.nextInt(questions.length)];
    List<String> options = [
      selected['correct'] as String,
      ...(selected['wrong'] as List<String>),
    ];
    options.shuffle(random);
    final correctIndex = options.indexOf(selected['correct'] as String);

    return GameQuestion(
      question: selected['question'] as String,
      options: options,
      correctAnswerIndex: correctIndex,
      type: QuestionType.dialog,
      difficulty: difficulty,
      explanation: selected['correct'] as String,
    );
  }

  static bool _isDifficultyMatch(String level, QuestionDifficulty difficulty) {
    // 간단한 난이도 매칭 로직
    final levelLower = level.toLowerCase();

    switch (difficulty) {
      case QuestionDifficulty.bronze1:
      case QuestionDifficulty.bronze2:
      case QuestionDifficulty.bronze3:
        return levelLower.contains('고교') || levelLower.contains('basic');
      case QuestionDifficulty.silver1:
      case QuestionDifficulty.silver2:
      case QuestionDifficulty.silver3:
        return levelLower.contains('toefl') ||
            levelLower.contains('intermediate');
      case QuestionDifficulty.gold1:
      case QuestionDifficulty.gold2:
      case QuestionDifficulty.gold3:
        return levelLower.contains('gre') || levelLower.contains('advanced');
      case QuestionDifficulty.platinum1:
      case QuestionDifficulty.platinum2:
      case QuestionDifficulty.platinum3:
        return levelLower.contains('master') || levelLower.contains('expert');
      case QuestionDifficulty.diamond1:
      case QuestionDifficulty.diamond2:
      case QuestionDifficulty.diamond3:
        return levelLower.contains('expert') ||
            levelLower.contains('professional');
      case QuestionDifficulty.master1:
      case QuestionDifficulty.master2:
      case QuestionDifficulty.master3:
        return levelLower.contains('master') || levelLower.contains('expert');
    }
  }
}
