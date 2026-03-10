import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/audio_listener_provider.dart';
import '../../../models/trigger_word.dart';
import '../../widgets/common/section_header.dart';

class AudioListenerScreen extends ConsumerWidget {
  const AudioListenerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioListenerProvider);
    final notifier = ref.read(audioListenerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.waves, color: AppColors.electricBlue, size: 24),
            const SizedBox(width: 12),
            Text(
              'Edge AI Audio Listener',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildWaveformDisplay(context, state),
              const SizedBox(height: 32),
              _buildTriggerWords(context, state, notifier),
              const SizedBox(height: 32),
              _buildSensitivitySlider(context, state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveformDisplay(BuildContext context, AudioListenerState state) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.slate900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.electricBlue.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withValues(alpha: 0.1),
                blurRadius: 12,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Grid dots background
              CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _GridDotsPainter(),
              ),
              // Waveform
              CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _WaveformPainter(isActive: state.isListening),
              ),
              // Live signal indicator
              Positioned(
                bottom: 12,
                left: 16,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: state.isListening
                            ? AppColors.electricBlue
                            : AppColors.textDisabled,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.isListening ? 'LIVE SIGNAL' : 'PAUSED',
                      style: TextStyle(
                        color: state.isListening
                            ? AppColors.electricBlue
                            : AppColors.textDisabled,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          state.isListening
              ? 'Analyzing Ambient Sound...'
              : 'Listener Paused',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          state.isProcessingLocally
              ? 'Real-time local processing active'
              : 'Connecting to cloud...',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTriggerWords(
      BuildContext context, AudioListenerState state, AudioListenerNotifier notifier) {
    final activeCount = state.triggerWords.where((w) => w.isActive).length;

    return Column(
      children: [
        SectionHeader(
          title: 'Trigger Words',
          actionLabel: '$activeCount Active',
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: state.triggerWords.length,
          itemBuilder: (context, index) {
            final word = state.triggerWords[index];
            return _triggerWordCard(context, word, notifier);
          },
        ),
      ],
    );
  }

  Widget _triggerWordCard(
      BuildContext context, TriggerWord word, AudioListenerNotifier notifier) {
    final isActive = word.isActive;

    return GestureDetector(
      onTap: () => notifier.toggleTriggerWord(word.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.electricBlue : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.electricBlue : AppColors.borderDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word.language,
              style: TextStyle(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              word.word,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensitivitySlider(
      BuildContext context, AudioListenerState state, AudioListenerNotifier notifier) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.mic, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 8),
            Text(
              'MICROPHONE SENSITIVITY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Slider(
          value: state.sensitivity,
          min: 0,
          max: 1,
          onChanged: (v) => notifier.setSensitivity(v),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  'Library, Home',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                      ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Crowded Street',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  'Subway, Traffic',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _GridDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.electricBlue.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaveformPainter extends CustomPainter {
  final bool isActive;
  _WaveformPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final paint = Paint()
      ..color = AppColors.electricBlue
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final midY = size.height / 2;
    final random = Random(42);

    path.moveTo(0, midY);
    for (double x = 0; x < size.width; x += 4) {
      final amplitude = random.nextDouble() * 30 + 5;
      final y = midY + sin(x * 0.05) * amplitude;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Secondary waveform (dimmer)
    final paint2 = Paint()
      ..color = AppColors.electricBlue.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path2 = Path();
    path2.moveTo(0, midY);
    for (double x = 0; x < size.width; x += 4) {
      final amplitude = random.nextDouble() * 20 + 3;
      final y = midY + cos(x * 0.03) * amplitude;
      path2.lineTo(x, y);
    }

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
