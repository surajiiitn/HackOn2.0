import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/api_service.dart';
import '../models/route_info.dart';

class SafeRouteLocation {
  final String name;
  final double lat;
  final double lng;
  final String safety;

  const SafeRouteLocation({
    required this.name,
    required this.lat,
    required this.lng,
    required this.safety,
  });
}

class SafeRoutePoint {
  final double lat;
  final double lng;

  const SafeRoutePoint({required this.lat, required this.lng});
}

class SafeRouteHazard {
  final int id;
  final double lat;
  final double lng;
  final String severity;
  final String description;

  const SafeRouteHazard({
    required this.id,
    required this.lat,
    required this.lng,
    required this.severity,
    required this.description,
  });
}

class SafeRouteDataRoute {
  final int id;
  final String start;
  final String end;
  final double distanceKm;
  final String riskLevel;
  final List<SafeRoutePoint> route;

  const SafeRouteDataRoute({
    required this.id,
    required this.start,
    required this.end,
    required this.distanceKm,
    required this.riskLevel,
    required this.route,
  });
}

const List<SafeRouteLocation> _locations = [
  SafeRouteLocation(
      name: 'GCOEN Khapri', lat: 21.0908, lng: 79.0472, safety: 'HIGH'),
  SafeRouteLocation(
      name: 'Khapri Station', lat: 21.0921, lng: 79.0551, safety: 'MEDIUM'),
  SafeRouteLocation(
      name: 'AIIMS Nagpur', lat: 21.0942, lng: 79.0605, safety: 'HIGH'),
  SafeRouteLocation(
      name: 'MIHAN SEZ', lat: 21.0935, lng: 79.0623, safety: 'HIGH'),
  SafeRouteLocation(
      name: 'Nagpur Airport', lat: 21.0920, lng: 79.0472, safety: 'HIGH'),
  SafeRouteLocation(
      name: 'Wardha Road', lat: 21.1001, lng: 79.0450, safety: 'MEDIUM'),
  SafeRouteLocation(
      name: 'Somalwada', lat: 21.0960, lng: 79.0530, safety: 'MEDIUM'),
  SafeRouteLocation(
      name: 'Narendra Nagar', lat: 21.1065, lng: 79.0590, safety: 'HIGH'),
  SafeRouteLocation(
      name: 'Pratap Nagar', lat: 21.1080, lng: 79.0670, safety: 'HIGH'),
  SafeRouteLocation(
      name: 'Trimurti Nagar', lat: 21.1160, lng: 79.0610, safety: 'HIGH'),
  SafeRouteLocation(
      name: 'Jaiprakash Nagar', lat: 21.1010, lng: 79.0670, safety: 'HIGH'),
  SafeRouteLocation(
      name: 'Futala Lake', lat: 21.1370, lng: 79.0720, safety: 'HIGH'),
  SafeRouteLocation(
      name: 'Sitabuldi', lat: 21.1450, lng: 79.0850, safety: 'MEDIUM'),
];

