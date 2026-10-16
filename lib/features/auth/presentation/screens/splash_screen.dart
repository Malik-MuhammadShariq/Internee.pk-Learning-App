import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/constants/storage_keys.dart';
import '../providers/firebase_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Splash screen — animated logo while checking auth state
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    // Check auth state after animation starts
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Ensure minimum 2 seconds so the logo animation completes
    final minDisplayFuture = Future.delayed(const Duration(seconds: 2));

    // Wait for first auth state event (with timeout)
    final authFuture = ref
        .read(authStateProvider.future)
        .timeout(const Duration(seconds: 4));

    // Run both concurrently — auth check + minimum display timer
    try {
      final results = await Future.wait([
        authFuture,
        minDisplayFuture,
      ]);
      final user = results[0] as User?;
      if (!mounted) return;

      if (user != null) {
        // Logged in → go to home
        context.go(Routes.home);
      } else {
        // Not logged in → check if first time
        final prefs = await SharedPreferences.getInstance();
        final isFirstTime = prefs.getBool(StorageKeys.isFirstTime) ?? true;
        if (!mounted) return;

        if (isFirstTime) {
          // Mark as not first time for next launch
          await prefs.setBool(StorageKeys.isFirstTime, false);
          context.go(Routes.onboarding);
        } else {
          context.go(Routes.login);
        }
      }
    } catch (_) {
      // Timeout or error → default to login
      if (mounted) context.go(Routes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animation: scale from 0.5 to 1.0 with bounce
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '📚',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              )
                  .animate(controller: _controller)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 1500.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 800.ms),

              const SizedBox(height: 24),

              // App name with fade-in + slide up
              Text(
                'Internee.pk',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate(controller: _controller)
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 800.ms),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Learn. Grow. Achieve.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                  letterSpacing: 2,
                ),
              )
                  .animate(controller: _controller)
                  .fadeIn(delay: 800.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, delay: 800.ms, duration: 800.ms),

              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ).animate(controller: _controller).fadeIn(delay: 1200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
