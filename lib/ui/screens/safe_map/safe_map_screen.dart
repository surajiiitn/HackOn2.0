import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/route_info.dart';
import '../../../providers/map_provider.dart';
import '../../widgets/common/offline_banner.dart';

class SafeMapScreen extends ConsumerStatefulWidget {
  const SafeMapScreen({super.key});

  @override
  ConsumerState<SafeMapScreen> createState() => _SafeMapScreenState();
}

class _SafeMapScreenState extends ConsumerState<SafeMapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();

    ref.listenManual<MapState>(mapProvider, (previous, next) {
      final pointsChanged = previous?.routePoints != next.routePoints;
      if (pointsChanged && next.routePoints.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _fitToRoute(next.routePoints);
        });
      }
    });
  }

  void _fitToRoute(List<SafeRoutePoint> routePoints) {
    final points = routePoints.map((p) => LatLng(p.lat, p.lng)).toList();
    if (points.length < 2) return;

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(64),
      ),
    );
  }

  void _showHazardDetails(SafeRouteHazard hazard) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.slate900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.slate700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                '${hazard.severity} Hazard',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hazard.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final notifier = ref.read(mapProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          _buildMapArea(context, mapState),
          _buildSearchOverlay(context, mapState, notifier),
          _buildFloatingActions(context, mapState, notifier),
          if (mapState.error != null)
            _buildInlineMessage(context, mapState.error!),
          if (mapState.activeRoute != null)
            _buildRouteSheet(
              context,
              mapState.activeRoute!,
              mapState.nearbyHazards.length,
              notifier,
            ),
          if (!mapState.isOfflineMapAvailable)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: OfflineBanner(
                  message: 'Offline mode — using cached map tiles',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapArea(BuildContext context, MapState state) {
    final routePoints =
        state.routePoints.map((p) => LatLng(p.lat, p.lng)).toList();

    final routeColor = _routeColor(state.activeRiskLevel);
    final routePolygon = routePoints.length >= 2
        ? _buildRouteZonePolygon(routePoints, zoneWidthMeters: 65)
        : const <LatLng>[];
    final hazardCircles = state.nearbyHazards
        .map(
          (hazard) => CircleMarker(
            point: LatLng(hazard.lat, hazard.lng),
            radius: 200,
            useRadiusInMeter: true,
            color: _hazardColor(hazard.severity).withValues(alpha: 0.24),
            borderColor: _hazardColor(hazard.severity),
            borderStrokeWidth: 2,
          ),
        )
        .toList();

    final hazardMarkers = state.nearbyHazards
        .map(
          (hazard) => Marker(
            point: LatLng(hazard.lat, hazard.lng),
            width: 34,
            height: 34,
            child: GestureDetector(
              onTap: () => _showHazardDetails(hazard),
              child: Container(
                decoration: BoxDecoration(
                  color: _hazardColor(hazard.severity),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
        .toList();

    final startEndMarkers = <Marker>[];
    if (routePoints.isNotEmpty) {
      startEndMarkers.add(
        Marker(
          point: routePoints.first,
          width: 32,
          height: 32,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
          ),
        ),
      );
      startEndMarkers.add(
        Marker(
          point: routePoints.last,
          width: 32,
          height: 32,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.emerald,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.flag, color: Colors.white, size: 16),
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(21.1065, 79.0590),
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.suraksha.ai',
        ),
        if (routePolygon.length >= 3)
          PolygonLayer(
            polygons: [
              Polygon(
                points: routePolygon,
                color: routeColor.withValues(alpha: 0.2),
                borderColor: routeColor.withValues(alpha: 0.7),
                borderStrokeWidth: 2,
              ),
            ],
          ),
        if (hazardCircles.isNotEmpty) CircleLayer(circles: hazardCircles),
        if (routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                color: routeColor,
                strokeWidth: 6,
                borderColor: Colors.white.withValues(alpha: 0.25),
                borderStrokeWidth: 1,
              ),
            ],
          ),
        if (hazardMarkers.isNotEmpty || startEndMarkers.isNotEmpty)
          MarkerLayer(markers: [...hazardMarkers, ...startEndMarkers]),
      ],
    );
  }

  Widget _buildSearchOverlay(
    BuildContext context,
    MapState state,
    MapNotifier notifier,
  ) {
    final locationNames = state.availableLocations.map((e) => e.name).toList();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDark.withValues(alpha: 0.92),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildLocationDropdown(
              icon: Icons.my_location,
              iconColor: AppColors.accentOrange,
              value: locationNames.contains(state.origin) ? state.origin : null,
              hint: 'Select start location',
              locations: locationNames,
              onChanged: notifier.setOrigin,
            ),
            const SizedBox(height: 8),
            _buildLocationDropdown(
              icon: Icons.location_on,
              iconColor: AppColors.emerald,
              value: locationNames.contains(state.destination)
                  ? state.destination
                  : null,
              hint: 'Select destination',
              locations: locationNames,
              onChanged: notifier.setDestination,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.isSearching ? null : notifier.searchRoute,
                icon: state.isSearching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shield, size: 16),
                label: Text(
                  state.isSearching
                      ? 'Analyzing route...'
                      : 'Find Safest Route',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdown({
    required IconData icon,
    required Color iconColor,
    required String? value,
    required String hint,
    required List<String> locations,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true,
              dropdownColor: AppColors.slate900,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              iconEnabledColor: AppColors.textSecondary,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              hint: Text(
                hint,
                style: const TextStyle(color: AppColors.textDisabled),
              ),
              items: locations
                  .map(
                    (name) => DropdownMenuItem<String>(
                      value: name,
                      child: Text(name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (selected) {
                if (selected != null) onChanged(selected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineMessage(BuildContext context, String message) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 196,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.crimsonDim,
          border: Border.all(color: AppColors.crimson.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions(
    BuildContext context,
    MapState state,
    MapNotifier notifier,
  ) {
    return Positioned(
      right: 16,
      bottom: 320,
      child: Column(
        children: [
          _floatingButton(Icons.layers, () {}),
          const SizedBox(height: 12),
          _floatingButton(Icons.navigation, notifier.searchRoute),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  if (!ApiService.isAuthenticated) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to drop a hazard pin'),
                      ),
                    );
                    return;
                  }

                  final point = _resolveHazardDropPoint(state);
                  await notifier.dropHazardPin(
                    latitude: point.latitude,
                    longitude: point.longitude,
                    hazardType: 'suspicious_activity',
                    description: 'Reported from safe map',
                  );
                  if (!context.mounted) return;
                  final hasError = ref.read(mapProvider).error != null;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        hasError
                            ? 'Failed to drop hazard pin'
                            : 'Hazard pin dropped successfully',
                      ),
                      backgroundColor:
                          hasError ? AppColors.crimson : AppColors.emerald,
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.report_problem, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Drop Hazard Pin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.slate700.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildRouteSheet(
    BuildContext context,
    RouteInfo route,
    int nearbyHazards,
    MapNotifier notifier,
  ) {
    final dangerColor = route.dangerScore <= 30
        ? AppColors.emerald
        : route.dangerScore <= 60
            ? AppColors.amber
            : AppColors.crimson;

    final safetyLabel = route.dangerScore <= 30
        ? 'Safe'
        : route.dangerScore <= 60
            ? 'Caution'
            : 'Danger';

    final warningText = nearbyHazards > 0
        ? '⚠ Danger zone detected along this route.'
        : '✅ No hazard zone detected near this route.';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(top: BorderSide(color: AppColors.slate800)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.slate700,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safe Route Found',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${route.origin} → ${route.destination}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${route.distanceKm?.toStringAsFixed(1) ?? '--'} km • Risk ${route.riskLevel ?? '--'} • ${route.estimatedTime}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: dangerColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: dangerColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Danger Score',
                            style: TextStyle(
                              color: dangerColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: '${route.dangerScore}',
                              style: TextStyle(
                                color: dangerColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                              children: const [
                                TextSpan(
                                  text: '/100',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            safetyLabel,
                            style: TextStyle(
                              color: dangerColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    warningText,
                    style: TextStyle(
                      color: nearbyHazards > 0
                          ? AppColors.amber
                          : AppColors.emerald,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        icon: Icons.lightbulb,
                        iconColor: AppColors.emerald,
                        title: 'Good Lighting',
                        subtitle:
                            '${(route.lightingCoverage * 100).round()}% coverage',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _metricCard(
                        icon: Icons.warning_amber,
                        iconColor: AppColors.amber,
                        title: '$nearbyHazards Nearby Hazards',
                        subtitle: 'Near selected route',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: notifier.startNavigation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Start Navigation',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.slate800.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _routeColor(String? riskLevel) {
    switch ((riskLevel ?? '').toUpperCase()) {
      case 'LOW':
        return AppColors.emerald;
      case 'MEDIUM':
        return AppColors.amber;
      case 'HIGH':
        return AppColors.crimson;
      default:
        return AppColors.electricBlue;
    }
  }

  Color _hazardColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'HIGH':
        return AppColors.crimson;
      case 'MEDIUM':
        return AppColors.amber;
      case 'LOW':
        return const Color(0xFFFACC15);
      default:
        return AppColors.amber;
    }
  }

  LatLng _resolveHazardDropPoint(MapState state) {
    if (state.routePoints.isNotEmpty) {
      final midpoint = state.routePoints[state.routePoints.length ~/ 2];
      return LatLng(midpoint.lat, midpoint.lng);
    }

    try {
      return _mapController.camera.center;
    } catch (_) {
      return const LatLng(21.1065, 79.0590);
    }
  }

  List<LatLng> _buildRouteZonePolygon(
    List<LatLng> pathPoints, {
    required double zoneWidthMeters,
  }) {
    if (pathPoints.length < 2) return const <LatLng>[];

    final leftEdge = <LatLng>[];
    final rightEdge = <LatLng>[];

    for (var i = 0; i < pathPoints.length; i++) {
      final current = pathPoints[i];
      final prev = i == 0 ? current : pathPoints[i - 1];
      final next = i == pathPoints.length - 1 ? current : pathPoints[i + 1];

      var deltaLat = next.latitude - prev.latitude;
      var deltaLng = next.longitude - prev.longitude;
      if (deltaLat.abs() < 0.0000001 && deltaLng.abs() < 0.0000001) {
        deltaLat = 0.0000001;
      }

      final length = math.sqrt(deltaLat * deltaLat + deltaLng * deltaLng);
      final normalLat = deltaLng / length;
      final normalLng = -deltaLat / length;

      final latOffset = _metersToLatitudeDegrees(zoneWidthMeters) * normalLat;
      final lngOffset = _metersToLongitudeDegrees(
            zoneWidthMeters,
            current.latitude,
          ) *
          normalLng;

      leftEdge.add(
        LatLng(current.latitude + latOffset, current.longitude + lngOffset),
      );
      rightEdge.add(
        LatLng(current.latitude - latOffset, current.longitude - lngOffset),
      );
    }

    final polygon = <LatLng>[
      ...leftEdge,
      ...rightEdge.reversed,
    ];

    return polygon.length >= 3 ? polygon : const <LatLng>[];
  }

  double _metersToLatitudeDegrees(double meters) => meters / 111320.0;

  double _metersToLongitudeDegrees(double meters, double latitude) {
    final cosLat = math.cos(latitude * math.pi / 180).abs();
    final safeCos = cosLat < 0.01 ? 0.01 : cosLat;
    return meters / (111320.0 * safeCos);
  }
}
