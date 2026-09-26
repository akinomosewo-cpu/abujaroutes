import 'package:flutter_test/flutter_test.dart';
import 'package:abujaroutes/domain/models/transit_route.dart';
import 'package:abujaroutes/domain/route_filter.dart';

const _routes = [
  TransitRoute(
    id: '1',
    origin: 'Berger Roundabout',
    destination: 'Nyanya',
    mode: TransitMode.korope,
    fareMin: 200,
    fareMax: 300,
    stops: ['Area 1', 'Utako Bridge'],
    status: RouteStatus.verified,
  ),
  TransitRoute(
    id: '2',
    origin: 'Wuse Market',
    destination: 'Kubwa',
    mode: TransitMode.bus,
    fareMin: 250,
    fareMax: 250,
    stops: ['Jabi Motor Park'],
    status: RouteStatus.verified,
  ),
  TransitRoute(
    id: '3',
    origin: 'Garki Area 3',
    destination: 'Wuse 2',
    mode: TransitMode.keke,
    fareMin: 300,
    fareMax: 500,
    status: RouteStatus.pending,
  ),
];

void main() {
  group('filterRoutes', () {
    test('returns all routes when query and mode are empty', () {
      final result = filterRoutes(_routes);
      expect(result.length, 3);
    });

    test('matches query against origin', () {
      final result = filterRoutes(_routes, query: 'berger');
      expect(result.map((r) => r.id), ['1']);
    });

    test('matches query against destination case-insensitively', () {
      final result = filterRoutes(_routes, query: 'KUBWA');
      expect(result.map((r) => r.id), ['2']);
    });

    test('matches query against stops', () {
      final result = filterRoutes(_routes, query: 'jabi motor park');
      expect(result.map((r) => r.id), ['2']);
    });

    test('filters by mode', () {
      final result = filterRoutes(_routes, mode: TransitMode.keke);
      expect(result.map((r) => r.id), ['3']);
    });

    test('combines query and mode filters', () {
      final result = filterRoutes(_routes, query: 'wuse', mode: TransitMode.bus);
      expect(result.map((r) => r.id), ['2']);
    });

    test('excludes routes above maxFare', () {
      final result = filterRoutes(_routes, maxFare: 250);
      expect(result.map((r) => r.id), ['1', '2']);
    });

    test('returns empty list when nothing matches', () {
      final result = filterRoutes(_routes, query: 'lagos');
      expect(result, isEmpty);
    });

    test('trims and ignores whitespace-only query', () {
      final result = filterRoutes(_routes, query: '   ');
      expect(result.length, 3);
    });
  });

  group('findRoutesBetween', () {
    test('matches origin -> destination directly', () {
      final result = findRoutesBetween(_routes, 'Berger', 'Nyanya');
      expect(result.map((r) => r.id), ['1']);
    });

    test('matches reversed direction since informal routes run both ways', () {
      final result = findRoutesBetween(_routes, 'Nyanya', 'Berger');
      expect(result.map((r) => r.id), ['1']);
    });

    test('returns all routes when both inputs are empty', () {
      final result = findRoutesBetween(_routes, '', '');
      expect(result.length, 3);
    });

    test('returns empty when destination has no match', () {
      final result = findRoutesBetween(_routes, 'Berger', 'Lagos');
      expect(result, isEmpty);
    });
  });
}
