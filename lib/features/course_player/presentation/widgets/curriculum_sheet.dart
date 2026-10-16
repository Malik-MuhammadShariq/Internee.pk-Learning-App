import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/data/mock_data_service.dart';
import '../../../../core/services/firestore_progress_service.dart';
import '../../../dashboard/data/models/course_model.dart';

/// Curriculum sheet — can be used as bottom sheet OR inline tab
class CurriculumSheet extends ConsumerStatefulWidget {
  final String courseId;
  final bool isInline;
  final VoidCallback? onChapterTap;

  const CurriculumSheet({
    super.key,
    required this.courseId,
    this.isInline = false,
    this.onChapterTap,
  });

  @override
  ConsumerState<CurriculumSheet> createState() => _CurriculumSheetState();
}

class _CurriculumSheetState extends ConsumerState<CurriculumSheet> {
  final _mockData = MockDataService();

  @override
  Widget build(BuildContext context) {
    final chapters = _mockData.getChaptersForCourse(widget.courseId);

    if (widget.isInline) {
      return _buildInline(chapters);
    }
    return _buildBottomSheet(chapters);
  }

  Widget _buildBottomSheet(List<ChapterModel> chapters) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Text(
                      'Course Curriculum',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _buildChapterList(chapters),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInline(List<ChapterModel> chapters) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Text(
                'Course Curriculum',
                style: AppTextStyles.headlineSmall,
              ),
              const Spacer(),
              Text(
                '${chapters.length} chapters',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildChapterList(chapters),
        ),
      ],
    );
  }

  Widget _buildChapterList(List<ChapterModel> chapters) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return _ChapterTile(
          chapter: chapter,
          index: index,
          courseId: widget.courseId,
          onTap: widget.onChapterTap,
        ).animate(delay: (80 * index).ms).fadeIn().slideY(begin: 0.1, end: 0);
      },
    );
  }
}

/// Individual chapter tile with circular checkbox and play button
class _ChapterTile extends ConsumerStatefulWidget {
  final ChapterModel chapter;
  final int index;
  final String courseId;
  final VoidCallback? onTap;

  const _ChapterTile({
    required this.chapter,
    required this.index,
    required this.courseId,
    this.onTap,
  });

  @override
  ConsumerState<_ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends ConsumerState<_ChapterTile>
    with SingleTickerProviderStateMixin {
  bool _isCompleted = false;
  bool _isToggling = false;
  late AnimationController _popController;
  late Animation<double> _popAnimation;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _popAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );
    _loadProgress();
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final progressService = ref.read(firestoreProgressServiceProvider);
    final completed = await progressService.isChapterCompleted(
      widget.courseId,
      widget.chapter.id,
    );
    if (mounted) setState(() => _isCompleted = completed);
  }

  Future<void> _toggleComplete() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);

    // Trigger pop animation
    _popController.forward().then((_) => _popController.reverse());

    final progressService = ref.read(firestoreProgressServiceProvider);
    final nowCompleted = await progressService.toggleChapter(
      widget.courseId,
      widget.chapter.id,
    );

    if (mounted) {
      setState(() {
        _isCompleted = nowCompleted;
        _isToggling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: _isCompleted
              ? AppColors.success.withValues(alpha: 0.05)
              : AppColors.greyLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: _isCompleted
                ? AppColors.success.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Circular checkbox with pop animation
            GestureDetector(
              onTap: _toggleComplete,
              child: AnimatedBuilder(
                animation: _popAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _popAnimation.value,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCompleted
                            ? AppColors.success
                            : Colors.transparent,
                        border: Border.all(
                          color: _isCompleted
                              ? AppColors.success
                              : AppColors.grey,
                          width: 2,
                        ),
                      ),
                      child: _isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: AppColors.white,
                            )
                          : Center(
                              child: Text(
                                '${widget.index + 1}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Chapter info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapter.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration:
                          _isCompleted ? TextDecoration.none : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.chapter.durationMinutes} min',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Play icon button
            IconButton(
              onPressed: widget.onTap,
              icon: Icon(
                _isCompleted
                    ? Icons.replay_rounded
                    : Icons.play_arrow_rounded,
                color: AppColors.primary,
              ),
              tooltip: _isCompleted ? 'Review chapter' : 'Play chapter',
            ),
          ],
        ),
      ),
    );
  }
}