const List<SafeRouteDataRoute> _routes = [
  SafeRouteDataRoute(
    id: 1,
    start: 'GCOEN Khapri',
    end: 'AIIMS Nagpur',
    distanceKm: 2.4,
    riskLevel: 'LOW',
    route: [
      SafeRoutePoint(lat: 21.0908, lng: 79.0472),
      SafeRoutePoint(lat: 21.0920, lng: 79.0520),
      SafeRoutePoint(lat: 21.0930, lng: 79.0560),
      SafeRoutePoint(lat: 21.0942, lng: 79.0605),
    ],
  ),
  SafeRouteDataRoute(
    id: 2,
    start: 'GCOEN Khapri',
    end: 'Khapri Station',
    distanceKm: 1.8,
    riskLevel: 'MEDIUM',
    route: [
      SafeRoutePoint(lat: 21.0908, lng: 79.0472),
      SafeRoutePoint(lat: 21.0912, lng: 79.0500),
      SafeRoutePoint(lat: 21.0917, lng: 79.0525),
      SafeRoutePoint(lat: 21.0921, lng: 79.0551),
    ],
  ),
  SafeRouteDataRoute(
    id: 3,
    start: 'AIIMS Nagpur',
    end: 'Somalwada',
    distanceKm: 2.8,
    riskLevel: 'MEDIUM',
    route: [
      SafeRoutePoint(lat: 21.0942, lng: 79.0605),
      SafeRoutePoint(lat: 21.0950, lng: 79.0580),
      SafeRoutePoint(lat: 21.0955, lng: 79.0555),
      SafeRoutePoint(lat: 21.0960, lng: 79.0530),
    ],
  ),
  SafeRouteDataRoute(
    id: 4,
    start: 'Somalwada',
    end: 'Narendra Nagar',
    distanceKm: 2.5,
    riskLevel: 'LOW',
    route: [
      SafeRoutePoint(lat: 21.0960, lng: 79.0530),
      SafeRoutePoint(lat: 21.0990, lng: 79.0555),
      SafeRoutePoint(lat: 21.1030, lng: 79.0575),
      SafeRoutePoint(lat: 21.1065, lng: 79.0590),
    ],
  ),
  SafeRouteDataRoute(
    id: 5,
    start: 'Narendra Nagar',
    end: 'Pratap Nagar',
    distanceKm: 1.5,
    riskLevel: 'LOW',
    route: [
      SafeRoutePoint(lat: 21.1065, lng: 79.0590),
      SafeRoutePoint(lat: 21.1070, lng: 79.0620),
      SafeRoutePoint(lat: 21.1075, lng: 79.0645),
      SafeRoutePoint(lat: 21.1080, lng: 79.0670),
    ],
  ),
  SafeRouteDataRoute(
    id: 6,
    start: 'Pratap Nagar',
    end: 'Trimurti Nagar',
    distanceKm: 1.6,
    riskLevel: 'LOW',
    route: [
      SafeRoutePoint(lat: 21.1080, lng: 79.0670),
      SafeRoutePoint(lat: 21.1105, lng: 79.0650),
      SafeRoutePoint(lat: 21.1130, lng: 79.0630),
      SafeRoutePoint(lat: 21.1160, lng: 79.0610),
    ],
  ),
  SafeRouteDataRoute(
    id: 7,
    start: 'Trimurti Nagar',
    end: 'Sitabuldi',
    distanceKm: 3.5,
    riskLevel: 'MEDIUM',
    route: [
      SafeRoutePoint(lat: 21.1160, lng: 79.0610),
      SafeRoutePoint(lat: 21.1230, lng: 79.0660),
      SafeRoutePoint(lat: 21.1340, lng: 79.0740),
      SafeRoutePoint(lat: 21.1450, lng: 79.0850),
    ],
  ),
];

const List<SafeRouteHazard> _hazards = [
  SafeRouteHazard(
    id: 1,
    lat: 21.0980,
    lng: 79.0550,
    severity: 'HIGH',
    description: 'Poor lighting and isolated area',
  ),
  SafeRouteHazard(
    id: 2,
    lat: 21.1030,
    lng: 79.0580,
    severity: 'MEDIUM',
    description: 'Reported theft incidents',
  ),
  SafeRouteHazard(
    id: 3,
    lat: 21.1120,
    lng: 79.0610,
    severity: 'HIGH',
    description: 'Unsafe industrial road',
  ),
  SafeRouteHazard(
    id: 4,
    lat: 21.1300,
    lng: 79.0720,
    severity: 'MEDIUM',
    description: 'Crowded traffic area',
  ),
];

class MapState {
  final String origin;
  final String destination;
  final RouteInfo? activeRoute;
  final List<SafeRouteLocation> availableLocations;
  final List<SafeRoutePoint> routePoints;
  final List<SafeRouteHazard> nearbyHazards;
  final String? activeRiskLevel;
  final double? activeDistanceKm;
  final bool isSearching;
  final bool isNavigating;
  final bool isOfflineMapAvailable;
  final String? error;

  const MapState({
    this.origin = '',
    this.destination = '',
    this.activeRoute,
    this.availableLocations = const [],
    this.routePoints = const [],
    this.nearbyHazards = const [],
    this.activeRiskLevel,
    this.activeDistanceKm,
    this.isSearching = false,
    this.isNavigating = false,
    this.isOfflineMapAvailable = true,
    this.error,
  });

  MapState copyWith({
    String? origin,
    String? destination,
    RouteInfo? activeRoute,
    bool clearActiveRoute = false,
    List<SafeRouteLocation>? availableLocations,
    List<SafeRoutePoint>? routePoints,
    List<SafeRouteHazard>? nearbyHazards,
    String? activeRiskLevel,
    double? activeDistanceKm,
    bool clearRouteMeta = false,
    bool? isSearching,
    bool? isNavigating,
    bool? isOfflineMapAvailable,
    String? error,
  }) {
    return MapState(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      activeRoute: clearActiveRoute ? null : (activeRoute ?? this.activeRoute),
      availableLocations: availableLocations ?? this.availableLocations,
      routePoints: routePoints ?? this.routePoints,
      nearbyHazards: nearbyHazards ?? this.nearbyHazards,
      activeRiskLevel:
          clearRouteMeta ? null : (activeRiskLevel ?? this.activeRiskLevel),
      activeDistanceKm:
          clearRouteMeta ? null : (activeDistanceKm ?? this.activeDistanceKm),
      isSearching: isSearching ?? this.isSearching,
      isNavigating: isNavigating ?? this.isNavigating,
      isOfflineMapAvailable:
          isOfflineMapAvailable ?? this.isOfflineMapAvailable,
      error: error,
    );
  }
}

