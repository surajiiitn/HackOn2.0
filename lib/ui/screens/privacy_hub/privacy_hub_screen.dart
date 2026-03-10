import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/privacy_provider.dart';
import '../../../models/breach_info.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/section_header.dart';

class PrivacyHubScreen extends ConsumerWidget {
  const PrivacyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(privacyProvider);
    final notifier = ref.read(privacyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield_outlined,
                color: AppColors.electricBlue, size: 28),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                text: 'PrivacyGuard ',
                style: Theme.of(context).textTheme.titleLarge,
                children: const [
                  TextSpan(
                    text: 'AI',
                    style: TextStyle(color: AppColors.electricBlue),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(context, state),
            _buildScanButton(context, state, notifier),
            if (state.error != null) _buildErrorBanner(context, state.error!),
            _buildBreachesSection(context, state, notifier),
            _buildTakedownSection(context, state, notifier),
            _buildBiometricVault(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.crimsonDim,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.crimson.withValues(alpha: 0.45)),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, PrivacyState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Identity Integrity Score',
              value: '${state.identityScore}/100',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.scoreChange < 0
                        ? Icons.trending_down
                        : Icons.trending_up,
                    color: AppColors.accentOrange,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${state.scoreChange.abs().toInt()}%',
                    style: const TextStyle(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              accentColor: AppColors.electricBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Deepfake Exposure',
              value: state.deepfakeExposure,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.emerald, size: 14),
                  const SizedBox(width: 4),
                  const Text(
                    'SECURE',
                    style: TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              subtitle: '24 verified professional profiles scanned',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(
      BuildContext context, PrivacyState state, PrivacyNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: state.isScanning ? null : () => notifier.startScan(),
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.isScanning)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(Icons.radar, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    state.isScanning
                        ? 'Scanning...'
                        : 'Scan My Digital Footprint',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Powered by DeepSearch AI Engine • Last scan: ${state.lastScanTime}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreachesSection(
      BuildContext context, PrivacyState state, PrivacyNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Flagged Breaches',
            leading: const Icon(Icons.warning,
                color: AppColors.accentOrange, size: 20),
            actionLabel: 'ACTION REQUIRED',
          ),
          const SizedBox(height: 12),
          ...state.breaches.map(
            (breach) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _breachCard(context, breach, notifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breachCard(
      BuildContext context, BreachInfo breach, PrivacyNotifier notifier) {
    final iconColor = breach.severity == BreachSeverity.critical
        ? AppColors.electricBlue
        : breach.severity == BreachSeverity.high
            ? AppColors.crimson
            : AppColors.amber;

    final iconBgColor = iconColor.withValues(alpha: 0.1);

    IconData icon;
    switch (breach.iconName) {
      case 'alternate_email':
        icon = Icons.alternate_email;
        break;
      case 'face_retouching_off':
        icon = Icons.face_retouching_off;
        break;
      case 'map':
        icon = Icons.map;
        break;
      default:
        icon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  breach.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  breach.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: breach.actions.map((action) {
                    final isDestructive = action.contains('Takedown');
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () => _handleBreachAction(
                            context, action, breach, notifier),
                        child: Text(
                          action,
                          style: TextStyle(
                            color: isDestructive
                                ? AppColors.accentOrange
                                : AppColors.electricBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _resolveFlaggedUrl(BreachInfo breach) {
    switch (breach.id) {
      case '1':
        return 'https://example.com/databreach/leaked-emails';
      case '2':
        return 'https://reddit.com/r/deepfakes/example';
      case '3':
        return 'https://databrokerx.com/profile/123';
      default:
        return 'https://example.com/privacy/${breach.id}';
    }
  }

  Future<void> _handleBreachAction(
    BuildContext context,
    String action,
    BreachInfo breach,
    PrivacyNotifier notifier,
  ) async {
    if (action.contains('Takedown')) {
      await notifier.requestTakedown(_resolveFlaggedUrl(breach));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Takedown notice generated')),
        );
      }
      return;
    }

    if (action == 'Ignore') {
      notifier.dismissBreach(breach.id);
      return;
    }
  }

  Widget _buildTakedownSection(
      BuildContext context, PrivacyState state, PrivacyNotifier notifier) {
    final defaultUrl = state.breaches.isNotEmpty
        ? _resolveFlaggedUrl(state.breaches.first)
        : 'https://example.com/privacy-exposure';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Takedown Actions',
            leading: const Icon(Icons.gavel,
                color: AppColors.electricBlue, size: 20),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.slate900, AppColors.slate800],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'REGULATORY READY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DPDP Act (India)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Legal Notice Generator',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Automate the creation of enforceable takedown notices and privacy compliance reports under latest DPDP mandates.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await notifier.requestTakedown(defaultUrl);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notice exported and queued'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.backgroundDark,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: const Text(
                          'Export PDF',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await notifier.requestTakedown(defaultUrl);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Draft notice created'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.slate700,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                      ),
                      child: const Text(
                        'Draft Notice',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricVault(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.electricBlueDim,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fingerprint,
                  color: AppColors.electricBlue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biometric Vault',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Securely store and hash your facial data to prevent deepfake spoofing.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.slate800,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward,
                  color: AppColors.textSecondary, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
