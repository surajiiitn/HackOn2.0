import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/breach_info.dart';
import '../core/services/api_service.dart';

class PrivacyState {
  final int identityScore;
  final double scoreChange;
  final String deepfakeExposure;
  final bool isScanning;
  final String lastScanTime;
  final List<BreachInfo> breaches;
  final String? activeScanId;
  final String? error;

  const PrivacyState({
    this.identityScore = 74,
    this.scoreChange = -4.0,
    this.deepfakeExposure = 'Low',
    this.isScanning = false,
    this.lastScanTime = '2 hours ago',
    this.breaches = const [],
    this.activeScanId,
    this.error,
  });

  PrivacyState copyWith({
    int? identityScore,
    double? scoreChange,
    String? deepfakeExposure,
    bool? isScanning,
    String? lastScanTime,
    List<BreachInfo>? breaches,
    String? activeScanId,
    String? error,
  }) {
    return PrivacyState(
      identityScore: identityScore ?? this.identityScore,
      scoreChange: scoreChange ?? this.scoreChange,
      deepfakeExposure: deepfakeExposure ?? this.deepfakeExposure,
      isScanning: isScanning ?? this.isScanning,
      lastScanTime: lastScanTime ?? this.lastScanTime,
      breaches: breaches ?? this.breaches,
      activeScanId: activeScanId ?? this.activeScanId,
      error: error,
    );
  }
}

class PrivacyNotifier extends StateNotifier<PrivacyState> {
  PrivacyNotifier()
      : super(PrivacyState(
          breaches: const [
            BreachInfo(
              id: '1',
              title: 'Email leaked in 2024 Data Breach',
              description:
                  'Found in "GlobalTech" database dump. Password rotation recommended.',
              severity: BreachSeverity.high,
              iconName: 'alternate_email',
              isActionRequired: true,
              actions: ['View Source', 'Ignore'],
            ),
            BreachInfo(
              id: '2',
              title: 'Unidentified AI Image Found',
              description:
                  'High-probability synthetic image resembling your likeness detected on Reddit.',
              severity: BreachSeverity.critical,
              iconName: 'face_retouching_off',
              isActionRequired: true,
              actions: ['Analyze Metadata', 'Takedown Request'],
            ),
            BreachInfo(
              id: '3',
              title: 'Location Data Exposure',
              description:
                  'Aggregated location history sold by \'DataBrokerX\' to 3 advertising networks.',
              severity: BreachSeverity.medium,
              iconName: 'map',
              isActionRequired: false,
              actions: ['Opt-out of Sale'],
            ),
          ],
        ));

  Future<void> startScan() async {
    state = state.copyWith(isScanning: true, error: null);
    try {
      final data = await ApiService.startPrivacyScan();
      final scanId = data['id']?.toString();
      state = state.copyWith(activeScanId: scanId);

      // Poll for scan completion
      await _pollScanStatus(scanId);
    } on ApiException catch (e) {
      state = state.copyWith(isScanning: false, error: e.message);
    } catch (_) {
      // Fallback: simulate scan completion for offline-first
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isScanning: false, lastScanTime: 'Just now');
    }
  }

  Future<void> _pollScanStatus(String? scanId) async {
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final status = await ApiService.getScanStatus(scanId: scanId);
        final scanStatus = status['status'] as String?;
        if (scanStatus == 'completed' || scanStatus == 'failed') {
          final score = (status['identity_score'] as num?)?.toInt();
          state = state.copyWith(
            isScanning: false,
            lastScanTime: 'Just now',
            identityScore: score ?? state.identityScore,
          );
          return;
        }
      } catch (_) {
        break;
      }
    }
    state = state.copyWith(isScanning: false, lastScanTime: 'Just now');
  }

  void dismissBreach(String id) {
    state = state.copyWith(
      breaches: state.breaches.where((b) => b.id != id).toList(),
    );
  }

  Future<void> requestTakedown(String url) async {
    state = state.copyWith(error: null);
    try {
      await ApiService.generateNotice(url);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: 'Failed to generate legal notice');
    }
  }
}

final privacyProvider =
    StateNotifierProvider<PrivacyNotifier, PrivacyState>((ref) {
  return PrivacyNotifier();
});
