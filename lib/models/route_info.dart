enum RouteSafetyLevel { safe, caution, danger }

class RouteInfo {
  final String id;
  final String origin;
  final String destination;
  final int dangerScore;
  final RouteSafetyLevel safetyLevel;
  final String estimatedTime;
  final String via;
  final double lightingCoverage;
  final int recentIncidents;
  final bool isNavigating;

  const RouteInfo({
    required this.id,
    required this.origin,
    required this.destination,
    required this.dangerScore,
    required this.safetyLevel,
    required this.estimatedTime,
    this.via = '',
    this.lightingCoverage = 0.0,
    this.recentIncidents = 0,
    this.isNavigating = false,
  });

  RouteInfo copyWith({
    String? id,
    String? origin,
    String? destination,
    int? dangerScore,
    RouteSafetyLevel? safetyLevel,
    String? estimatedTime,
    String? via,
    double? lightingCoverage,
    int? recentIncidents,
    bool? isNavigating,
  }) {
    return RouteInfo(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      dangerScore: dangerScore ?? this.dangerScore,
      safetyLevel: safetyLevel ?? this.safetyLevel,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      via: via ?? this.via,
      lightingCoverage: lightingCoverage ?? this.lightingCoverage,
      recentIncidents: recentIncidents ?? this.recentIncidents,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['id'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      dangerScore: json['danger_score'] as int,
      safetyLevel: RouteSafetyLevel.values.byName(json['safety_level'] as String),
      estimatedTime: json['estimated_time'] as String,
      via: json['via'] as String? ?? '',
      lightingCoverage: (json['lighting_coverage'] as num?)?.toDouble() ?? 0.0,
      recentIncidents: json['recent_incidents'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin': origin,
      'destination': destination,
      'danger_score': dangerScore,
      'safety_level': safetyLevel.name,
      'estimated_time': estimatedTime,
      'via': via,
      'lighting_coverage': lightingCoverage,
      'recent_incidents': recentIncidents,
    };
  }
}
