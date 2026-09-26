import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/display_name_service.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/transit_route.dart';
import '../blocs/route_bloc.dart';

class SubmitRoutePage extends StatefulWidget {
  const SubmitRoutePage({super.key});

  @override
  State<SubmitRoutePage> createState() => _SubmitRoutePageState();
}

class _SubmitRoutePageState extends State<SubmitRoutePage> {
  final _formKey = GlobalKey<FormState>();
  final _originCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _stopsCtrl = TextEditingController();
  final _fareMinCtrl = TextEditingController();
  final _fareMaxCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  TransitMode _mode = TransitMode.korope;

  @override
  void dispose() {
    _originCtrl.dispose();
    _destinationCtrl.dispose();
    _stopsCtrl.dispose();
    _fareMinCtrl.dispose();
    _fareMaxCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Optional, one-time, skippable display-name capture so a submission
    // can carry local attribution. This never blocks submitting or
    // browsing routes: dismissing it just submits anonymously.
    await DisplayNameService.init();
    if (!DisplayNameService.hasDisplayName && mounted) {
      await _promptForDisplayName();
    }

    final fareMin = double.tryParse(_fareMinCtrl.text.trim()) ?? 0;
    final fareMax = double.tryParse(_fareMaxCtrl.text.trim());
    final stops = _stopsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final route = TransitRoute(
      id: const Uuid().v4(),
      origin: _originCtrl.text.trim(),
      destination: _destinationCtrl.text.trim(),
      mode: _mode,
      fareMin: fareMin,
      fareMax: (fareMax == null || fareMax < fareMin) ? fareMin : fareMax,
      stops: stops,
      status: RouteStatus.pending,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      submittedBy: DisplayNameService.getDisplayName(),
      submittedAt: DateTime.now(),
    );

    if (!mounted) return;
    context.read<RouteBloc>().add(RouteSubmitted(route));

    _formKey.currentState!.reset();
    _originCtrl.clear();
    _destinationCtrl.clear();
    _stopsCtrl.clear();
    _fareMinCtrl.clear();
    _fareMaxCtrl.clear();
    _notesCtrl.clear();

    if (!mounted) return;
    await _showSubmissionSuccess();
  }

  Future<void> _promptForDisplayName() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add your name? (optional)', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riders can see who contributed a route. No account or password needed — you can skip this and submit anonymously.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const Gap(16),
            TextField(
              key: const Key('displayNameField'),
              controller: ctrl,
              autofocus: true,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Chidi O.'),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('displayNameSkip'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            key: const Key('displayNameSave'),
            onPressed: () => Navigator.of(dialogContext).pop(ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await DisplayNameService.setDisplayName(name);
    }
  }

  Future<void> _showSubmissionSuccess() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks! Your route was added and marked unverified.')),
    );
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (dialogContext) => const _SubmissionSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Add a route you know', style: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary)),
            const Gap(6),
            Text(
              'Help other riders by sharing a korope, keke or bus route and its fare. Submissions are marked "Unverified" until confirmed by other riders.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const Gap(24),
            const _Label('Mode of transport'),
            const Gap(8),
            Wrap(
              spacing: 8,
              children: TransitMode.values.map((mode) {
                final selected = _mode == mode;
                return ChoiceChip(
                  label: Text(mode.shortLabel),
                  selected: selected,
                  onSelected: (_) => setState(() => _mode = mode),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(color: selected ? Colors.transparent : AppColors.border),
                );
              }).toList(),
            ),
            const Gap(20),
            const _Label('Origin'),
            const Gap(8),
            TextFormField(
              key: const Key('originField'),
              controller: _originCtrl,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Berger Roundabout'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter an origin' : null,
            ),
            const Gap(16),
            const _Label('Destination'),
            const Gap(8),
            TextFormField(
              key: const Key('destinationField'),
              controller: _destinationCtrl,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Nyanya'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a destination' : null,
            ),
            const Gap(16),
            const _Label('Stops (comma separated, optional)'),
            const Gap(8),
            TextFormField(
              controller: _stopsCtrl,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Area 1, Utako Bridge'),
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Min fare (₦)'),
                      const Gap(8),
                      TextFormField(
                        key: const Key('fareMinField'),
                        controller: _fareMinCtrl,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: '200'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v.trim()) == null) return 'Numbers only';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Max fare (₦, optional)'),
                      const Gap(8),
                      TextFormField(
                        controller: _fareMaxCtrl,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: '300'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          if (double.tryParse(v.trim()) == null) return 'Numbers only';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            const _Label('Notes (optional)'),
            const Gap(8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Fare rises during rush hour'),
            ),
            const Gap(28),
            ElevatedButton(
              key: const Key('submitRouteButton'),
              onPressed: _submit,
              child: const Text('Submit route'),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }
}

/// A short, non-blocking checkmark scale-in shown after a route
/// submission succeeds. Auto-dismisses so it never traps the user.
class _SubmissionSuccessDialog extends StatefulWidget {
  const _SubmissionSuccessDialog();

  @override
  State<_SubmissionSuccessDialog> createState() => _SubmissionSuccessDialogState();
}

class _SubmissionSuccessDialogState extends State<_SubmissionSuccessDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _autoDismiss;

  @override
  void initState() {
    super.initState();
    // Driven by a ticker (not a bare Future.delayed) so tests using
    // pumpAndSettle correctly wait for the auto-dismiss to finish.
    _autoDismiss = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.of(context).maybePop();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _autoDismiss.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            )
                .animate()
                .scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1), duration: 300.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 150.ms),
            const Gap(16),
            Text(
              'Route submitted!',
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
            ).animate(delay: 150.ms).fadeIn(duration: 200.ms),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700));
}
