import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/services/api_service.dart';

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
  AuthNotifier() : super(const AuthState()) {
    _tryAutoLogin();
  }

  String _normalizePhoneNumber(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) return '+91$digits';
    if (digits.length == 12 && digits.startsWith('91')) return '+$digits';
    if (input.startsWith('+')) return input;
    return '+$digits';
  }

  Future<void> _tryAutoLogin() async {
    await ApiService.loadTokens();
    if (ApiService.isAuthenticated) {
      try {
        final data = await ApiService.getProfile();
        state = state.copyWith(
          user: UserModel.fromJson(data),
          step: AuthStep.complete,
        );
      } catch (_) {
        await ApiService.clearTokens();
      }
    }
  }

  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void setOtpDigit(int index, String digit) {
    final otp = state.otp.padRight(6, ' ').split('');
    otp[index] = digit;
    state = state.copyWith(otp: otp.join().trim());
  }

  Future<void> sendOtp() async {
    if (state.phoneNumber.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter your phone number');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final phone = _normalizePhoneNumber(state.phoneNumber);
      await ApiService.requestOtp(phone);
      state = state.copyWith(
        isLoading: false,
        step: AuthStep.otpVerification,
        otpResendCountdown: 45,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Network error. Please try again.');
    }
  }

  Future<void> verifyOtp() async {
    if (state.otp.length < 6) {
      state = state.copyWith(error: 'Please enter the 6-digit OTP');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final phone = _normalizePhoneNumber(state.phoneNumber);
      final data = await ApiService.verifyOtp(phone, state.otp);
      final userData = data['user'] as Map<String, dynamic>?;
      state = state.copyWith(
        isLoading: false,
        step: AuthStep.permissions,
        user: userData != null ? UserModel.fromJson(userData) : null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Network error. Please try again.');
    }
  }

  void togglePermission(String permission, bool value) {
    final user = state.user ?? UserModel(phoneNumber: state.phoneNumber);
    switch (permission) {
      case 'location':
        state = state.copyWith(user: user.copyWith(locationPermission: value));
        break;
      case 'microphone':
        state =
            state.copyWith(user: user.copyWith(microphonePermission: value));
        break;
      case 'sms':
        state = state.copyWith(user: user.copyWith(smsPermission: value));
        break;
    }
  }

  Future<void> completeSetup() async {
    state = state.copyWith(isLoading: true);
    try {
      await ApiService.updateProfile({
        'preferred_language': 'en',
      });
      state = state.copyWith(isLoading: false, step: AuthStep.complete);
    } catch (_) {
      // Proceed even if profile update fails
      state = state.copyWith(isLoading: false, step: AuthStep.complete);
    }
  }

  Future<void> logout() async {
    await ApiService.clearTokens();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
