import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/transit_route.dart';
import 'route_list_page.dart' show modeColor;

class RouteDetailPage extends StatelessWidget {
  final TransitRoute route;
  const RouteDetailPage({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final color = modeColor(route.mode);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(route.mode.label)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(route.routeLabel, style: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary)),
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(label: route.mode.label, color: color),
                _Pill(label: 'Fare: ${route.fareLabel}', color: AppColors.success),
                if (route.status == RouteStatus.pending) const _Pill(label: 'Unverified submission', color: AppColors.warning),
                if (route.status == RouteStatus.verified) const _Pill(label: 'Verified by riders', color: AppColors.success),
              ],
            ),
            const Gap(24),
            if (route.stops.isNotEmpty) ...[
              Text('Stops along the way', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
              const Gap(12),
              _StopsTimeline(stops: route.stops, color: color),
              const Gap(24),
            ],
            if (route.notes != null && route.notes!.isNotEmpty) ...[
              Text('Rider notes', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
              const Gap(8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
                child: Text(route.notes!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
      );
}

class _StopsTimeline extends StatelessWidget {
  final List<String> stops;
  final Color color;
  const _StopsTimeline({required this.stops, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < stops.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  if (i != stops.length - 1) Container(width: 2, height: 32, color: AppColors.border),
                ],
              ),
              const Gap(12),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(stops[i], style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
              ),
            ],
          ),
      ],
    );
  }
}
