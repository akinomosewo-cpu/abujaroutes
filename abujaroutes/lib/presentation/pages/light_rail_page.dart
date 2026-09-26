import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../data/light_rail_schedule.dart';

class LightRailPage extends StatelessWidget {
  const LightRailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Abuja Light Rail', style: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary)),
          const Gap(6),
          Text(
            'Reference schedule for the operating light-rail segments. Times are approximate — confirm at the station.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const Gap(24),
          for (final line in lightRailLines) ...[
            _LineCard(line: line),
            const Gap(16),
          ],
        ],
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  final LightRailLine line;
  const _LineCard({required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: AppColors.cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.lightRail.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.train_rounded, color: AppColors.lightRail, size: 20),
              ),
              const Gap(12),
              Expanded(
                child: Text(line.name, style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
              ),
            ],
          ),
          const Gap(12),
          Text('Stations', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          const Gap(6),
          Text(
            line.stations.map((s) => s.name).join('  →  '),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
          ),
          const Gap(14),
          Text('Fare', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          const Gap(6),
          Text('₦${line.fare.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
          const Gap(14),
          Text('Weekday departures', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          const Gap(6),
          Wrap(spacing: 8, runSpacing: 8, children: line.weekdayDepartures.map((t) => _TimeChip(t)).toList()),
          const Gap(14),
          Text('Weekend departures', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          const Gap(6),
          Wrap(spacing: 8, runSpacing: 8, children: line.weekendDepartures.map((t) => _TimeChip(t)).toList()),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  const _TimeChip(this.time);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: AppColors.lightRail.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(time, style: AppTextStyles.labelSmall.copyWith(color: AppColors.lightRail, fontWeight: FontWeight.w700)),
      );
}
