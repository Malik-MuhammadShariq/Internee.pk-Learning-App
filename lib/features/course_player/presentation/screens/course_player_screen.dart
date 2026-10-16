import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/data/mock_data_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/firestore_progress_service.dart';
import '../../../dashboard/data/models/course_model.dart';
import '../widgets/curriculum_sheet.dart';

/// Course player screen — real WebView for Internee.pk course content
class CoursePlayerScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CoursePlayerScreen({super.key, required this.courseId});

  @override
  ConsumerState<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends ConsumerState<CoursePlayerScreen> {
  late final WebViewController _controller;
  final _mockData = MockDataService();
  int _selectedTab = 0;
  bool _isLoading = true;
  bool _hasInternet = true;
  bool _loginBannerDismissed = false;
  double _progress = 0.0;

  CourseModel? get _course {
    try {
      return _mockData.allCourses.firstWhere((c) => c.id == widget.courseId);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadLoginBannerState();
    _loadProgress();
    _initWebView();
  }

  Future<void> _checkConnectivity() async {
    final connectivity = ref.read(connectivityServiceProvider);
    final connected = await connectivity.isConnected();
    if (mounted) setState(() => _hasInternet = connected);
  }

  Future<void> _loadLoginBannerState() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool(StorageKeys.loginBannerDismissed) ?? false;
    if (mounted) setState(() => _loginBannerDismissed = dismissed);
  }

  Future<void> _dismissLoginBanner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.loginBannerDismissed, true);
    if (mounted) setState(() => _loginBannerDismissed = true);
  }

  Future<void> _loadProgress() async {
    final course = _course;
    if (course == null) return;
    final progressService = ref.read(firestoreProgressServiceProvider);
    final p = await progressService.getCourseProgress(
      course.id,
      course.chapterCount,
    );
    if (mounted) setState(() => _progress = p);
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(_course?.courseUrl ?? 'https://www.internee.pk'));
  }

  @override
  Widget build(BuildContext context) {
    final course = _course;

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Not Found')),
        body: const Center(child: Text('Course not found')),
      );
    }

    return PopScope(
      canPop: _selectedTab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedTab != 0) {
          setState(() => _selectedTab = 0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(
            course.title,
            style: AppTextStyles.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () => _showOptions(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            if (_progress > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: AppColors.greyLight,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.success),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn()
                  .slideY(begin: -0.2, end: 0),

            // Login banner (green, dismissible)
            if (!_loginBannerDismissed)
              _buildLoginBanner()
                  .animate()
                  .fadeIn()
                  .slideY(begin: -0.2, end: 0),

            // Tab content
            Expanded(
              child: _buildTabContent(course),
            ),

            // Bottom tabs
            _buildBottomTabs(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.loginToTrackProgress,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _dismissLoginBanner();
              // Could navigate to login
            },
            child: Text(
              'Dismiss',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(CourseModel course) {
    switch (_selectedTab) {
      case 0:
        return _buildLearnTab(course);
      case 1:
        return CurriculumSheet(
          courseId: widget.courseId,
          isInline: true,
          onChapterTap: () => setState(() => _selectedTab = 0),
        );
      case 2:
        return _buildAboutTab(course);
      default:
        return _buildLearnTab(course);
    }
  }

  Widget _buildLearnTab(CourseModel course) {
    if (!_hasInternet) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.noInternetForCourse,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                _checkConnectivity();
                _controller.reload();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(AppStrings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: AppColors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ).animate().fadeIn(),
      ],
    );
  }

  Widget _buildAboutTab(CourseModel course) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: AppTextStyles.headlineMedium,
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${AppStrings.courseBy} ${course.instructor}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildInfoChip(Icons.signal_cellular_alt_rounded, course.level),
              const SizedBox(width: AppSpacing.sm),
              _buildInfoChip(Icons.access_time_rounded, course.duration),
              const SizedBox(width: AppSpacing.sm),
              _buildInfoChip(Icons.list_alt_rounded, '${course.chapterCount} ch'),
            ],
          ).animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Description',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            course.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey,
              height: 1.6,
            ),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grey),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTabs() {
    return Container(
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
          _buildTab(0, Icons.play_circle_outline_rounded, AppStrings.learn),
          _buildTab(1, Icons.list_alt_rounded, AppStrings.curriculum),
          _buildTab(2, Icons.info_outline_rounded, AppStrings.aboutCourse),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.grey,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share course'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Reload page'),
              onTap: () {
                _controller.reload();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report issue'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
