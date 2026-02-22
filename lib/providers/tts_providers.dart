import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_model/data/services/tts_service.dart';
import 'package:local_model/providers/service_providers.dart';

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
