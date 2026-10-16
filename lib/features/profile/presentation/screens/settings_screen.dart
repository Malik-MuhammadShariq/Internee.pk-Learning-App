import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/webview_service.dart';

/// Settings screen with toggle options
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _downloadWifiOnly = true;
  bool _autoPlayVideos = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Account section
          _buildSectionTitle('Account'),
          _buildSettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.md),

          // Notifications section
          _buildSectionTitle('Notifications'),
          _buildToggleTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive course updates and reminders',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),

          const SizedBox(height: AppSpacing.md),

          // Appearance section
          _buildSectionTitle('Appearance'),
          _buildToggleTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),

          const SizedBox(height: AppSpacing.md),

          // Download section
          _buildSectionTitle('Downloads'),
          _buildToggleTile(
            icon: Icons.wifi_outlined,
            title: 'WiFi Only Downloads',
            subtitle: 'Only download content on WiFi',
            value: _downloadWifiOnly,
            onChanged: (v) => setState(() => _downloadWifiOnly = v),
          ),
          _buildToggleTile(
            icon: Icons.play_circle_outline_rounded,
            title: 'Auto-play Videos',
            subtitle: 'Automatically play next video',
            value: _autoPlayVideos,
            onChanged: (v) => setState(() => _autoPlayVideos = v),
          ),

          const SizedBox(height: AppSpacing.md),

          // Language
          _buildSectionTitle('Language'),
          _buildSettingsTile(
            icon: Icons.language_rounded,
            title: 'App Language',
            subtitle: 'English',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.md),

          // Support section
          _buildSectionTitle('Support'),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            subtitle: 'FAQs and support articles',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.mail_outline_rounded,
            title: 'Contact Us',
            subtitle: 'Get in touch with our team',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.star_outline_rounded,
            title: 'Rate App',
            subtitle: 'Rate us on the Play Store',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.md),

          // Internee.pk Session
          _buildSectionTitle('Internee.pk'),
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: AppStrings.clearInterneeSession,
            subtitle: AppStrings.clearSessionDesc,
            onTap: () => _clearInterneeSession(context),
          ),

          const SizedBox(height: AppSpacing.md),

          // About
          _buildSectionTitle('About'),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: '1.0.0 (Build 1)',
            trailing: null,
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.policy_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Future<void> _clearInterneeSession(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Clear Session'),
        content: const Text(
          'This will log you out of Internee.pk WebView. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final webViewService = ref.read(webViewServiceProvider);
      await webViewService.clearInterneeSession();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Internee.pk session cleared'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.greyLight,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: subtitle != null
            ? Text(subtitle, style: AppTextStyles.bodySmall)
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.greyLight,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: subtitle != null
            ? Text(subtitle, style: AppTextStyles.bodySmall)
            : null,
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }
}
