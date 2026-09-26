import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_theme.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthRepository.instance.logIn(
        contact: _contactCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        FadeSlidePageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: const Icon(Icons.route_rounded, color: Colors.white, size: 32),
                ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),
                const Gap(24),
                Text('Welcome back', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary))
                    .animate(delay: 60.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.15, end: 0),
                const Gap(6),
                Text(
                  'Log in to track and submit routes.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ).animate(delay: 120.ms).fadeIn(duration: 300.ms),
                const Gap(32),
                TextFormField(
                  key: const Key('loginContactField'),
                  controller: _contactCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Email or phone number'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ).animate(delay: 160.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                const Gap(14),
                TextFormField(
                  key: const Key('loginPasswordField'),
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                if (_error != null) ...[
                  const Gap(12),
                  Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger)),
                ],
                const Gap(28),
                ElevatedButton(
                  key: const Key('loginSubmitButton'),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Text('Log in'),
                ).animate(delay: 240.ms).fadeIn(duration: 300.ms),
                const Gap(20),
                Center(
                  child: TextButton(
                    key: const Key('goToSignupButton'),
                    onPressed: () => Navigator.of(context).push(
                      FadeSlidePageRoute(builder: (_) => const SignupPage()),
                    ),
                    child: Text(
                      "Don't have an account? Sign up",
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                    ),
                  ),
                ).animate(delay: 280.ms).fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
