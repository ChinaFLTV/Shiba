import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/data/services/stt_service.dart';
import 'package:shiba/providers/service_providers.dart';

/// Current STT state
final sttStateProvider = StateProvider<SttState>((ref) => SttState.idle);

/// Whether the STT model has been downloaded
final sttModelReadyProvider = FutureProvider<bool>((ref) async {
  return ref.read(sttServiceProvider).isModelDownloaded();
});

/// STT model download progress: (received, total)
final sttDownloadProgressProvider = StateProvider<(int, int)>((ref) => (0, 0));
