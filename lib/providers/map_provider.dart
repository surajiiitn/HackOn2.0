import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_info.dart';
import '../core/services/api_service.dart';

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
    try {
      // Demo coordinates (Mumbai area)
      final data = await ApiService.getSafePath(
        startLat: 19.0760,
        startLng: 72.8777,
        endLat: 19.0896,
        endLng: 72.8656,
      );

      final dangerScore = (data['danger_score'] as num?)?.toInt() ?? 0;
      final safetyLevel = dangerScore < 30
          ? RouteSafetyLevel.safe
          : dangerScore < 60
              ? RouteSafetyLevel.caution
              : RouteSafetyLevel.danger;

      state = state.copyWith(
        isSearching: false,
        activeRoute: RouteInfo(
          id: data['id']?.toString() ?? 'route-1',
          origin: state.origin,
          destination: state.destination,
          dangerScore: dangerScore,
          safetyLevel: safetyLevel,
          estimatedTime: '${(dangerScore * 0.2 + 8).toInt()} min walk',
          via: 'Analyzed route',
          lightingCoverage: 1.0 - (dangerScore / 100.0),
          recentIncidents: (data['hazard_count'] as num?)?.toInt() ?? 0,
        ),
      );
    } on ApiException catch (e) {
      state = state.copyWith(isSearching: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isSearching: false, error: 'Network error');
    }
  }

  void startNavigation() {
    state = state.copyWith(isNavigating: true);
  }

  void stopNavigation() {
    state = state.copyWith(isNavigating: false);
  }

  Future<void> dropHazardPin({
    double latitude = 19.0760,
    double longitude = 72.8777,
    String hazardType = 'suspicious_activity',
    String description = '',
  }) async {
    try {
      await ApiService.dropHazardPin(
        latitude: latitude,
        longitude: longitude,
        hazardType: hazardType,
        description: description,
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: 'Failed to report hazard');
    }
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
