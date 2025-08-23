import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/game_question.dart';

class QuestionService {
  static List<Map<String, dynamic>>? _wordData;
  static List<Map<String, dynamic>>? _grammarData;
  static List<Map<String, dynamic>>? _dialogData;

  static Future<void> initializeData() async {
    if (_wordData == null) {
      final wordJson = await rootBundle.loadString(
        'assets/datas/voca_10000.json',
      );
      _wordData = List<Map<String, dynamic>>.from(json.decode(wordJson));
    }

    if (_grammarData == null) {
      final grammarJson = await rootBundle.loadString(
        'assets/datas/english_by_basic_sentence.json',
      );
      _grammarData = List<Map<String, dynamic>>.from(json.decode(grammarJson));
    }

    if (_dialogData == null) {
      final dialogJson = await rootBundle.loadString(
        'assets/datas/your_life_style.json',
      );
      _dialogData = List<Map<String, dynamic>>.from(json.decode(dialogJson));
    }
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
        // 간단한 오답 생성 로직
        switch (originalQuestion.type) {
          case QuestionType.word:
            wrongAnswer = _generateWrongWordAnswer();
            break;
          case QuestionType.grammar:
            wrongAnswer = _generateWrongGrammarAnswer();
            break;
          case QuestionType.dialog:
            wrongAnswer = _generateWrongDialogAnswer();
            break;
        }
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

  static String _generateWrongWordAnswer() {
    final wrongAnswers = ['잘못된 뜻', '틀린 의미', '다른 뜻', '오답', '의미 없음'];
    return wrongAnswers[Random().nextInt(wrongAnswers.length)];
  }

  static String _generateWrongGrammarAnswer() {
    final wrongAnswers = [
      'am',
      'is',
      'are',
      'be',
      'go',
      'goes',
      'going',
      'went',
    ];
    return wrongAnswers[Random().nextInt(wrongAnswers.length)];
  }

  static String _generateWrongDialogAnswer() {
    final wrongAnswers = ['잘못된 표현', '틀린 뜻', '다른 의미', '오답'];
    return wrongAnswers[Random().nextInt(wrongAnswers.length)];
  }

  static GameQuestion _generateWordQuestion(QuestionDifficulty difficulty) {
    final random = Random();

    // 데이터가 초기화되지 않은 경우 기본 문제 생성
    if (_wordData == null) {
      return _generateSimpleWordQuestion(difficulty);
    }

    final wordData = _wordData!;

    // 난이도에 따라 필터링
    List<Map<String, dynamic>> filteredWords = wordData.where((word) {
      final level = word['level']?.toString().toLowerCase() ?? '';
      return _isDifficultyMatch(level, difficulty);
    }).toList();

    if (filteredWords.isEmpty) {
      filteredWords = wordData; // 필터링된 결과가 없으면 전체에서 선택
    }

    final selectedWord = filteredWords[random.nextInt(filteredWords.length)];
    final correctWord = selectedWord['word']?.toString() ?? '';
    final correctMeaning = selectedWord['word_meaning']?.toString() ?? '';

    // 간단한 단어만 선택 (긴 단어 제외)
    if (correctWord.length > 12 || correctMeaning.length > 15) {
      return _generateSimpleWordQuestion(difficulty);
    }

    // 오답 생성
    List<String> wrongMeanings = [];
    for (int i = 0; i < 3; i++) {
      String wrongMeaning;
      do {
        final randomWord = wordData[random.nextInt(wordData.length)];
        wrongMeaning = randomWord['word_meaning']?.toString() ?? '';
        // 오답도 간단하게
        if (wrongMeaning.length > 15) {
          wrongMeaning = '의미 없음';
        }
      } while (wrongMeaning == correctMeaning ||
          wrongMeanings.contains(wrongMeaning) ||
          wrongMeaning == '의미 없음');
      wrongMeanings.add(wrongMeaning);
    }

    // 옵션 섞기
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

  static GameQuestion _generateGrammarQuestion(QuestionDifficulty difficulty) {
    final random = Random();

    // 데이터가 초기화되지 않은 경우 기본 문제 생성
    if (_grammarData == null) {
      return _generateFallbackGrammarQuestion(difficulty);
    }

    // 간단한 문법 문제들
    final grammarQuestions = [
      {
        'question': '빈칸에 들어갈 단어는?',
        'sentence': 'I ___ a student.',
        'correct': 'am',
        'wrong': ['is', 'are', 'be'],
      },
      {
        'question': '빈칸에 들어갈 단어는?',
        'sentence': 'She ___ beautiful.',
        'correct': 'is',
        'wrong': ['am', 'are', 'be'],
      },
      {
        'question': '빈칸에 들어갈 단어는?',
        'sentence': 'They ___ happy.',
        'correct': 'are',
        'wrong': ['is', 'am', 'be'],
      },
      {
        'question': '빈칸에 들어갈 단어는?',
        'sentence': 'I ___ to school.',
        'correct': 'go',
        'wrong': ['goes', 'going', 'went'],
      },
      {
        'question': '빈칸에 들어갈 단어는?',
        'sentence': 'He ___ to school.',
        'correct': 'goes',
        'wrong': ['go', 'going', 'went'],
      },
      {
        'question': '빈칸에 들어갈 단어는?',
        'sentence': 'I ___ a book.',
        'correct': 'read',
        'wrong': ['reads', 'reading', 'readed'],
      },
      {
        'question': '빈칸에 들어갈 단어는?',
        'sentence': 'She ___ a book.',
        'correct': 'reads',
        'wrong': ['read', 'reading', 'readed'],
      },
      {
        'question': '빈칸에 들어갈 단어는?',
        'sentence': 'I ___ yesterday.',
        'correct': 'went',
        'wrong': ['go', 'goes', 'going'],
      },
      {
        'question': '빈칸에 들어갈 단어는?',
        'sentence': 'I ___ a car.',
        'correct': 'have',
        'wrong': ['has', 'having', 'haves'],
      },
      {
        'question': '빈칸에 들어갈 단어는?',
        'sentence': 'She ___ a car.',
        'correct': 'has',
        'wrong': ['have', 'having', 'haves'],
      },
    ];

    final selected = grammarQuestions[random.nextInt(grammarQuestions.length)];
    final question = selected['question'] as String;
    final sentence = selected['sentence'] as String;
    final correct = selected['correct'] as String;
    final wrong = selected['wrong'] as List<String>;

    List<String> options = [correct, ...wrong];
    options.shuffle(random);
    final correctIndex = options.indexOf(correct);

    return GameQuestion(
      question: '$question\n$sentence',
      options: options,
      correctAnswerIndex: correctIndex,
      type: QuestionType.grammar,
      difficulty: difficulty,
      explanation: correct,
    );
  }

  static GameQuestion _generateDialogQuestion(QuestionDifficulty difficulty) {
    final random = Random();

    // 데이터가 초기화되지 않은 경우 기본 문제 생성
    if (_dialogData == null) {
      return _generateFallbackDialogQuestion(difficulty);
    }

    // 간단한 대화 표현들
    final dialogExpressions = [
      {'word': 'Hello', 'meaning': '안녕하세요'},
      {'word': 'Goodbye', 'meaning': '안녕히 가세요'},
      {'word': 'Thank you', 'meaning': '감사합니다'},
      {'word': 'Sorry', 'meaning': '죄송합니다'},
      {'word': 'Please', 'meaning': '부탁합니다'},
      {'word': 'Excuse me', 'meaning': '실례합니다'},
      {'word': 'Nice to meet you', 'meaning': '만나서 반갑습니다'},
      {'word': 'How are you?', 'meaning': '어떻게 지내세요?'},
      {'word': 'I\'m fine', 'meaning': '잘 지내요'},
      {'word': 'What\'s your name?', 'meaning': '이름이 뭐예요?'},
      {'word': 'My name is', 'meaning': '제 이름은'},
      {'word': 'Where are you from?', 'meaning': '어디서 왔어요?'},
      {'word': 'I\'m from', 'meaning': '저는 ~에서 왔어요'},
      {'word': 'How old are you?', 'meaning': '몇 살이에요?'},
      {'word': 'I\'m ~ years old', 'meaning': '저는 ~살이에요'},
      {'word': 'What time is it?', 'meaning': '몇 시예요?'},
      {'word': 'It\'s time to', 'meaning': '~할 시간이에요'},
      {'word': 'I like', 'meaning': '저는 ~을 좋아해요'},
      {'word': 'I don\'t like', 'meaning': '저는 ~을 싫어해요'},
      {'word': 'Do you like?', 'meaning': '~을 좋아하세요?'},
    ];

    final selected =
        dialogExpressions[random.nextInt(dialogExpressions.length)];
    final word = selected['word']!;
    final meaning = selected['meaning']!;

    // 간단한 오답들
    final wrongMeanings = ['잘못된 표현', '틀린 뜻', '다른 의미'];

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
