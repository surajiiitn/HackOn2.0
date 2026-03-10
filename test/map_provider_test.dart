import 'package:flutter_test/flutter_test.dart';

import 'package:suraksha_ai/providers/map_provider.dart';

void main() {
  group('MapNotifier route resolution', () {
    test('builds a route for every location pair in dataset', () async {
      final notifier = MapNotifier();
      final locations = notifier.state.availableLocations;

      for (final origin in locations) {
        for (final destination in locations) {
          notifier.setOrigin(origin.name);
          notifier.setDestination(destination.name);
          await notifier.searchRoute();

          expect(
            notifier.state.error,
            isNull,
            reason: 'Expected route for ${origin.name} -> ${destination.name}',
          );
          expect(
            notifier.state.activeRoute,
            isNotNull,
            reason: 'Missing RouteInfo for ${origin.name} -> ${destination.name}',
          );
          expect(
            notifier.state.routePoints.length,
            greaterThanOrEqualTo(2),
            reason:
                'Expected drawable polyline for ${origin.name} -> ${destination.name}',
          );
        }
      }
    });
  });
}