class _GraphEdge {
  final String from;
  final String to;
  final double distanceKm;
  final String riskLevel;
  final List<SafeRoutePoint> points;

  const _GraphEdge({
    required this.from,
    required this.to,
    required this.distanceKm,
    required this.riskLevel,
    required this.points,
  });
}

class _NodeCost {
  final double riskScore;
  final double distanceKm;

  const _NodeCost({required this.riskScore, required this.distanceKm});
}

class _PathStep {
  final String previousNode;
  final _GraphEdge edge;

  const _PathStep({required this.previousNode, required this.edge});
}

class _ResolvedRoute {
  final List<_GraphEdge> edges;
  final List<SafeRoutePoint> points;
  final double distanceKm;
  final String riskLevel;

  const _ResolvedRoute({
    required this.edges,
    required this.points,
    required this.distanceKm,
    required this.riskLevel,
  });
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier()
      : super(
          const MapState(
            origin: 'GCOEN Khapri',
            destination: 'AIIMS Nagpur',
            availableLocations: _locations,
          ),
        ) {
    _applyDatasetRoute();
  }

  void setOrigin(String origin) {
    state = state.copyWith(origin: origin, error: null);
  }

  void setDestination(String destination) {
    state = state.copyWith(destination: destination, error: null);
  }

  Future<void> searchRoute() async {
    state = state.copyWith(isSearching: true, error: null);
    _applyDatasetRoute();
  }

  void _applyDatasetRoute() {
    final start = state.origin.trim();
    final end = state.destination.trim();

    if (start.isEmpty || end.isEmpty) {
      state = state.copyWith(
        isSearching: false,
        clearActiveRoute: true,
        routePoints: const [],
        nearbyHazards: const [],
        clearRouteMeta: true,
        error: 'Please select both start and destination.',
      );
      return;
    }

    final resolved = _resolveRoute(start, end);
    if (resolved == null) {
      state = state.copyWith(
        isSearching: false,
        clearActiveRoute: true,
        routePoints: const [],
        nearbyHazards: const [],
        clearRouteMeta: true,
        error: 'No route available for the selected locations.',
      );
      return;
    }

    final nearbyHazards = _hazardsNearRoute(resolved.points);
    final risk = resolved.riskLevel;
    final dangerScore = _riskToDangerScore(risk);
    final safetyLevel = dangerScore <= 30
        ? RouteSafetyLevel.safe
        : dangerScore <= 60
            ? RouteSafetyLevel.caution
            : RouteSafetyLevel.danger;

    final etaMinutes = math.max(1, ((resolved.distanceKm / 4.8) * 60).round());

    state = state.copyWith(
      isSearching: false,
      activeRoute: RouteInfo(
        id: '$start->$end',
        origin: start,
        destination: end,
        dangerScore: dangerScore,
        safetyLevel: safetyLevel,
        estimatedTime: '$etaMinutes min walk',
        via: 'Dataset path (${resolved.edges.length} segments)',
        lightingCoverage: (100 - dangerScore) / 100,
        recentIncidents: nearbyHazards.length,
        distanceKm: resolved.distanceKm,
        riskLevel: risk,
      ),
      routePoints: resolved.points,
      nearbyHazards: nearbyHazards,
      activeRiskLevel: risk,
      activeDistanceKm: resolved.distanceKm,
      error: null,
    );
  }

