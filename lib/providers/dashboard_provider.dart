import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardState {
  final bool isSosActive;
  final bool isAiListenerActive;
  final String aiListenerStatus;
  final List<String> listeningKeywords;
  final bool isOffline;

  const DashboardState({
    this.isSosActive = false,
    this.isAiListenerActive = true,
    this.aiListenerStatus = 'ACTIVE',
    this.listeningKeywords = const ['Bachao', 'Help'],
    this.isOffline = false,
  });

  DashboardState copyWith({
    bool? isSosActive,
    bool? isAiListenerActive,
    String? aiListenerStatus,
    List<String>? listeningKeywords,
    bool? isOffline,
  }) {
    return DashboardState(
      isSosActive: isSosActive ?? this.isSosActive,
      isAiListenerActive: isAiListenerActive ?? this.isAiListenerActive,
      aiListenerStatus: aiListenerStatus ?? this.aiListenerStatus,
      listeningKeywords: listeningKeywords ?? this.listeningKeywords,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  void activateSos() {
    state = state.copyWith(isSosActive: true);
    // TODO: Connect to Django API — send SOS alert with location
  }

  void deactivateSos() {
    state = state.copyWith(isSosActive: false);
  }

  void toggleAiListener() {
    final isActive = !state.isAiListenerActive;
    state = state.copyWith(
      isAiListenerActive: isActive,
      aiListenerStatus: isActive ? 'ACTIVE' : 'PAUSED',
    );
  }

  void setOfflineStatus(bool isOffline) {
    state = state.copyWith(isOffline: isOffline);
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
