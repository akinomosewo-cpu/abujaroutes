import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_theme.dart';
import 'home_page.dart';
import 'login_page.dart';

/// A short, non-blocking branded splash shown once on launch (~1.2s)
/// before landing on the main app. Purely cosmetic: it never gates
/// access to browsing or searching routes.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Driven by a ticker (not a bare Future.delayed) so tests using
    // pumpAndSettle correctly wait for the splash to finish before moving on.
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          _navigateOnward();
        }
      })
      ..forward();
  }

  Future<void> _navigateOnward() async {
    await AuthRepository.instance.init();
    if (!mounted) return;
    final loggedIn = AuthRepository.instance.isLoggedIn;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: loggedIn ? const HomePage() : const LoginPage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 12))],
              ),
              child: const Icon(Icons.route_rounded, color: Colors.white, size: 44),
            )
                .animate()
                .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 20),
            Text(
              'Abuja Routes',
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary),
            ).animate(delay: 200.ms).fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Crowdsourced by riders, for riders',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ).animate(delay: 350.ms).fadeIn(duration: 350.ms),
          ],
        ),
      ),
    );
  }
}
