import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/dashboard_provider.dart';
import '../../widgets/common/quick_action_tile.dart';
import '../../widgets/common/section_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield, color: AppColors.electricBlue, size: 28),
            const SizedBox(width: 12),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(context),
            _buildSosButton(context, dashboard, notifier),
            _buildQuickActions(context),
            _buildAiListenerCard(context, dashboard, notifier),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.directions_run,
                color: AppColors.textMuted, size: 22),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Quick Safe Route',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                ),
                onSubmitted: (value) {
                  context.go(AppConstants.safeMapPath);
                },
              ),
            ),
            Icon(Icons.search, color: AppColors.textMuted, size: 22),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSosButton(
      BuildContext context, DashboardState state, DashboardNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          GestureDetector(
            onLongPress: () => notifier.activateSos(),
            onLongPressEnd: (_) => notifier.deactivateSos(),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.crimson,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.crimson.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
                border: Border.all(
                  color: AppColors.backgroundDark,
                  width: 6,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 56,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, color: AppColors.textMuted, size: 16),
              const SizedBox(width: 8),
              Text(
                'Hold to Activate',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'QUICK ACTIONS'),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                QuickActionTile(
                  icon: Icons.call,
                  label: 'Fake Call',
                  color: AppColors.emerald,
                  onTap: () => context.go(AppConstants.settingsPath),
                ),
                const SizedBox(width: 12),
                QuickActionTile(
                  icon: Icons.radar,
                  label: 'Digital Scan',
                  color: AppColors.electricBlue,
                  onTap: () => context.go(AppConstants.privacyHubPath),
                ),
                const SizedBox(width: 12),
                QuickActionTile(
                  icon: Icons.share_location,
                  label: 'Live Loc',
                  color: AppColors.electricBlue,
                ),
                const SizedBox(width: 12),
                QuickActionTile(
                  icon: Icons.verified_user,
                  label: 'Safe Zone',
                  color: AppColors.accentOrange,
                  onTap: () => context.go(AppConstants.safeMapPath),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiListenerCard(
      BuildContext context, DashboardState state, DashboardNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (state.isAiListenerActive)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emerald.withValues(alpha: 0.3),
                    ),
                  ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.isAiListenerActive
                        ? AppColors.emerald
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Edge AI Listener: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                      children: [
                        TextSpan(
                          text: state.aiListenerStatus,
                          style: TextStyle(
                            color: state.isAiListenerActive
                                ? AppColors.emerald
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Listening for: "${state.listeningKeywords.join('" / "')}"',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.graphic_eq, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}
