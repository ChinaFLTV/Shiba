import 'package:shiba/core/constants.dart';

class Conversation {
  final String id;
  final String title;
  final String modelId;
  final String modelName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String systemPrompt;
  final double temperature;
  final int topK;
  final double topP;
  final int maxTokens;
  final int historyRounds;

  const Conversation({
    required this.id,
    required this.title,
    required this.modelId,
    required this.modelName,
    required this.createdAt,
    required this.updatedAt,
    this.systemPrompt = '',
    this.temperature = AppConstants.defaultTemperature,
    this.topK = AppConstants.defaultTopK,
    this.topP = AppConstants.defaultTopP,
    this.maxTokens = AppConstants.defaultMaxTokens,
    this.historyRounds = AppConstants.defaultHistoryRounds,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'model_id': modelId,
        'model_name': modelName,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'system_prompt': systemPrompt,
        'temperature': temperature,
        'top_k': topK,
        'top_p': topP,
        'max_tokens': maxTokens,
        'history_rounds': historyRounds,
      };

  factory Conversation.fromMap(Map<String, dynamic> map) => Conversation(
        id: map['id'] as String,
        title: map['title'] as String,
        modelId: map['model_id'] as String,
        modelName: map['model_name'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
        systemPrompt: map['system_prompt'] as String? ?? '',
        temperature: (map['temperature'] as num?)?.toDouble() ??
            AppConstants.defaultTemperature,
        topK: map['top_k'] as int? ?? AppConstants.defaultTopK,
        topP: (map['top_p'] as num?)?.toDouble() ?? AppConstants.defaultTopP,
        maxTokens: map['max_tokens'] as int? ?? AppConstants.defaultMaxTokens,
        historyRounds:
            map['history_rounds'] as int? ?? AppConstants.defaultHistoryRounds,
      );

  Conversation copyWith({
    String? title,
    DateTime? updatedAt,
    String? systemPrompt,
    double? temperature,
    int? topK,
    double? topP,
    int? maxTokens,
    int? historyRounds,
  }) =>
      Conversation(
        id: id,
        title: title ?? this.title,
        modelId: modelId,
        modelName: modelName,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        systemPrompt: systemPrompt ?? this.systemPrompt,
        temperature: temperature ?? this.temperature,
        topK: topK ?? this.topK,
        topP: topP ?? this.topP,
        maxTokens: maxTokens ?? this.maxTokens,
        historyRounds: historyRounds ?? this.historyRounds,
      );
}
