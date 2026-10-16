import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/services/firestore_quiz_service.dart';
import '../../presentation/providers/quiz_provider.dart';

/// Quiz result screen with score animation + Firestore persistence
class QuizResultScreen extends ConsumerStatefulWidget {
  final String quizId;
  final int score;
  final int total;

  const QuizResultScreen({
    super.key,
    required this.quizId,
    required this.score,
    required this.total,
  });

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  bool _resultSaved = false;

  @override
  void initState() {
    super.initState();
    // Persist result to Firestore on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveResult();
    });
  }

  Future<void> _saveResult() async {
    if (_resultSaved) return;
    _resultSaved = true;

    final quizService = ref.read(firestoreQuizServiceProvider);
    final result = ref.read(latestQuizResultProvider);

    // Use the latest result from provider (has timeTakenSec) if available,
    // otherwise fall back to constructor params
    final score = result?.score ?? widget.score;
    final total = result?.total ?? widget.total;
    final timeTakenSec = result?.timeTakenSec ?? 0;
    final courseId = result?.courseId ?? '';

    await quizService.saveResult(
      courseId: courseId,
      quizId: widget.quizId,
      score: score,
      total: total,
      timeTakenSec: timeTakenSec,
    );
  }

  double get _percentage => widget.total > 0 ? (widget.score / widget.total) * 100 : 0;
  bool get _passed => _percentage >= 60;

  String get _message {
    if (_percentage >= 90) return 'Outstanding! 🏆';
    if (_percentage >= 70) return 'Great Job! 🎉';
    if (_percentage >= 60) return 'Well Done! 👍';
    return 'Keep Practicing! 💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),

              // Result icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: _passed
                      ? AppColors.successGradient
                      : AppColors.warmGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_passed ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _passed ? '🎉' : '📖',
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .shimmer(delay: 500.ms, duration: 1000.ms),

              const SizedBox(height: AppSpacing.lg),

              // Message
              Text(
                _message,
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.xs),

              Text(
                _passed
                    ? 'You passed the quiz!'
                    : 'You can do better next time',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: AppSpacing.xl),

              // Score circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _percentage / 100),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 10,
                          backgroundColor: AppColors.greyLight,
                          valueColor: AlwaysStoppedAnimation(
                            _passed ? AppColors.success : AppColors.error,
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: widget.score),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return Text(
                            '$value',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: _passed
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          );
                        },
                      ),
                      Text(
                        '/ ${widget.total}',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Stats cards
              Row(
                children: [
                  _buildStatCard(
                    'Correct',
                    '${widget.score}',
                    AppColors.success,
                    Icons.check_circle_outline_rounded,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildStatCard(
                    'Wrong',
                    '${widget.total - widget.score}',
                    AppColors.error,
                    Icons.cancel_outlined,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildStatCard(
                    'Score',
                    '${_percentage.toInt()}%',
                    AppColors.primary,
                    Icons.percent_rounded,
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              AnimatedButton(
                text: AppStrings.continueCourse,
                onPressed: () => context.go(Routes.home),
                icon: Icons.home_rounded,
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.sm),

              AnimatedButton(
                text: AppStrings.retryQuiz,
                onPressed: () =>
                    context.go('${Routes.quizQuestion}?quizId=${widget.quizId}'),
                isOutlined: true,
                icon: Icons.refresh_rounded,
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(color: color),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
