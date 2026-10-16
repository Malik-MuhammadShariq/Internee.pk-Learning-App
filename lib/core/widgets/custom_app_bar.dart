import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../extensions/context_extensions.dart';

/// Custom app bar with gradient background
class CustomGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double elevation;

  const CustomGradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: AppBar(
        title: Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: elevation,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: actions,
      ),
    );
  }
}

/// Standard clean app bar
class CleanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;

  const CleanAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = false,
    this.showBackButton = false,
    this.onBackPressed,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.headlineSmall),
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed:
                      onBackPressed ?? () => Navigator.of(context).pop(),
                )
              : null),
      actions: actions,
      iconTheme: IconThemeData(color: context.colorScheme.onSurface),
    );
  }
}
