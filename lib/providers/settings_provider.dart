import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/emergency_contact.dart';

class SettingsState {
  final bool zeroInternetMode;
  final String offlineMapsSize;
  final String fakeCallName;
  final int fakeCallDelay;
  final bool vibrationAlerts;
  final List<EmergencyContact> emergencyContacts;

  const SettingsState({
    this.zeroInternetMode = true,
    this.offlineMapsSize = '320MB',
    this.fakeCallName = 'Mom',
    this.fakeCallDelay = 30,
    this.vibrationAlerts = true,
    this.emergencyContacts = const [],
  });

  SettingsState copyWith({
    bool? zeroInternetMode,
    String? offlineMapsSize,
    String? fakeCallName,
    int? fakeCallDelay,
    bool? vibrationAlerts,
    List<EmergencyContact>? emergencyContacts,
  }) {
    return SettingsState(
      zeroInternetMode: zeroInternetMode ?? this.zeroInternetMode,
      offlineMapsSize: offlineMapsSize ?? this.offlineMapsSize,
      fakeCallName: fakeCallName ?? this.fakeCallName,
      fakeCallDelay: fakeCallDelay ?? this.fakeCallDelay,
      vibrationAlerts: vibrationAlerts ?? this.vibrationAlerts,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
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
        ));

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

  void addEmergencyContact(EmergencyContact contact) {
    state = state.copyWith(
      emergencyContacts: [...state.emergencyContacts, contact],
    );
  }

  void removeEmergencyContact(String id) {
    state = state.copyWith(
      emergencyContacts:
          state.emergencyContacts.where((c) => c.id != id).toList(),
    );
  }

  Future<void> triggerTestFakeCall() async {
    // TODO: Connect to native platform channel for fake call
    await Future.delayed(Duration(seconds: state.fakeCallDelay));
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
