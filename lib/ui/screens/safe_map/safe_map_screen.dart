import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/map_provider.dart';
import '../../../models/route_info.dart';
import '../../widgets/common/offline_banner.dart';

class SafeMapScreen extends ConsumerWidget {
  const SafeMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapProvider);
    final notifier = ref.read(mapProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          // Map placeholder with offline fallback
          _buildMapArea(context, mapState),

          // Search overlay at top
          _buildSearchOverlay(context, mapState, notifier),

          // Floating action buttons
          _buildFloatingActions(context, notifier),

          // Bottom sheet with route info
          if (mapState.activeRoute != null)
            _buildRouteSheet(context, mapState.activeRoute!, notifier),

          // Offline banner
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        image: const DecorationImage(
          image: AssetImage('assets/images/screen_map.png'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: CustomPaint(
        painter: _RouteOverlayPainter(),
      ),
    );
  }

  Widget _buildSearchOverlay(
      BuildContext context, MapState state, MapNotifier notifier) {
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
              AppColors.backgroundDark.withValues(alpha: 0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildSearchField(
              context,
              icon: Icons.my_location,
              iconColor: AppColors.accentOrange,
              value: state.origin,
              hint: 'Current Location',
              onChanged: notifier.setOrigin,
            ),
            const SizedBox(height: 8),
            _buildSearchField(
              context,
              icon: Icons.location_on,
              iconColor: AppColors.emerald,
              value: state.destination,
              hint: 'Where to?',
              onChanged: notifier.setDestination,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value),
              onChanged: onChanged,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: true,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions(BuildContext context, MapNotifier notifier) {
    return Positioned(
      right: 16,
      bottom: 320,
      child: Column(
        children: [
          _floatingButton(Icons.layers, () {}),
          const SizedBox(height: 12),
          _floatingButton(Icons.navigation, () {}),
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
                onTap: () => notifier.dropHazardPin(),
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
      BuildContext context, RouteInfo route, MapNotifier notifier) {
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

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(
            top: BorderSide(color: AppColors.slate800),
          ),
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
                // Drag handle
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.slate700,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),

                // Title row
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
                            'Via ${route.via} • ${route.estimatedTime}',
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
                              children: [
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
                const SizedBox(height: 20),

                // Safety metrics
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        context,
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
                        context,
                        icon: Icons.warning_amber,
                        iconColor: AppColors.amber,
                        title: '${route.recentIncidents} Recent Incidents',
                        subtitle: 'Last 24 hours',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Start navigation button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => notifier.startNavigation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Start Navigation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _metricCard(
    BuildContext context, {
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
}

class _RouteOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Safe route (emerald green, solid)
    final safePaint = Paint()
      ..color = AppColors.emerald
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final safePath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.35,
        size.width * 0.35,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.55,
        size.width * 0.6,
        size.height * 0.6,
      );

    canvas.drawPath(safePath, safePaint);

    // Caution route (amber, dashed simulation)
    final cautionPaint = Paint()
      ..color = AppColors.amber.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cautionPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.4,
        size.width * 0.2,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.58,
        size.width * 0.6,
        size.height * 0.6,
      );

    canvas.drawPath(cautionPath, cautionPaint);

    // Origin marker
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.25),
      8,
      Paint()..color = AppColors.accentOrange,
    );

    // Destination marker
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.6),
      8,
      Paint()..color = AppColors.emerald,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.6),
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
