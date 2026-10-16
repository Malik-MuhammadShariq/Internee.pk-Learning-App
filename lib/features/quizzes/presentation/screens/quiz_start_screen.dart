import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/data/mock_data_service.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/widgets/animated_button.dart';

/// Quiz start screen with info card
class QuizStartScreen extends ConsumerWidget {
  final String quizId;

  const QuizStartScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockData = MockDataService();
    final quiz = mockData.getQuizById(quizId);

    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),

              const SizedBox(height: AppSpacing.lg),

              // Quiz illustration
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                ),
                child: const Center(
                  child: Text('🧠', style: TextStyle(fontSize: 80)),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  )
                  .shimmer(delay: 500.ms, duration: 1000.ms),

              const SizedBox(height: AppSpacing.lg),

              // Quiz title
              Text(
                quiz.title,
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'Test your knowledge',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: AppSpacing.xl),

              // Info card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.quiz_outlined,
                      'Questions',
                      '${quiz.totalQuestions}',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow(
                      Icons.timer_outlined,
                      'Time Limit',
                      '${quiz.timeLimitMinutes} minutes',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow(
                      Icons.check_circle_outline_rounded,
                      'Passing Score',
                      '${quiz.passingScore}%',
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.xl),

              // Start button
              AnimatedButton(
                text: 'Start Quiz',
                onPressed: () {
                  context.go(Routes.quizQuestion, extra: quizId);
                },
                icon: Icons.play_arrow_rounded,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.md),

              Text(
                'You can\'t pause once started',
                style: AppTextStyles.caption.copyWith(color: AppColors.grey),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}
