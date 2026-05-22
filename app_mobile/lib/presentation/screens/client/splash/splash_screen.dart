import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final authProvider = context.read<AuthProvider>();

    await authProvider.initializeAuth();
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      if (authProvider.isAdmin) {
        Navigator.pushReplacementNamed(context, RouteNames.dashboard);
      } else {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                AppStrings.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
