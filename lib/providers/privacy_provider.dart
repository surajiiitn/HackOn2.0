import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/breach_info.dart';

class PrivacyState {
  final int identityScore;
  final double scoreChange;
  final String deepfakeExposure;
  final bool isScanning;
  final String lastScanTime;
  final List<BreachInfo> breaches;

  const PrivacyState({
    this.identityScore = 74,
    this.scoreChange = -4.0,
    this.deepfakeExposure = 'Low',
    this.isScanning = false,
    this.lastScanTime = '2 hours ago',
    this.breaches = const [],
  });

  PrivacyState copyWith({
    int? identityScore,
    double? scoreChange,
    String? deepfakeExposure,
    bool? isScanning,
    String? lastScanTime,
    List<BreachInfo>? breaches,
  }) {
    return PrivacyState(
      identityScore: identityScore ?? this.identityScore,
      scoreChange: scoreChange ?? this.scoreChange,
      deepfakeExposure: deepfakeExposure ?? this.deepfakeExposure,
      isScanning: isScanning ?? this.isScanning,
      lastScanTime: lastScanTime ?? this.lastScanTime,
      breaches: breaches ?? this.breaches,
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
    state = state.copyWith(isScanning: true);
    // TODO: Connect to Django API — trigger OSINT scan
    await Future.delayed(const Duration(seconds: 3));
    state = state.copyWith(isScanning: false, lastScanTime: 'Just now');
  }

  void dismissBreach(String id) {
    state = state.copyWith(
      breaches: state.breaches.where((b) => b.id != id).toList(),
    );
  }
}

final privacyProvider =
    StateNotifierProvider<PrivacyNotifier, PrivacyState>((ref) {
  return PrivacyNotifier();
});
