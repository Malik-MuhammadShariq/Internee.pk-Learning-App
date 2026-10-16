import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/firestore_progress_service.dart';
import '../../../../app/router/routes.dart';
import '../../data/models/course_model.dart';
import '../providers/course_provider.dart';
import '../../../auth/presentation/providers/firebase_providers.dart';
import '../screens/search_screen.dart';
import '../../../../features/progress/presentation/screens/progress_dashboard.dart';
import '../../../../features/profile/presentation/screens/profile_screen.dart';
import '../widgets/course_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/featured_course_slider.dart';
import '../widgets/continue_learning_card.dart';

/// Home screen — main dashboard with course discovery
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentNavIndex = 0;
  List<String> _continueLearningCourseIds = [];

  /// Tab history stack for Android back button navigation.
  /// Starts with [0] = Home. Each tab tap pushes the new index.
  /// Back button pops the stack and switches to previous tab.
  final List<int> _tabHistory = [0];

  /// Tracks whether the "Press back again to exit" snackbar is showing.
  /// Used to detect second back press within 2 seconds.
  bool _exitSnackbarVisible = false;

  @override
  void initState() {
    super.initState();
    _loadContinueLearning();
  }

  Future<void> _loadContinueLearning() async {
    final progressService = ref.read(firestoreProgressServiceProvider);
    final courseState = ref.read(courseProvider);
    final allIds = courseState.courses.map((c) => c.id).toList();
    final ids = await progressService.getCourseIdsWithProgress(allIds);
    if (mounted) {
      setState(() {
        _continueLearningCourseIds = ids;
      });
    }
  }

  /// Handle tab tap — switches tab locally and pushes to history stack.
  void _onNavTap(int index) {
    if (index == _currentNavIndex) return; // Same tab — skip

    setState(() {
      _currentNavIndex = index;
      // Push to history stack (skip if same as current top)
      if (_tabHistory.isEmpty || _tabHistory.last != index) {
        _tabHistory.add(index);
      }
    });
  }

  /// Handle Android back button within the shell.
  /// - If history has more than 1 entry → pop and go to previous tab
  /// - If on Home with only 1 entry → show "Press back again to exit" snackbar
  /// - Second press within 2 seconds → exit app
  void _handleBackPress() {
    if (_exitSnackbarVisible) {
      // Second back press within 2 seconds — exit app
      SystemNavigator.pop();
      return;
    }

    if (_tabHistory.length > 1) {
      // Pop current tab and go to previous
      setState(() {
        _tabHistory.removeLast();
        _currentNavIndex = _tabHistory.last;
      });
    } else {
      // On Home — show "Press back again to exit" snackbar
      _exitSnackbarVisible = true;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Press back again to exit'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

      // Reset flag after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _exitSnackbarVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseProvider);

    return PopScope(
      // Intercept back button to navigate tab history instead of exiting
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return; // Route was popped normally (e.g. course player back)
        _handleBackPress(); // Intercept back to navigate tab history
      },
      child: Scaffold(
        body: SafeArea(
          child: _buildTabContent(courseState),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  /// Build content for the current tab index.
  Widget _buildTabContent(CourseState courseState) {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeContent(courseState);
      case 1:
        return const SearchScreen();
      case 2:
        return const ProgressDashboard();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent(courseState);
    }
  }

  Widget _buildHomeContent(CourseState courseState) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(courseProvider.notifier).loadCourses();
        await _loadContinueLearning();
      },
      child: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverToBoxAdapter(
            child: _buildAppBar(),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),

          // Categories
          SliverToBoxAdapter(
            child: _buildCategories(courseState),
          ),

          // Featured Courses
          SliverToBoxAdapter(
            child: _buildSectionTitle(AppStrings.featuredCourses),
          ),
          SliverToBoxAdapter(
            child: FeaturedCourseSlider(
              courses: courseState.courses,
              isLoading: courseState.isLoading,
            ),
          ),

          // Continue Learning — only if user has progress
          if (_continueLearningCourseIds.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionTitle(AppStrings.continueLearning),
            ),
            SliverToBoxAdapter(
              child: _buildContinueLearning(courseState),
            ),
          ],

          // All Courses
          SliverToBoxAdapter(
            child: _buildSectionTitle(AppStrings.allCourses),
          ),

          // Course list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: courseState.isLoading
                ? const SliverToBoxAdapter(
                    child: SizedBox(height: 300),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = courseState.courses[index];
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _CourseCardWithProgress(
                            course: course,
                            onTap: () => context.go(
                              Routes.coursePlayer,
                              extra: course.id,
                            ),
                          )
                              .animate(delay: (50 * index).ms)
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: 0.1, end: 0),
                        );
                      },
                      childCount: courseState.courses.length,
                    ),
                  ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xl),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusXl),
          bottomRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Row(
        children: [
          // Profile avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.white.withValues(alpha: 0.2),
            child: const Text('👤', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Greeting — name from Firestore users/{uid} stream
          Expanded(
            child: _GreetingWithProfile(),
          ),

          // Notification bell
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.white,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: GestureDetector(
        onTap: () => _onNavTap(1), // Switch to Courses/Search tab locally
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.grey),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.searchCourses,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildCategories(CourseState courseState) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: courseState.categories.length,
        itemBuilder: (context, index) {
          final category = courseState.categories[index];
          final isSelected = courseState.selectedCategory == category.name;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: CategoryChip(
              label: category.name,
              icon: category.icon,
              isSelected: isSelected,
              onTap: () {
                ref.read(courseProvider.notifier).selectCategory(category.name);
              },
            ).animate(delay: (50 * index).ms).fadeIn().scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.headlineMedium,
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildContinueLearning(CourseState courseState) {
    final courses = courseState.courses
        .where((c) => _continueLearningCourseIds.contains(c.id))
        .toList();

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _ContinueLearningCardWithProgress(
              course: course,
              onTap: () => context.go(Routes.coursePlayer, extra: course.id),
            ).animate(delay: (80 * index).ms).fadeIn().slideX(begin: 0.2, end: 0),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

}

/// Course card that loads its own progress from ProgressService
class _CourseCardWithProgress extends ConsumerWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const _CourseCardWithProgress({
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressService = ref.watch(firestoreProgressServiceProvider);
    return FutureBuilder<double>(
      future: progressService.getCourseProgress(course.id, course.chapterCount),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        return CourseCard(
          course: course,
          progress: progress,
          onTap: onTap,
        );
      },
    );
  }
}

/// Continue learning card with async progress
class _ContinueLearningCardWithProgress extends ConsumerWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const _ContinueLearningCardWithProgress({
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressService = ref.watch(firestoreProgressServiceProvider);
    return FutureBuilder<double>(
      future: progressService.getCourseProgress(course.id, course.chapterCount),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        return ContinueLearningCard(
          course: course,
          progress: progress,
          onTap: onTap,
        );
      },
    );
  }
}

/// Greeting widget that reads name from Firestore users/{uid} stream.
/// Falls back to "Hi, Learner!" while loading or if doc is missing.
class _GreetingWithProfile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(authStateProvider);

    return asyncUser.when(
      data: (fbUser) {
        if (fbUser == null) {
          // Not logged in — show fallback
          return _buildGreeting(context, 'Learner');
        }

        // Watch the Firestore profile doc stream (live updates)
        final profileAsync =
            ref.watch(userProfileProvider(fbUser.uid));

        return profileAsync.when(
          data: (snapshot) {
            final data = snapshot?.data() as Map<String, dynamic>?;
            final name = (data?['name'] as String?)?.trim() ?? '';
            final displayName = name.isNotEmpty ? name : 'Learner';
            return _buildGreeting(context, displayName);
          },
          loading: () => _buildGreeting(context, 'Learner'),
          error: (_, __) => _buildGreeting(context, 'Learner'),
        );
      },
      loading: () => _buildGreeting(context, 'Learner'),
      error: (_, __) => _buildGreeting(context, 'Learner'),
    );
  }

  Widget _buildGreeting(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, $name!',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.white,
          ),
        ).animate().fadeIn().slideY(begin: -0.2, end: 0),
        Text(
          'What do you want to learn today?',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
          ),
        ).animate().fadeIn(delay: 100.ms),
      ],
    );
  }
}
