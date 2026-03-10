import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/common/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text(
          'Offline & Safety Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmergencyContacts(context, state, notifier),
            _buildZeroInternetCard(context, state, notifier),
            _buildFakeCallConfig(context, state, notifier),
            _buildGeneralSettings(context, state, notifier),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts(
      BuildContext context, SettingsState state, SettingsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Emergency Contacts',
            actionLabel: 'Edit List',
            onAction: () {},
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Add button
                _contactAvatar(
                  context,
                  isAdd: true,
                  name: 'Add',
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                // Contact list
                ...state.emergencyContacts.map(
                  (contact) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _contactAvatar(
                      context,
                      name: contact.name,
                      avatarUrl: contact.avatarUrl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactAvatar(
    BuildContext context, {
    required String name,
    String? avatarUrl,
    bool isAdd = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isAdd
                  ? AppColors.emeraldDim
                  : AppColors.slate800,
              shape: BoxShape.circle,
              border: isAdd
                  ? Border.all(
                      color: AppColors.emerald.withValues(alpha: 0.4),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    )
                  : null,
            ),
            child: isAdd
                ? const Icon(Icons.add, color: AppColors.emerald)
                : Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildZeroInternetCard(
      BuildContext context, SettingsState state, SettingsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.signal_wifi_connected_no_internet_4,
                              color: AppColors.emerald, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Zero-Internet Mode',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Route critical location alerts via SMS automatically when cellular data is unavailable.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: state.zeroInternetMode,
                  onChanged: (_) => notifier.toggleZeroInternetMode(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderDark),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'Offline maps available: ${state.offlineMapsSize}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFakeCallConfig(
      BuildContext context, SettingsState state, SettingsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fake Call Configuration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caller name
                Text(
                  'CALLER DISPLAY NAME',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller:
                      TextEditingController(text: state.fakeCallName),
                  onChanged: notifier.setFakeCallName,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Boss, Mom, Uber Driver',
                    suffixIcon: Icon(Icons.edit, size: 18),
                  ),
                ),
                const SizedBox(height: 24),

                // Delay slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRIGGER DELAY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.5,
                          ),
                    ),
                    Text(
                      '${state.fakeCallDelay} seconds',
                      style: const TextStyle(
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: state.fakeCallDelay.toDouble(),
                  min: 5,
                  max: 300,
                  divisions: 59,
                  onChanged: (v) => notifier.setFakeCallDelay(v.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('5s',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text('1m',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text('2m',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text('5m',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 20),

                // Test button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => notifier.triggerTestFakeCall(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emeraldDim,
                      foregroundColor: AppColors.emerald,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text(
                      'Test Fake Call Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings(
      BuildContext context, SettingsState state, SettingsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _settingsRow(
            context,
            icon: Icons.vibration,
            title: 'Vibration Alerts',
            subtitle: 'Tactile feedback for silent triggers',
          ),
          _settingsRow(
            context,
            icon: Icons.map_outlined,
            title: 'Offline Area Management',
            subtitle: 'Download high-risk zones',
          ),
          _settingsRow(
            context,
            icon: Icons.lock_outline,
            title: 'App Lock Bypass',
            subtitle: 'Allow emergency features over lockscreen',
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
