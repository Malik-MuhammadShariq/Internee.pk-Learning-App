import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../app/router/routes.dart';
import '../../data/models/course_model.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

/// Search screen with live results
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isEmpty
        ? <CourseModel>[]
        : ref.read(courseProvider.notifier).searchCourses(_query);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.searchCourses),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: AppStrings.searchCourses,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.greyLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _query.isEmpty
          ? _buildEmptySearch()
          : results.isEmpty
              ? _buildNoResults()
              : _buildResults(results),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: AppColors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Search for courses',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Find Programming, Technology courses and more',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 60)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No courses found',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try a different search term',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    ).animate().fadeIn().shake();
  }

  Widget _buildResults(List<CourseModel> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final course = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: CourseCard(
            course: course,
            onTap: () => context.go(Routes.coursePlayer, extra: course.id),
          ).animate(delay: (50 * index).ms).fadeIn().slideY(begin: 0.1, end: 0),
        );
      },
    );
  }
}
