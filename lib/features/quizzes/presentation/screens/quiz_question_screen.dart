import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../providers/quiz_provider.dart';
import '../widgets/option_card.dart';

/// Quiz question screen with timer and options
class QuizQuestionScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizQuestionScreen({super.key, required this.quizId});

  @override
  ConsumerState<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends ConsumerState<QuizQuestionScreen> {
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).loadQuiz(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final quiz = quizState.currentQuiz;
    final currentQuestion = quizState.currentQuestion;

    if (quizState.isLoading || quiz == null || currentQuestion == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (quizState.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Pass quizId, score, and total via query params + extra
        final uri = Uri(
          path: Routes.quizResult,
          queryParameters: {
            'score': quizState.score.toString(),
            'total': quizState.totalQuestions.toString(),
          },
        );
        context.go(uri.toString(), extra: quiz.id);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedAnswer = quizState.selectedAnswers[quizState.currentQuestionIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress and timer
            _buildHeader(quizState),

            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question number
                    Text(
                      'Question ${quizState.currentQuestionIndex + 1} of ${quizState.totalQuestions}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.1, end: 0),

                    const SizedBox(height: AppSpacing.sm),

                    // Question text
                    Text(
                      currentQuestion.question,
                      style: AppTextStyles.headlineMedium,
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Options
                    ...List.generate(
                      currentQuestion.options.length,
                      (index) {
                        final option = currentQuestion.options[index];
                        final isSelected = selectedAnswer == index;
                        final isCorrect =
                            index == currentQuestion.correctOptionIndex;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: OptionCard(
                            option: option,
                            index: index,
                            isSelected: isSelected,
                            isCorrect: _showFeedback ? isCorrect : null,
                            isWrong: _showFeedback && isSelected && !isCorrect,
                            onTap: _showFeedback
                                ? null
                                : () {
                                    ref
                                        .read(quizProvider.notifier)
                                        .selectAnswer(index);
                                  setState(() => _showFeedback = true);
                                  // Auto-advance after feedback
                                  Future.delayed(
                                      const Duration(seconds: 1), () {
                                    if (mounted) {
                                      setState(() => _showFeedback = false);
                                      ref
                                          .read(quizProvider.notifier)
                                          .nextQuestion();
                                    }
                                  });
                                  },
                          )
                              .animate(delay: (100 * index).ms)
                              .fadeIn()
                              .slideY(begin: 0.1, end: 0),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            _buildNavigation(quizState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(QuizState quizState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded),
              ),

              // Progress info
              Expanded(
                child: Text(
                  '${quizState.currentQuestionIndex + 1}/${quizState.totalQuestions}',
                  style: AppTextStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              // Timer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 16, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${(quizState.currentQuiz?.timeLimitMinutes ?? 0)}:00',
                      style: AppTextStyles.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: quizState.progress,
              backgroundColor: AppColors.greyLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(QuizState quizState) {
    final isFirst = quizState.currentQuestionIndex == 0;
    final isLast =
        quizState.currentQuestionIndex == quizState.totalQuestions - 1;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (!isFirst)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(quizProvider.notifier).previousQuestion();
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Previous'),
              ),
            ),

          if (!isFirst) const SizedBox(width: AppSpacing.md),

          // Next button
          Expanded(
            flex: isFirst ? 1 : 1,
            child: ElevatedButton(
              onPressed: quizState
                          .selectedAnswers[quizState.currentQuestionIndex] !=
                      null
                  ? () {
                      ref.read(quizProvider.notifier).nextQuestion();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                disabledBackgroundColor: AppColors.greyMedium,
              ),
              child: Text(isLast ? 'Finish' : 'Next →'),
            ),
          ),
        ],
      ),
    );
  }
}
