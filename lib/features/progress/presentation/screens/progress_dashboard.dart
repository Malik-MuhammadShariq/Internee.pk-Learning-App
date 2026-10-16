import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/data/mock_data_service.dart';
import '../../../../core/services/firestore_progress_service.dart';
import '../../../dashboard/data/models/course_model.dart';

/// Progress dashboard with charts and stats — driven by real 4 courses
class ProgressDashboard extends ConsumerWidget {
  const ProgressDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressService = ref.watch(firestoreProgressServiceProvider);
    final courses = MockDataService().allCourses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall stats cards (computed from real progress)
            FutureBuilder<_ProgressSummary>(
              future: _computeSummary(progressService, courses),
              builder: (context, snapshot) {
                final summary = snapshot.data ??
                    const _ProgressSummary(
                      overallPercentage: 0,
                      totalMinutesLearned: 0,
                      chaptersCompleted: 0,
                      currentStreak: 7,
                    );
                return Row(
                  children: [
                    _buildStatCard(
                      '${summary.overallPercentage}%',
                      'Learning',
                      AppColors.primary,
                      Icons.school_rounded,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatCard(
                      '${summary.totalMinutesLearned}',
                      'Minutes',
                      AppColors.secondary,
                      Icons.access_time_filled_rounded,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatCard(
                      '${summary.chaptersCompleted}',
                      'Chapters',
                      AppColors.success,
                      Icons.check_circle_outline_rounded,
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.2, end: 0);
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Weekly activity chart
            Text(
              'Weekly Activity',
              style: AppTextStyles.headlineSmall,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: AppSpacing.md),

            _buildWeeklyChart()
                .animate(delay: 300.ms)
                .fadeIn()
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Course progress (all 4 courses)
            Text(
              'Course Progress',
              style: AppTextStyles.headlineSmall,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: AppSpacing.md),

            ...courses.asMap().entries.map((entry) {
              final index = entry.key;
              final course = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: FutureBuilder<double>(
                  future: progressService.getCourseProgress(
                    course.id,
                    course.chapterCount,
                  ),
                  builder: (context, snapshot) {
                    final progress = snapshot.data ?? 0.0;
                    return _buildCourseProgressCard(course, progress)
                        .animate(delay: (100 * index).ms)
                        .fadeIn()
                        .slideX(begin: 0.1, end: 0);
                  },
                ),
              );
            }),

            const SizedBox(height: AppSpacing.lg),

            // Achievements
            Text(
              'Achievements',
              style: AppTextStyles.headlineSmall,
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: AppSpacing.md),

            _buildAchievements()
                .animate(delay: 600.ms)
                .fadeIn()
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Learning streak
            _buildStreakCard(7)
                .animate(delay: 700.ms)
                .fadeIn()
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<_ProgressSummary> _computeSummary(
    FirestoreProgressService progressService,
    List<CourseModel> courses,
  ) async {
    int totalChapters = 0;
    int completedChapters = 0;
    int totalMinutes = 0;

    for (final course in courses) {
      final completed =
          await progressService.getCompletedChapters(course.id);
      totalChapters += course.chapterCount;
      completedChapters += completed.length;
      for (final chapter in course.chapters) {
        if (completed.contains(chapter.id)) {
          totalMinutes += chapter.durationMinutes;
        }
      }
    }

    final overallPercentage =
        totalChapters > 0 ? ((completedChapters / totalChapters) * 100).toInt() : 0;

    return _ProgressSummary(
      overallPercentage: overallPercentage,
      totalMinutesLearned: totalMinutes,
      chaptersCompleted: completedChapters,
      currentStreak: 7,
    );
  }

  Widget _buildStatCard(
      String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
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

  Widget _buildWeeklyChart() {
    final hours = [2.5, 3.0, 1.5, 4.0, 2.0, 3.5, 1.0];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 5,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < days.length) {
                    return Text(
                      days[value.toInt()],
                      style: AppTextStyles.caption,
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            hours.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: hours[index],
                  gradient: AppColors.primaryGradient,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseProgressCard(CourseModel course, double progress) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course.title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            course.instructor,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.greyLight,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.success),
                  minHeight: 8,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {'icon': '🏆', 'title': 'First Chapter', 'desc': 'Complete your first chapter'},
      {'icon': '🎯', 'title': 'Quiz Master', 'desc': 'Score 100% on any quiz'},
      {'icon': '🔥', 'title': '7-Day Streak', 'desc': 'Learn for 7 days straight'},
      {'icon': '⭐', 'title': 'Top Scorer', 'desc': 'Be in the top 10%'},
      {'icon': '🎓', 'title': 'Certified', 'desc': 'Complete a full course'},
      {'icon': '📚', 'title': 'Bookworm', 'desc': 'Complete all chapters'},
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: achievements.map((achievement) {
        return Container(
          width: 100,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            children: [
              Text(
                achievement['icon']!,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                achievement['title']!,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.warmGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 48)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Day Streak!',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Keep it up! You\'re on fire!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary of progress across all courses
class _ProgressSummary {
  final int overallPercentage;
  final int totalMinutesLearned;
  final int chaptersCompleted;
  final int currentStreak;

  const _ProgressSummary({
    required this.overallPercentage,
    required this.totalMinutesLearned,
    required this.chaptersCompleted,
    required this.currentStreak,
  });
}