  _ResolvedRoute? _resolveRoute(String start, String end) {
    final locationsByName = {
      for (final location in _locations) location.name: location,
    };

    final startLocation = locationsByName[start];
    final endLocation = locationsByName[end];
    if (startLocation == null || endLocation == null) {
      return null;
    }

    if (start == end) {
      final samePoint =
          SafeRoutePoint(lat: startLocation.lat, lng: startLocation.lng);
      return _ResolvedRoute(
        edges: [],
        points: [samePoint, samePoint],
        distanceKm: 0,
        riskLevel: 'LOW',
      );
    }

    final edges = _buildGraphEdges();
    final routableNames = <String>{
      for (final edge in edges) edge.from,
      for (final edge in edges) edge.to,
    };

    var startAnchor = start;
    var endAnchor = end;

    _GraphEdge? startConnector;
    _GraphEdge? endConnector;

    if (!routableNames.contains(start)) {
      final nearest = _nearestRoutableLocation(
          startLocation, routableNames, locationsByName);
      if (nearest == null) return null;
      startAnchor = nearest.name;
      startConnector = _buildConnectorEdge(startLocation, nearest);
    }

    if (!routableNames.contains(end)) {
      final nearest =
          _nearestRoutableLocation(endLocation, routableNames, locationsByName);
      if (nearest == null) return null;
      endAnchor = nearest.name;
      endConnector = _buildConnectorEdge(nearest, endLocation);
    }

    final pathEdges = startAnchor == endAnchor
        ? <_GraphEdge>[]
        : _findSafestPath(startAnchor, endAnchor, edges);

    if (pathEdges == null) {
      return null;
    }

    final allEdges = <_GraphEdge>[
      if (startConnector != null) startConnector,
      ...pathEdges,
      if (endConnector != null) endConnector,
    ];

    final mergedPoints = _mergeEdgePoints(allEdges);
    if (mergedPoints.length < 2) {
      mergedPoints
          .add(SafeRoutePoint(lat: endLocation.lat, lng: endLocation.lng));
    }

    final distanceKm =
        allEdges.fold<double>(0, (sum, edge) => sum + edge.distanceKm);
    final riskLevel =
        _aggregateRiskLevel(allEdges.map((e) => e.riskLevel).toList());

    return _ResolvedRoute(
      edges: allEdges,
      points: mergedPoints,
      distanceKm: distanceKm,
      riskLevel: riskLevel,
    );
  }

  List<_GraphEdge> _buildGraphEdges() {
    final edges = <_GraphEdge>[];
    for (final route in _routes) {
      edges.add(
        _GraphEdge(
          from: route.start,
          to: route.end,
          distanceKm: route.distanceKm,
          riskLevel: route.riskLevel,
          points: List<SafeRoutePoint>.from(route.route),
        ),
      );
      edges.add(
        _GraphEdge(
          from: route.end,
          to: route.start,
          distanceKm: route.distanceKm,
          riskLevel: route.riskLevel,
          points: route.route.reversed.toList(),
        ),
      );
    }
    return edges;
  }

  List<_GraphEdge>? _findSafestPath(
    String start,
    String end,
    List<_GraphEdge> edges,
  ) {
    final byFrom = <String, List<_GraphEdge>>{};
    for (final edge in edges) {
      byFrom.putIfAbsent(edge.from, () => []).add(edge);
    }

    final bestCost = <String, _NodeCost>{
      start: const _NodeCost(riskScore: 0, distanceKm: 0),
    };
    final previous = <String, _PathStep>{};
    final pending = <String>{start};

    while (pending.isNotEmpty) {
      String current = pending.first;
      for (final candidate in pending) {
        final currentCost = bestCost[current]!;
        final candidateCost = bestCost[candidate]!;
        if (_isBetterCost(candidateCost, currentCost)) {
          current = candidate;
        }
      }

      pending.remove(current);
      if (current == end) break;

      final currentCost = bestCost[current]!;
      for (final edge in byFrom[current] ?? const <_GraphEdge>[]) {
        final nextCost = _NodeCost(
          riskScore: currentCost.riskScore + _riskPenalty(edge.riskLevel),
          distanceKm: currentCost.distanceKm + edge.distanceKm,
        );

        final existing = bestCost[edge.to];
        if (existing == null || _isBetterCost(nextCost, existing)) {
          bestCost[edge.to] = nextCost;
          previous[edge.to] = _PathStep(previousNode: current, edge: edge);
          pending.add(edge.to);
        }
      }
    }

    if (!bestCost.containsKey(end)) {
      return null;
    }

    final result = <_GraphEdge>[];
    var cursor = end;
    while (cursor != start) {
      final step = previous[cursor];
      if (step == null) {
        return null;
      }
      result.insert(0, step.edge);
      cursor = step.previousNode;
    }

    return result;
  }

  bool _isBetterCost(_NodeCost a, _NodeCost b) {
    if ((a.riskScore - b.riskScore).abs() > 0.0001) {
      return a.riskScore < b.riskScore;
    }
    return a.distanceKm < b.distanceKm;
  }

