import 'package:equatable/equatable.dart';

/// Quiz data model
class QuizModel extends Equatable {
  final String id;
  final String title;
  final String courseId;
  final int totalQuestions;
  final int timeLimitMinutes;
  final int passingScore;
  final List<QuestionModel> questions;

  const QuizModel({
    required this.id,
    required this.title,
    required this.courseId,
    required this.totalQuestions,
    required this.timeLimitMinutes,
    required this.passingScore,
    required this.questions,
  });

  @override
  List<Object> get props => [id, title];
}

/// Question data model
class QuestionModel extends Equatable {
  final String id;
  final String question;
  final List<QuizOption> options;
  final int correctOptionIndex;
  final String explanation;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });

  @override
  List<Object> get props => [id, question];
}

/// Quiz option
class QuizOption extends Equatable {
  final String id;
  final String text;

  const QuizOption({
    required this.id,
    required this.text,
  });

  @override
  List<Object> get props => [id, text];
}

/// Quiz result
class QuizResult extends Equatable {
  final String quizId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeTakenSeconds;
  final DateTime completedAt;
  final bool passed;

  const QuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeTakenSeconds,
    required this.completedAt,
    required this.passed,
  });

  @override
  List<Object> get props => [quizId, score, completedAt];
}
