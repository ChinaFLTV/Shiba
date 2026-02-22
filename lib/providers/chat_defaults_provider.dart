import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/core/constants.dart';
import 'package:shiba/data/database/database_helper.dart';

const _kChatDefaultSystemPrompt = 'chat_default_system_prompt';
const _kChatDefaultTemperature = 'chat_default_temperature';
const _kChatDefaultTopK = 'chat_default_top_k';
const _kChatDefaultTopP = 'chat_default_top_p';
const _kChatDefaultMaxTokens = 'chat_default_max_tokens';
const _kChatDefaultHistoryRounds = 'chat_default_history_rounds';

class ChatDefaults {
  final String systemPrompt;
  final double temperature;
  final int topK;
  final double topP;
  final int maxTokens;
  final int historyRounds;

  const ChatDefaults({
    this.systemPrompt = '',
    this.temperature = AppConstants.defaultTemperature,
    this.topK = AppConstants.defaultTopK,
    this.topP = AppConstants.defaultTopP,
    this.maxTokens = AppConstants.defaultMaxTokens,
    this.historyRounds = AppConstants.defaultHistoryRounds,
  });

  ChatDefaults copyWith({
    String? systemPrompt,
    double? temperature,
    int? topK,
    double? topP,
    int? maxTokens,
    int? historyRounds,
  }) {
    return ChatDefaults(
      systemPrompt: systemPrompt ?? this.systemPrompt,
      temperature: temperature ?? this.temperature,
      topK: topK ?? this.topK,
      topP: topP ?? this.topP,
      maxTokens: maxTokens ?? this.maxTokens,
      historyRounds: historyRounds ?? this.historyRounds,
    );
  }
}

final chatDefaultsProvider =
    StateNotifierProvider<ChatDefaultsNotifier, ChatDefaults>(
        (ref) => ChatDefaultsNotifier());

class ChatDefaultsNotifier extends StateNotifier<ChatDefaults> {
  ChatDefaultsNotifier() : super(const ChatDefaults()) {
    _load();
  }

  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    final systemPrompt = await db.getSetting(_kChatDefaultSystemPrompt);
    final temperature = await db.getSetting(_kChatDefaultTemperature);
    final topK = await db.getSetting(_kChatDefaultTopK);
    final topP = await db.getSetting(_kChatDefaultTopP);
    final maxTokens = await db.getSetting(_kChatDefaultMaxTokens);
    final historyRounds = await db.getSetting(_kChatDefaultHistoryRounds);

    state = ChatDefaults(
      systemPrompt: systemPrompt ?? '',
      temperature: temperature != null
          ? double.tryParse(temperature) ?? AppConstants.defaultTemperature
          : AppConstants.defaultTemperature,
      topK: topK != null
          ? int.tryParse(topK) ?? AppConstants.defaultTopK
          : AppConstants.defaultTopK,
      topP: topP != null
          ? double.tryParse(topP) ?? AppConstants.defaultTopP
          : AppConstants.defaultTopP,
      maxTokens: maxTokens != null
          ? int.tryParse(maxTokens) ?? AppConstants.defaultMaxTokens
          : AppConstants.defaultMaxTokens,
      historyRounds: historyRounds != null
          ? int.tryParse(historyRounds) ?? AppConstants.defaultHistoryRounds
          : AppConstants.defaultHistoryRounds,
    );
  }

  Future<void> save(ChatDefaults next) async {
    state = next;
    final db = DatabaseHelper.instance;
    await db.setSetting(_kChatDefaultSystemPrompt, next.systemPrompt);
    await db.setSetting(_kChatDefaultTemperature, next.temperature.toString());
    await db.setSetting(_kChatDefaultTopK, next.topK.toString());
    await db.setSetting(_kChatDefaultTopP, next.topP.toString());
    await db.setSetting(_kChatDefaultMaxTokens, next.maxTokens.toString());
    await db.setSetting(
        _kChatDefaultHistoryRounds, next.historyRounds.toString());
  }

  Future<void> reset() async {
    await save(const ChatDefaults());
  }
}