  double _riskPenalty(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return 1;
      case 'MEDIUM':
        return 3;
      case 'HIGH':
        return 7;
      default:
        return 4;
    }
  }

  SafeRouteLocation? _nearestRoutableLocation(
    SafeRouteLocation source,
    Set<String> routableNames,
    Map<String, SafeRouteLocation> locationsByName,
  ) {
    SafeRouteLocation? nearest;
    var bestDistance = double.infinity;

    for (final name in routableNames) {
      final candidate = locationsByName[name];
      if (candidate == null) continue;

      final distance = _haversineDistanceKm(
        source.lat,
        source.lng,
        candidate.lat,
        candidate.lng,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        nearest = candidate;
      }
    }

    return nearest;
  }

  _GraphEdge _buildConnectorEdge(
    SafeRouteLocation from,
    SafeRouteLocation to,
  ) {
    return _GraphEdge(
      from: from.name,
      to: to.name,
      distanceKm: _haversineDistanceKm(from.lat, from.lng, to.lat, to.lng),
      riskLevel: _safetyToConnectorRisk(from.safety),
      points: [
        SafeRoutePoint(lat: from.lat, lng: from.lng),
        SafeRoutePoint(lat: to.lat, lng: to.lng),
      ],
    );
  }

  String _safetyToConnectorRisk(String safety) {
    switch (safety.toUpperCase()) {
      case 'HIGH':
        return 'LOW';
      case 'MEDIUM':
        return 'MEDIUM';
      case 'LOW':
        return 'HIGH';
      default:
        return 'MEDIUM';
    }
  }

  String _aggregateRiskLevel(List<String> risks) {
    var maxScore = 0;
    for (final risk in risks) {
      final score = _riskRank(risk);
      if (score > maxScore) maxScore = score;
    }

    if (maxScore >= 3) return 'HIGH';
    if (maxScore == 2) return 'MEDIUM';
    return 'LOW';
  }

  int _riskRank(String risk) {
    switch (risk.toUpperCase()) {
      case 'LOW':
        return 1;
      case 'MEDIUM':
        return 2;
      case 'HIGH':
        return 3;
      default:
        return 2;
    }
  }

  int _riskToDangerScore(String risk) {
    switch (risk.toUpperCase()) {
      case 'LOW':
        return 20;
      case 'MEDIUM':
        return 55;
      case 'HIGH':
        return 85;
      default:
        return 60;
    }
  }

  List<SafeRoutePoint> _mergeEdgePoints(List<_GraphEdge> edges) {
    if (edges.isEmpty) return [];

    final merged = <SafeRoutePoint>[];
    for (var i = 0; i < edges.length; i++) {
      final points = edges[i].points;
      if (points.isEmpty) continue;

      if (merged.isEmpty) {
        merged.addAll(points);
        continue;
      }

      merged.addAll(points.skip(1));
    }

    return merged;
  }

  List<SafeRouteHazard> _hazardsNearRoute(List<SafeRoutePoint> routePoints) {
    const thresholdKm = 0.35;
    return _hazards.where((hazard) {
      for (final point in routePoints) {
        if (_haversineDistanceKm(
              hazard.lat,
              hazard.lng,
              point.lat,
              point.lng,
            ) <=
            thresholdKm) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  double _haversineDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _toRad(double degrees) => degrees * (math.pi / 180.0);

  void startNavigation() {
    state = state.copyWith(isNavigating: true);
  }

  void stopNavigation() {
    state = state.copyWith(isNavigating: false);
  }

  Future<void> dropHazardPin({
    double latitude = 21.1065,
    double longitude = 79.0590,
    String hazardType = 'suspicious_activity',
    String description = '',
  }) async {
    try {
      final response = await ApiService.dropHazardPin(
        latitude: latitude,
        longitude: longitude,
        hazardType: hazardType,
        description: description,
      );

      final responseLat = _parseDouble(response['lat']) ?? latitude;
      final responseLng = _parseDouble(response['lng']) ?? longitude;
      final responseType = (response['hazard_type'] as String?) ?? hazardType;
      final responseDescription =
          (response['description'] as String?) ?? description;
      final hazardDescription = responseDescription.trim().isNotEmpty
          ? responseDescription.trim()
          : 'User reported hazard';

      final reportedHazard = SafeRouteHazard(
        id: DateTime.now().millisecondsSinceEpoch,
        lat: responseLat,
        lng: responseLng,
        severity: _severityFromHazardType(responseType),
        description: hazardDescription,
      );

      state = state.copyWith(
        nearbyHazards: [...state.nearbyHazards, reportedHazard],
        error: null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: 'Failed to report hazard');
    }
  }

  double? _parseDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String _severityFromHazardType(String hazardType) {
    switch (hazardType.toLowerCase()) {
      case 'harassment':
      case 'unsafe_road':
        return 'HIGH';
      case 'suspicious_activity':
      case 'construction':
      case 'flooding':
        return 'MEDIUM';
      case 'broken_streetlight':
        return 'LOW';
      default:
        return 'MEDIUM';
    }
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
