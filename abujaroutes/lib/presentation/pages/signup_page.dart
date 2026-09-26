import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_theme.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  bool _success = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
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
      await AuthRepository.instance.signUp(
        name: _nameCtrl.text,
        contact: _contactCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      setState(() => _success = true);
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        FadeSlidePageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted && !_success) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                    ),
                    const Gap(8),
                    Text('Create your account', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary))
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.15, end: 0),
                    const Gap(6),
                    Text(
                      'Join riders mapping Abuja\'s routes.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ).animate(delay: 60.ms).fadeIn(duration: 300.ms),
                    const Gap(32),
                    TextFormField(
                      key: const Key('signupNameField'),
                      controller: _nameCtrl,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(hintText: 'Full name'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                    const Gap(14),
                    TextFormField(
                      key: const Key('signupContactField'),
                      controller: _contactCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(hintText: 'Email or phone number'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ).animate(delay: 140.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                    const Gap(14),
                    TextFormField(
                      key: const Key('signupPasswordField'),
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Password (min. 6 characters)',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                    ).animate(delay: 180.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                    if (_error != null) ...[
                      const Gap(12),
                      Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger)),
                    ],
                    const Gap(28),
                    ElevatedButton(
                      key: const Key('signupSubmitButton'),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                            )
                          : const Text('Sign up'),
                    ).animate(delay: 220.ms).fadeIn(duration: 300.ms),
                  ],
                ),
              ),
            ),
            if (_success)
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.background.withValues(alpha: 0.92),
                  child: Center(
                    child: Container(
                      key: const Key('signupSuccessCheck'),
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                    ).animate().scale(
                          begin: const Offset(0.4, 0.4),
                          end: const Offset(1, 1),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
