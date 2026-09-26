import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/transit_route.dart';
import '../blocs/route_bloc.dart';
import 'route_detail_page.dart';

Color modeColor(TransitMode mode) {
  switch (mode) {
    case TransitMode.korope:
      return AppColors.korope;
    case TransitMode.keke:
      return AppColors.keke;
    case TransitMode.bus:
      return AppColors.bus;
    case TransitMode.lightRail:
      return AppColors.lightRail;
  }
}

class RouteListPage extends StatelessWidget {
  const RouteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          final results = state.filteredRoutes;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Abuja Routes', style: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary)),
                    const Gap(6),
                    Text('Search korope, keke and bus routes crowdsourced by riders.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const Gap(20),
                    TextField(
                      key: const Key('routeSearchField'),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Search by origin, destination or stop',
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      ),
                      onChanged: (value) => context.read<RouteBloc>().add(RouteSearchChanged(value)),
                    ),
                    const Gap(12),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: state.modeFilter == null,
                            onTap: () => context.read<RouteBloc>().add(const RouteModeFilterChanged(null)),
                          ),
                          for (final mode in TransitMode.values)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _FilterChip(
                                label: mode.shortLabel,
                                color: modeColor(mode),
                                selected: state.modeFilter == mode,
                                onTap: () => context.read<RouteBloc>().add(RouteModeFilterChanged(mode)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? _EmptyResults(query: state.query)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const Gap(10),
                        itemBuilder: (context, index) {
                          final route = results[index];
                          return _RouteCard(route: route)
                              .animate(delay: Duration(milliseconds: 30 * index))
                              .fadeIn()
                              .slideY(begin: 0.05);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? accent : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: selected ? null : Border.all(color: AppColors.border),
          boxShadow: selected ? [BoxShadow(color: accent.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final String query;
  const _EmptyResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.route_rounded, color: AppColors.textTertiary, size: 40),
            const Gap(12),
            Text(
              query.isEmpty ? 'No routes match this filter' : 'No routes found for "$query"',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const Gap(4),
            Text(
              'Know this route? Submit it from the + tab.',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final TransitRoute route;
  const _RouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    final color = modeColor(route.mode);
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.of(context).push(
        FadeSlidePageRoute(builder: (_) => RouteDetailPage(route: route)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(16)),
              child: Icon(_iconFor(route.mode), color: color, size: 22),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route.routeLabel, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                  const Gap(6),
                  Row(
                    children: [
                      _ModePill(label: route.mode.label, color: color),
                      const Gap(8),
                      Text(route.fareLabel, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            if (route.status == RouteStatus.pending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
                child: Text('Unverified', style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700)),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(TransitMode mode) {
    switch (mode) {
      case TransitMode.korope:
        return Icons.airport_shuttle_rounded;
      case TransitMode.keke:
        return Icons.local_taxi_rounded;
      case TransitMode.bus:
        return Icons.directions_bus_rounded;
      case TransitMode.lightRail:
        return Icons.train_rounded;
    }
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final Color color;
  const _ModePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
      );
}
