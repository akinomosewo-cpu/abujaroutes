import 'package:flutter_test/flutter_test.dart';
import 'package:abujaroutes/domain/models/transit_route.dart';

void main() {
  group('TransitRoute.fareLabel', () {
    test('shows a single amount when fare is fixed', () {
      const route = TransitRoute(
        id: '1',
        origin: 'A',
        destination: 'B',
        mode: TransitMode.bus,
        fareMin: 250,
        fareMax: 250,
      );
      expect(route.fareLabel, '₦250');
    });

    test('shows a range when fares differ', () {
      const route = TransitRoute(
        id: '2',
        origin: 'A',
        destination: 'B',
        mode: TransitMode.korope,
        fareMin: 200,
        fareMax: 300,
      );
      expect(route.fareLabel, '₦200 - ₦300');
    });
  });

  group('TransitRoute json round-trip', () {
    test('toJson/fromJson preserves fields', () {
      final route = TransitRoute(
        id: '3',
        origin: 'Gwarinpa',
        destination: 'Jabi',
        mode: TransitMode.keke,
        fareMin: 200,
        fareMax: 300,
        stops: const ['Life Camp'],
        status: RouteStatus.pending,
        notes: 'Test note',
        submittedAt: DateTime.utc(2026, 1, 1),
      );

      final restored = TransitRoute.fromJson(route.toJson());

      expect(restored.id, route.id);
      expect(restored.origin, route.origin);
      expect(restored.destination, route.destination);
      expect(restored.mode, route.mode);
      expect(restored.fareMin, route.fareMin);
      expect(restored.fareMax, route.fareMax);
      expect(restored.stops, route.stops);
      expect(restored.status, route.status);
      expect(restored.notes, route.notes);
      expect(restored.submittedAt, route.submittedAt);
    });
  });
}
