import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../app/router/routes.dart';
import '../providers/auth_provider.dart';

/// Signup screen with password strength indicator
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  double _passwordStrength = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordStrength = Validators.getPasswordStrength(value);
    });
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      final success = await ref.read(authProvider.notifier).signup(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (success && mounted) {
        context.go(Routes.home);
      }
    }
  }

  Color get _strengthColor {
    if (_passwordStrength < 0.3) return AppColors.error;
    if (_passwordStrength < 0.6) return AppColors.warning;
    if (_passwordStrength < 0.8) return AppColors.info;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // Back button
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ).animate().fadeIn().slideX(begin: -0.2, end: 0),

                const SizedBox(height: AppSpacing.sm),

                // Title
                Text(
                  AppStrings.createAccount,
                  style: AppTextStyles.displayMedium,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  AppStrings.signupSubtitle,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppSpacing.lg),

                // Full Name
                _buildTextField(
                  controller: _nameController,
                  label: AppStrings.fullName,
                  icon: Icons.person_outline_rounded,
                  validator: Validators.validateName,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppSpacing.md),

                // Email
                _buildTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppSpacing.md),

                // Password
                _buildTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  onChanged: _onPasswordChanged,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                // Password strength indicator
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildPasswordStrength()
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),
                ],

                const SizedBox(height: AppSpacing.md),

                // Confirm Password
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: AppStrings.confirmPassword,
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirm,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppSpacing.sm),

                // Terms checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) =>
                            setState(() => _acceptTerms = v ?? false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.termsAgreement,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: AppSpacing.lg),

                // Signup button
                AnimatedButton(
                  text: AppStrings.signup,
                  onPressed: _signup,
                  isLoading: authState.isLoading,
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),

                // Error
                if (authState.error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    authState.error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ).animate().shake().fadeIn(),
                ],

                const SizedBox(height: AppSpacing.md),

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: AppTextStyles.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.go(Routes.login),
                        child: Text(
                          AppStrings.login,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildPasswordStrength() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _passwordStrength,
            backgroundColor: AppColors.greyLight,
            valueColor: AlwaysStoppedAnimation(_strengthColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        // Strength label
        Text(
          Validators.getPasswordStrengthLabel(_passwordStrength),
          style: AppTextStyles.caption.copyWith(color: _strengthColor),
        ),
      ],
    );
  }
}
