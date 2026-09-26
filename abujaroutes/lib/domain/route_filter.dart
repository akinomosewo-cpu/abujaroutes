import 'models/transit_route.dart';

/// Pure, testable search/filter logic for the route list.
///
/// [query] matches against origin, destination and stops (case-insensitive,
/// substring match). [mode] restricts to a single [TransitMode] when
/// provided. [maxFare] excludes routes whose minimum fare exceeds it.
List<TransitRoute> filterRoutes(
  List<TransitRoute> routes, {
  String query = '',
  TransitMode? mode,
  double? maxFare,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  return routes.where((route) {
    if (mode != null && route.mode != mode) return false;
    if (maxFare != null && route.fareMin > maxFare) return false;
    if (normalizedQuery.isEmpty) return true;

    final haystack = <String>[
      route.origin,
      route.destination,
      ...route.stops,
    ].map((s) => s.toLowerCase());

    return haystack.any((field) => field.contains(normalizedQuery));
  }).toList();
}

/// Convenience search used by an "A to B" journey finder: matches routes
/// whose origin contains [from] and destination contains [to] (in either
/// direction, since informal routes usually run both ways).
List<TransitRoute> findRoutesBetween(
  List<TransitRoute> routes,
  String from,
  String to,
) {
  final f = from.trim().toLowerCase();
  final t = to.trim().toLowerCase();
  if (f.isEmpty && t.isEmpty) return routes;

  bool matchesDirection(TransitRoute r) {
    final origin = r.origin.toLowerCase();
    final dest = r.destination.toLowerCase();
    final fMatch = f.isEmpty || origin.contains(f) || dest.contains(f);
    final tMatch = t.isEmpty || origin.contains(t) || dest.contains(t);
    return fMatch && tMatch;
  }

  return routes.where(matchesDirection).toList();
}
