import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/core/constants.dart';
import 'package:shiba/data/database/database_helper.dart';
import 'package:shiba/data/services/tts_service.dart';
import 'package:shiba/providers/service_providers.dart';

/// Current TTS playback state
final ttsStateProvider = StateProvider<TtsState>((ref) => TtsState.idle);

/// ID of the message currently being read aloud (null if none)
final ttsPlayingMessageIdProvider = StateProvider<String?>((ref) => null);

/// Whether the TTS model has been downloaded
final ttsModelReadyProvider = FutureProvider<bool>((ref) async {
  return ref.read(ttsServiceProvider).isModelDownloaded();
});

/// TTS model download progress: (received, total)
final ttsDownloadProgressProvider =
    StateProvider<(int, int)>((ref) => (0, 0));

/// Persisted TTS settings (speed only — current MeloTTS zh-en model has 1 speaker)
final ttsSettingsProvider =
    StateNotifierProvider<TtsSettingsNotifier, TtsSettings>(
        (ref) => TtsSettingsNotifier());

class TtsSettings {
  final double speed;
  const TtsSettings({this.speed = AppConstants.defaultTtsSpeed});
}

const _ttsSpeedKey = 'tts_speed';

class TtsSettingsNotifier extends StateNotifier<TtsSettings> {
  TtsSettingsNotifier() : super(const TtsSettings()) {
    _load();
  }

  Future<void> _load() async {
    final spd = await DatabaseHelper.instance.getSetting(_ttsSpeedKey);
    state = TtsSettings(
      speed: spd != null ? double.tryParse(spd) ?? AppConstants.defaultTtsSpeed : AppConstants.defaultTtsSpeed,
    );
  }

  Future<void> setSpeed(double speed) async {
    state = TtsSettings(speed: speed);
    await DatabaseHelper.instance.setSetting(_ttsSpeedKey, speed.toString());
  }
}
