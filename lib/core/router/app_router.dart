import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../ui/screens/auth/auth_screen.dart';
import '../../ui/screens/dashboard/dashboard_screen.dart';
import '../../ui/screens/safe_map/safe_map_screen.dart';
import '../../ui/screens/audio_listener/audio_listener_screen.dart';
import '../../ui/screens/privacy_hub/privacy_hub_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';
import '../../ui/widgets/common/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.authPath,
    routes: [
      GoRoute(
        path: AppConstants.authPath,
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppConstants.dashboardPath,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppConstants.safeMapPath,
            builder: (context, state) => const SafeMapScreen(),
          ),
          GoRoute(
            path: AppConstants.audioListenerPath,
            builder: (context, state) => const AudioListenerScreen(),
          ),
          GoRoute(
            path: AppConstants.privacyHubPath,
            builder: (context, state) => const PrivacyHubScreen(),
          ),
          GoRoute(
            path: AppConstants.settingsPath,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
