import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/emergency_contact.dart';
import '../core/services/api_service.dart';

class SettingsState {
  final bool zeroInternetMode;
  final String offlineMapsSize;
  final String fakeCallName;
  final int fakeCallDelay;
  final bool vibrationAlerts;
  final List<EmergencyContact> emergencyContacts;
  final bool isLoadingContacts;

  const SettingsState({
    this.zeroInternetMode = true,
    this.offlineMapsSize = '320MB',
    this.fakeCallName = 'Mom',
    this.fakeCallDelay = 30,
    this.vibrationAlerts = true,
    this.emergencyContacts = const [],
    this.isLoadingContacts = false,
  });

  SettingsState copyWith({
    bool? zeroInternetMode,
    String? offlineMapsSize,
    String? fakeCallName,
    int? fakeCallDelay,
    bool? vibrationAlerts,
    List<EmergencyContact>? emergencyContacts,
    bool? isLoadingContacts,
  }) {
    return SettingsState(
      zeroInternetMode: zeroInternetMode ?? this.zeroInternetMode,
      offlineMapsSize: offlineMapsSize ?? this.offlineMapsSize,
      fakeCallName: fakeCallName ?? this.fakeCallName,
      fakeCallDelay: fakeCallDelay ?? this.fakeCallDelay,
      vibrationAlerts: vibrationAlerts ?? this.vibrationAlerts,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      isLoadingContacts: isLoadingContacts ?? this.isLoadingContacts,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(SettingsState(
          emergencyContacts: const [
            EmergencyContact(id: '1', name: 'Mom', phoneNumber: '+919876543210'),
            EmergencyContact(id: '2', name: 'Sarah', phoneNumber: '+919876543211'),
            EmergencyContact(id: '3', name: 'Dad', phoneNumber: '+919876543212'),
            EmergencyContact(id: '4', name: 'Mike', phoneNumber: '+919876543213'),
          ],
        )) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    if (!ApiService.isAuthenticated) return;
    state = state.copyWith(isLoadingContacts: true);
    try {
      final data = await ApiService.listContacts();
      final results = data['results'] as List<dynamic>?;
      if (results != null && results.isNotEmpty) {
        state = state.copyWith(
          emergencyContacts: results
              .map((c) =>
                  EmergencyContact.fromJson(c as Map<String, dynamic>))
              .toList(),
          isLoadingContacts: false,
        );
      } else {
        state = state.copyWith(isLoadingContacts: false);
      }
    } catch (_) {
      state = state.copyWith(isLoadingContacts: false);
    }
  }

  void toggleZeroInternetMode() {
    state = state.copyWith(zeroInternetMode: !state.zeroInternetMode);
  }

  void setFakeCallName(String name) {
    state = state.copyWith(fakeCallName: name);
  }

  void setFakeCallDelay(int delay) {
    state = state.copyWith(fakeCallDelay: delay);
  }

  void toggleVibrationAlerts() {
    state = state.copyWith(vibrationAlerts: !state.vibrationAlerts);
  }

  Future<void> addEmergencyContact(EmergencyContact contact) async {
    state = state.copyWith(
      emergencyContacts: [...state.emergencyContacts, contact],
    );
    try {
      await ApiService.addContact({
        'name': contact.name,
        'phone_number': contact.phoneNumber,
        'relationship': '',
      });
      await loadContacts();
    } catch (_) {
      // Keep local state even if API fails
    }
  }

  Future<void> removeEmergencyContact(String id) async {
    state = state.copyWith(
      emergencyContacts:
          state.emergencyContacts.where((c) => c.id != id).toList(),
    );
    try {
      await ApiService.deleteContact(id);
    } catch (_) {
      // Already removed from local state
    }
  }

  Future<void> triggerTestFakeCall() async {
    await Future.delayed(Duration(seconds: state.fakeCallDelay));
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
