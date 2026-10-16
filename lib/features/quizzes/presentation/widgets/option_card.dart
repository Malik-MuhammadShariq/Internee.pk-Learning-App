import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../data/models/quiz_model.dart';

/// Quiz option card with selection and feedback animations
class OptionCard extends StatelessWidget {
  final QuizOption option;
  final int index;
  final bool isSelected;
  final bool? isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.index,
    this.isSelected = false,
    this.isCorrect,
    this.isWrong = false,
    this.onTap,
  });

  Color get _borderColor {
    if (isWrong) return AppColors.error;
    if (isCorrect == true) return AppColors.success;
    if (isSelected) return AppColors.primary;
    return AppColors.greyMedium;
  }

  Color get _backgroundColor {
    if (isWrong) return AppColors.error.withValues(alpha: 0.1);
    if (isCorrect == true) return AppColors.success.withValues(alpha: 0.1);
    if (isSelected) return AppColors.primary.withValues(alpha: 0.05);
    return AppColors.white;
  }

  String get _letter => String.fromCharCode(65 + index); // A, B, C, D

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: _borderColor,
            width: isSelected || isCorrect == true || isWrong ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Letter badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _borderColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              alignment: Alignment.center,
              child: Text(
                _letter,
                style: AppTextStyles.titleMedium.copyWith(
                  color: _borderColor,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Option text
            Expanded(
              child: Text(
                option.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            // Status icon
            if (isCorrect == true)
              const Icon(Icons.check_circle_rounded, color: AppColors.success)
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  )
            else if (isWrong)
              const Icon(Icons.cancel_rounded, color: AppColors.error)
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  ),
          ],
        ),
      ),
    );
  }
}
