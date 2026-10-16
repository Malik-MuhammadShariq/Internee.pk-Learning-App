import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../app/router/routes.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

/// Category screen showing filtered courses
class CategoryScreen extends ConsumerWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseState = ref.watch(courseProvider);
    final courses = category == 'All'
        ? courseState.courses
        : courseState.courses
            .where((c) => c.category == category)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: courses.isEmpty
          ? EmptyState(
              title: 'No courses yet',
              description: 'Courses in $category category coming soon!',
              icon: Icons.category_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: CourseCard(
                    course: course,
                    onTap: () =>
                        context.go(Routes.coursePlayer, extra: course.id),
                  )
                      .animate(delay: (50 * index).ms)
                      .fadeIn()
                      .slideY(begin: 0.1, end: 0),
                );
              },
            ),
    );
  }
}
