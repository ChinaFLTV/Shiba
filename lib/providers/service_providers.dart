import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/data/repositories/conversation_repository.dart';
import 'package:shiba/data/repositories/model_repository.dart';
import 'package:shiba/data/services/download_service.dart';
import 'package:shiba/data/services/hf_api_service.dart';
import 'package:shiba/data/services/llm_service.dart';
import 'package:shiba/data/services/tts_service.dart';

final conversationRepoProvider = Provider((ref) => ConversationRepository());
final modelRepoProvider = Provider((ref) => ModelRepository());
final hfApiServiceProvider = Provider((ref) => HfApiService());
final downloadServiceProvider = Provider((ref) {
  final modelRepo = ref.watch(modelRepoProvider);
  return DownloadService(modelRepo);
});
final llmServiceProvider = Provider((ref) => LlmService());
final ttsServiceProvider = Provider((ref) => TtsService());
