import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

enum AuthStep { phoneInput, otpVerification, permissions, complete }

class AuthState {
  final AuthStep step;
  final String phoneNumber;
  final String otp;
  final bool isLoading;
  final String? error;
  final int otpResendCountdown;
  final UserModel? user;

  const AuthState({
    this.step = AuthStep.phoneInput,
    this.phoneNumber = '',
    this.otp = '',
    this.isLoading = false,
    this.error,
    this.otpResendCountdown = 45,
    this.user,
  });

  AuthState copyWith({
    AuthStep? step,
    String? phoneNumber,
    String? otp,
    bool? isLoading,
    String? error,
    int? otpResendCountdown,
    UserModel? user,
  }) {
    return AuthState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      otpResendCountdown: otpResendCountdown ?? this.otpResendCountdown,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void setOtpDigit(int index, String digit) {
    final otp = state.otp.padRight(6, ' ').split('');
    otp[index] = digit;
    state = state.copyWith(otp: otp.join().trim());
  }

  Future<void> sendOtp() async {
    state = state.copyWith(isLoading: true, error: null);
    // TODO: Connect to Django API
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      isLoading: false,
      step: AuthStep.otpVerification,
      otpResendCountdown: 45,
    );
  }

  Future<void> verifyOtp() async {
    state = state.copyWith(isLoading: true, error: null);
    // TODO: Connect to Django API
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      isLoading: false,
      step: AuthStep.permissions,
    );
  }

  void togglePermission(String permission, bool value) {
    final user = state.user ??
        UserModel(phoneNumber: state.phoneNumber);
    switch (permission) {
      case 'location':
        state = state.copyWith(
            user: user.copyWith(locationPermission: value));
        break;
      case 'microphone':
        state = state.copyWith(
            user: user.copyWith(microphonePermission: value));
        break;
      case 'sms':
        state = state.copyWith(
            user: user.copyWith(smsPermission: value));
        break;
    }
  }

  Future<void> completeSetup() async {
    state = state.copyWith(isLoading: true);
    // TODO: Connect to Django API
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isLoading: false,
      step: AuthStep.complete,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
