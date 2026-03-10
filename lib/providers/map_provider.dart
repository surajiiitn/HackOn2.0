import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_info.dart';

class MapState {
  final String origin;
  final String destination;
  final RouteInfo? activeRoute;
  final bool isSearching;
  final bool isNavigating;
  final bool isOfflineMapAvailable;
  final String? error;

  const MapState({
    this.origin = '',
    this.destination = '',
    this.activeRoute,
    this.isSearching = false,
    this.isNavigating = false,
    this.isOfflineMapAvailable = true,
    this.error,
  });

  MapState copyWith({
    String? origin,
    String? destination,
    RouteInfo? activeRoute,
    bool? isSearching,
    bool? isNavigating,
    bool? isOfflineMapAvailable,
    String? error,
  }) {
    return MapState(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      activeRoute: activeRoute ?? this.activeRoute,
      isSearching: isSearching ?? this.isSearching,
      isNavigating: isNavigating ?? this.isNavigating,
      isOfflineMapAvailable:
          isOfflineMapAvailable ?? this.isOfflineMapAvailable,
      error: error,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier()
      : super(MapState(
          origin: '123 Harmony St.',
          destination: 'Central Park West',
          activeRoute: const RouteInfo(
            id: 'demo-route',
            origin: '123 Harmony St.',
            destination: 'Central Park West',
            dangerScore: 12,
            safetyLevel: RouteSafetyLevel.safe,
            estimatedTime: '12 min walk',
            via: '5th Avenue',
            lightingCoverage: 0.95,
            recentIncidents: 2,
          ),
        ));

  void setOrigin(String origin) {
    state = state.copyWith(origin: origin);
  }

  void setDestination(String destination) {
    state = state.copyWith(destination: destination);
  }

  Future<void> searchRoute() async {
    state = state.copyWith(isSearching: true, error: null);
    // TODO: Connect to Django API + PostGIS
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isSearching: false);
  }

  void startNavigation() {
    state = state.copyWith(isNavigating: true);
  }

  void stopNavigation() {
    state = state.copyWith(isNavigating: false);
  }

  void dropHazardPin() {
    // TODO: Connect to Django API — submit hazard report with PostGIS coordinates
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
