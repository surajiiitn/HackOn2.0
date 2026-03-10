import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';

class DashboardState {
  final bool isSosActive;
  final String? activeEventId;
  final bool isAiListenerActive;
  final String aiListenerStatus;
  final List<String> listeningKeywords;
  final bool isOffline;
  final String? error;

  const DashboardState({
    this.isSosActive = false,
    this.activeEventId,
    this.isAiListenerActive = true,
    this.aiListenerStatus = 'ACTIVE',
    this.listeningKeywords = const ['Bachao', 'Help'],
    this.isOffline = false,
    this.error,
  });

  DashboardState copyWith({
    bool? isSosActive,
    String? activeEventId,
    bool? isAiListenerActive,
    String? aiListenerStatus,
    List<String>? listeningKeywords,
    bool? isOffline,
    String? error,
  }) {
    return DashboardState(
      isSosActive: isSosActive ?? this.isSosActive,
      activeEventId: activeEventId ?? this.activeEventId,
      isAiListenerActive: isAiListenerActive ?? this.isAiListenerActive,
      aiListenerStatus: aiListenerStatus ?? this.aiListenerStatus,
      listeningKeywords: listeningKeywords ?? this.listeningKeywords,
      isOffline: isOffline ?? this.isOffline,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  Future<void> activateSos() async {
    state = state.copyWith(isSosActive: true, error: null);
    try {
      // Default coordinates (will be replaced with real GPS later)
      final data = await ApiService.triggerSos(
        latitude: 19.0760,
        longitude: 72.8777,
        triggerType: 'manual',
      );
      state = state.copyWith(
        activeEventId: data['id'] as String?,
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      // Keep SOS active locally even if API fails (offline-first)
    }
  }

  Future<void> deactivateSos() async {
    if (state.activeEventId != null) {
      try {
        await ApiService.cancelSos(state.activeEventId!);
      } catch (_) {}
    }
    state = state.copyWith(isSosActive: false, activeEventId: null);
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
