import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppConstants.dashboardPath)) return 0;
    if (location.startsWith(AppConstants.safeMapPath)) return 1;
    if (location.startsWith(AppConstants.audioListenerPath)) return 2;
    if (location.startsWith(AppConstants.settingsPath)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderDark, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.backgroundDark,
          indicatorColor: AppColors.electricBlueDim,
          selectedIndex: index,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go(AppConstants.dashboardPath);
              case 1:
                context.go(AppConstants.safeMapPath);
              case 2:
                context.go(AppConstants.audioListenerPath);
              case 3:
                context.go(AppConstants.settingsPath);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, color: AppColors.textDisabled),
              selectedIcon: Icon(Icons.grid_view, color: AppColors.electricBlue),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: AppColors.textDisabled),
              selectedIcon: Icon(Icons.map, color: AppColors.electricBlue),
              label: 'Safe Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.mic_none, color: AppColors.textDisabled),
              selectedIcon: Icon(Icons.mic, color: AppColors.electricBlue),
              label: 'Listen',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: AppColors.textDisabled),
              selectedIcon: Icon(Icons.settings, color: AppColors.electricBlue),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
