import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

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
      submittedAt: DateTime.now(),
    );

    context.read<RouteBloc>().add(RouteSubmitted(route));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks! Your route was added and marked unverified.')),
    );

    _formKey.currentState!.reset();
    _originCtrl.clear();
    _destinationCtrl.clear();
    _stopsCtrl.clear();
    _fareMinCtrl.clear();
    _fareMaxCtrl.clear();
    _notesCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Add a route you know', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
            const Gap(4),
            Text(
              'Help other riders by sharing a korope, keke or bus route and its fare. Submissions are marked "Unverified" until confirmed by other riders.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
                  selectedColor: AppColors.primary.withValues(alpha: 0.25),
                  backgroundColor: AppColors.surface,
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700));
}
