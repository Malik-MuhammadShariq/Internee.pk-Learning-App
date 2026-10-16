import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/firebase_providers.dart';

/// Profile screen with real Firebase user data from Firestore stream
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(authStateProvider);

    return asyncUser.when(
      data: (fbUser) {
        if (fbUser == null) {
          // Not logged in — shouldn't happen (guard), but handle gracefully
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Watch the Firestore profile doc stream
        final profileAsync =
            ref.watch(userProfileProvider(fbUser.uid));

        return profileAsync.when(
          data: (snapshot) {
            final data = snapshot?.data() as Map<String, dynamic>?;
            final name = data?['name'] as String? ??
                fbUser.displayName ?? 'User';
            final email = data?['email'] as String? ?? fbUser.email ?? '';
            final photoUrl = data?['photoUrl'] as String? ??
                fbUser.photoURL ??
                '';
            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xxl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(AppSpacing.radiusXxl),
                          bottomRight:
                              Radius.circular(AppSpacing.radiusXxl),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Avatar (initials circle — no network image)
                          _buildAvatar(name, photoUrl)
                              .animate()
                              .scale(
                                begin: const Offset(0, 0),
                                end: const Offset(1, 1),
                                duration: 600.ms,
                                curve: Curves.easeOutBack,
                              ),

                          const SizedBox(height: AppSpacing.md),

                          // Name with edit pencil
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                style:
                                    AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _showEditNameDialog(
                                  context,
                                  ref,
                                  fbUser.uid,
                                  name,
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 20,
                                  color:
                                      AppColors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 200.ms),

                          const SizedBox(height: AppSpacing.xs),

                          // Email
                          Text(
                            email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ).animate().fadeIn(delay: 300.ms),

                          const SizedBox(height: AppSpacing.md),

                          // Member since
                          Text(
                            'Member since ${_yearFromTimestamp(data?['joinDate'])}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white.withValues(alpha: 0.7),
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Stats row (from Firestore or defaults)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Row(
                        children: [
                          _buildStatItem('0', 'Courses', AppColors.primary),
                          _buildStatDivider(),
                          _buildStatItem('0', 'Hours', AppColors.secondary),
                          _buildStatDivider(),
                          _buildStatItem(
                              '0', 'Certificates', AppColors.success),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: AppSpacing.lg),

                    // Menu items
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profile',
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            onTap: () => context.go(Routes.settings),
                          ),
                          _buildMenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.info_outline_rounded,
                            title: 'About',
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            onTap: () => _showLogoutDialog(context, ref),
                            textColor: AppColors.error,
                            iconColor: AppColors.error,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const Scaffold(
            body: Center(child: Text('Error loading profile')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Auth error',
                  style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// Build avatar — initials circle (no network image dependency)
  Widget _buildAvatar(String name, String photoUrl) {
    // Use initials from name
    final initials = _getInitials(name);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 4),
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Extract initials from a name (max 2 chars)
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.greyMedium,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.grey),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(color: textColor),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: textColor ?? AppColors.grey,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }

  /// Edit name dialog → calls repository.updateName() via authProvider
  void _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Display name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                final success = await ref
                    .read(authProvider.notifier)
                    .updateName(newName);
                if (dialogContext.mounted) Navigator.pop(dialogContext);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Name updated successfully'
                          : 'Failed to update name'),
                      backgroundColor:
                          success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              } else {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Safely extract year from Firestore Timestamp (dynamic type)
  String _yearFromTimestamp(dynamic timestamp) {
    if (timestamp == null) return '${DateTime.now().year}';
    try {
      final date = timestamp.toDate() as DateTime;
      return '${date.year}';
    } catch (_) {
      return '${DateTime.now().year}';
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Logout via authProvider → guard redirect handles navigation
              await ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
