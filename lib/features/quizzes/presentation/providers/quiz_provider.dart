import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/quiz_model.dart';
import '../../../../core/data/mock_data_service.dart';

/// Quiz result — emitted on completion for Firestore persistence
class QuizResult {
  final String quizId;
  final String courseId;
  final int score;
  final int total;
  final int timeTakenSec;

  const QuizResult({
    required this.quizId,
    required this.courseId,
    required this.score,
    required this.total,
    required this.timeTakenSec,
  });
}

/// Quiz state
class QuizState {
  final QuizModel? currentQuiz;
  final int currentQuestionIndex;
  final List<int?> selectedAnswers;
  final bool isCompleted;
  final int score;
  final int timeTakenSec;
  final bool isLoading;

  const QuizState({
    this.currentQuiz,
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const [],
    this.isCompleted = false,
    this.score = 0,
    this.timeTakenSec = 0,
    this.isLoading = false,
  });

  QuizState copyWith({
    QuizModel? currentQuiz,
    int? currentQuestionIndex,
    List<int?>? selectedAnswers,
    bool? isCompleted,
    int? score,
    int? timeTakenSec,
    bool? isLoading,
  }) {
    return QuizState(
      currentQuiz: currentQuiz ?? this.currentQuiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      timeTakenSec: timeTakenSec ?? this.timeTakenSec,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Get current question
  QuestionModel? get currentQuestion {
    if (currentQuiz == null) return null;
    if (currentQuestionIndex >= currentQuiz!.questions.length) return null;
    return currentQuiz!.questions[currentQuestionIndex];
  }

  /// Get total questions
  int get totalQuestions => currentQuiz?.totalQuestions ?? 0;

  /// Get progress percentage
  double get progress {
    if (totalQuestions == 0) return 0;
    return (currentQuestionIndex + 1) / totalQuestions;
  }
}

/// Quiz notifier
class QuizNotifier extends StateNotifier<QuizState> {
  final MockDataService _mockData;
  DateTime? _startTime;

  QuizNotifier(this._mockData) : super(const QuizState());

  /// Load quiz
  Future<void> loadQuiz(String quizId) async {
    state = state.copyWith(isLoading: true);
    _startTime = DateTime.now();

    await Future.delayed(const Duration(milliseconds: 500));

    final quiz = _mockData.getQuizById(quizId);
    state = state.copyWith(
      currentQuiz: quiz,
      currentQuestionIndex: 0,
      selectedAnswers: List.filled(quiz?.totalQuestions ?? 0, null),
      isCompleted: false,
      score: 0,
      timeTakenSec: 0,
      isLoading: false,
    );
  }

  /// Select answer for current question
  void selectAnswer(int answerIndex) {
    final answers = List<int?>.from(state.selectedAnswers);
    answers[state.currentQuestionIndex] = answerIndex;
    state = state.copyWith(selectedAnswers: answers);
  }

  /// Go to next question
  void nextQuestion() {
    if (state.currentQuestionIndex < state.totalQuestions - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    } else {
      _completeQuiz();
    }
  }

  /// Go to previous question
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  /// Complete quiz and calculate score
  void _completeQuiz() {
    int score = 0;
    for (int i = 0; i < state.totalQuestions; i++) {
      if (state.selectedAnswers[i] ==
          state.currentQuiz!.questions[i].correctOptionIndex) {
        score++;
      }
    }

    // Calculate time taken
    final timeTakenSec = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;

    state = state.copyWith(
      isCompleted: true,
      score: score,
      timeTakenSec: timeTakenSec,
    );
  }

  /// Reset quiz
  void reset() {
    state = const QuizState();
  }
}

/// Quiz provider
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(MockDataService());
});

/// Provider to get the latest quiz result as a QuizResult object
/// Used by the result screen for Firestore persistence
final latestQuizResultProvider = Provider<QuizResult?>((ref) {
  final state = ref.watch(quizProvider);
  if (!state.isCompleted || state.currentQuiz == null) return null;
  return QuizResult(
    quizId: state.currentQuiz!.id,
    courseId: state.currentQuiz!.courseId,
    score: state.score,
    total: state.totalQuestions,
    timeTakenSec: state.timeTakenSec,
  );
});
