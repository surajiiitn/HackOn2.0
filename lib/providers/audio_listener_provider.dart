import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trigger_word.dart';
import '../core/services/api_service.dart';

class AudioListenerState {
  final bool isListening;
  final double sensitivity;
  final List<TriggerWord> triggerWords;
  final String? detectedWord;
  final bool isProcessingLocally;

  const AudioListenerState({
    this.isListening = true,
    this.sensitivity = 0.65,
    this.triggerWords = const [],
    this.detectedWord,
    this.isProcessingLocally = true,
  });

  AudioListenerState copyWith({
    bool? isListening,
    double? sensitivity,
    List<TriggerWord>? triggerWords,
    String? detectedWord,
    bool? isProcessingLocally,
  }) {
    return AudioListenerState(
      isListening: isListening ?? this.isListening,
      sensitivity: sensitivity ?? this.sensitivity,
      triggerWords: triggerWords ?? this.triggerWords,
      detectedWord: detectedWord,
      isProcessingLocally: isProcessingLocally ?? this.isProcessingLocally,
    );
  }
}

class AudioListenerNotifier extends StateNotifier<AudioListenerState> {
  AudioListenerNotifier()
      : super(AudioListenerState(
          triggerWords: const [
            TriggerWord(
                id: '1', word: 'Help', language: 'English', isActive: true),
            TriggerWord(
                id: '2', word: 'Bachao', language: 'Hindi', isActive: true),
            TriggerWord(
                id: '3', word: 'Kaapaatru', language: 'Tamil', isActive: true),
            TriggerWord(
                id: '4', word: 'Banchao', language: 'Bengali', isActive: true),
          ],
        ));

  void toggleListening() {
    state = state.copyWith(isListening: !state.isListening);
  }

  void setSensitivity(double value) {
    state = state.copyWith(sensitivity: value);
  }

  void toggleTriggerWord(String id) {
    final words = state.triggerWords.map((w) {
      if (w.id == id) return w.copyWith(isActive: !w.isActive);
      return w;
    }).toList();
    state = state.copyWith(triggerWords: words);
  }

  Future<void> onWordDetected(String word) async {
    state = state.copyWith(detectedWord: word);
    try {
      await ApiService.triggerSos(
        latitude: 19.0760,
        longitude: 72.8777,
        triggerType: 'scream_detection',
      );
    } catch (_) {
      // Keep detection state even if API call fails (offline-first)
    }
  }

  void clearDetection() {
    state = state.copyWith(detectedWord: null);
  }
}

final audioListenerProvider =
    StateNotifierProvider<AudioListenerNotifier, AudioListenerState>((ref) {
  return AudioListenerNotifier();
});
