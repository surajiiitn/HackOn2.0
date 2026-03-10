import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/permission_toggle.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);
    final showOtp = auth.step.index >= AuthStep.otpVerification.index;
    final showPermissions = auth.step.index >= AuthStep.permissions.index;

    if (auth.step == AuthStep.complete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(AppConstants.dashboardPath);
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildHeader(context),
                const SizedBox(height: 48),
                if (auth.error != null) ...[
                  _buildErrorBanner(context, auth.error!),
                  const SizedBox(height: 16),
                ],
                _buildPhoneInput(context, auth, notifier),
                if (showOtp) ...[
                  const SizedBox(height: 24),
                  _buildOtpSection(context, auth, notifier),
                  if (auth.step == AuthStep.otpVerification) ...[
                    const SizedBox(height: 16),
                    _buildVerifyOtpButton(context, auth, notifier),
                  ],
                ],
                if (showPermissions) ...[
                  const SizedBox(height: 32),
                  _buildPermissionsSection(context, auth, notifier),
                  const SizedBox(height: 32),
                  _buildCompleteButton(context, auth, notifier),
                ],
                const SizedBox(height: 24),
                Text(
                  AppConstants.encryptionNote.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDisabled,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.crimsonDim,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.crimson.withValues(alpha: 0.5)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.electricBlueDim,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.shield,
            color: AppColors.electricBlue,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.appTagline,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneInput(
      BuildContext context, AuthState auth, AuthNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Secure Login',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border.all(color: AppColors.borderDark),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                AppConstants.countryCode,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: TextField(
                  keyboardType: TextInputType.phone,
                  onChanged: notifier.setPhoneNumber,
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : () => notifier.sendOtp(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(auth.isLoading ? 'Sending...' : 'Send Verification Code'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyOtpButton(
      BuildContext context, AuthState auth, AuthNotifier notifier) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: auth.isLoading || auth.otp.length != AppConstants.otpLength
            ? null
            : () => notifier.verifyOtp(),
        child: Text(auth.isLoading ? 'Verifying...' : 'Verify Code'),
      ),
    );
  }

  Widget _buildOtpSection(
      BuildContext context, AuthState auth, AuthNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Verification Code',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              'Resend in 0:${auth.otpResendCountdown.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.electricBlue,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            AppConstants.otpLength,
            (index) => SizedBox(
              width: 48,
              height: 56,
              child: TextField(
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                ),
                onChanged: (value) {
                  notifier.setOtpDigit(index, value);
                  if (value.isNotEmpty && index < 5) {
                    FocusScope.of(context).nextFocus();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection(
      BuildContext context, AuthState auth, AuthNotifier notifier) {
    final user = auth.user ?? const UserModel(phoneNumber: '');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user,
                  color: AppColors.electricBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Security Permissions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PermissionToggle(
            icon: Icons.location_on,
            title: 'Precise Location',
            description:
                'Required for real-time SOS tracking and geofencing alerts.',
            value: user.locationPermission,
            onChanged: (v) => notifier.togglePermission('location', v),
          ),
          PermissionToggle(
            icon: Icons.mic,
            title: 'Microphone Access',
            description:
                'Used for voice-activated SOS triggers and audio surveillance.',
            value: user.microphonePermission,
            onChanged: (v) => notifier.togglePermission('microphone', v),
          ),
          PermissionToggle(
            icon: Icons.sms,
            title: 'SMS & Emergency Contacts',
            description:
                'Automatically alerts your trusted network during emergencies.',
            value: user.smsPermission,
            onChanged: (v) => notifier.togglePermission('sms', v),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(
      BuildContext context, AuthState auth, AuthNotifier notifier) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: auth.isLoading
            ? null
            : () {
                notifier.completeSetup().then((_) {
                  if (context.mounted) {
                    context.go(AppConstants.dashboardPath);
                  }
                });
              },
        child: const Text('Complete Setup'),
      ),
    );
  }
}
