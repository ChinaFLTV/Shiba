import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:local_model/data/models/conversation.dart';
import 'package:local_model/data/models/message.dart';
import 'package:local_model/core/constants.dart';
import 'package:local_model/providers/service_providers.dart';
import 'package:local_model/providers/model_providers.dart';

const _uuid = Uuid();

/// All conversations
final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(
        ConversationsNotifier.new);

class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() async {
    return ref.read(conversationRepoProvider).getAllConversations();
  }

  Future<void> refresh() async {
    state = AsyncData(
        await ref.read(conversationRepoProvider).getAllConversations());
  }

  Future<Conversation> createConversation(
      String modelId, String modelName) async {
    final now = DateTime.now();
    final conversation = Conversation(
      id: _uuid.v4(),
      title: '新对话',
      modelId: modelId,
      modelName: modelName,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(conversationRepoProvider).insertConversation(conversation);
    await refresh();
    return conversation;
  }

  Future<void> updateTitle(String id, String title, {bool updateTime = true}) async {
    final repo = ref.read(conversationRepoProvider);
    final conv = await repo.getConversation(id);
    if (conv != null) {
      await repo.updateConversation(conv.copyWith(
        title: title,
        updatedAt: updateTime ? DateTime.now() : conv.updatedAt,
      ));
      await refresh();
    }
  }

  Future<void> updateConversation(Conversation conv) async {
    await ref.read(conversationRepoProvider).updateConversation(conv);
    await refresh();
  }

  Future<void> deleteConversation(String id) async {
    await ref.read(conversationRepoProvider).deleteConversation(id);
    await refresh();
  }
}

/// Current conversation ID
final currentConversationIdProvider = StateProvider<String?>((ref) => null);

/// Current conversation object (reactive — updates when title/settings change)
final currentConversationProvider = Provider<Conversation?>((ref) {
  final convId = ref.watch(currentConversationIdProvider);
  if (convId == null) return null;
  final conversations = ref.watch(conversationsProvider).valueOrNull ?? [];
  return conversations.where((c) => c.id == convId).firstOrNull;
});

/// Messages for current conversation
final messagesProvider =
    AsyncNotifierProvider<MessagesNotifier, List<Message>>(
        MessagesNotifier.new);

class MessagesNotifier extends AsyncNotifier<List<Message>> {
  @override
  Future<List<Message>> build() async {
    final convId = ref.watch(currentConversationIdProvider);
    if (convId == null) return [];
    return ref.read(conversationRepoProvider).getMessages(convId);
  }

  Future<void> refresh() async {
    final convId = ref.read(currentConversationIdProvider);
    if (convId == null) {
      state = const AsyncData([]);
      return;
    }
    state = AsyncData(
        await ref.read(conversationRepoProvider).getMessages(convId));
  }

  Future<Message> addUserMessage(String content) async {
    final convId = ref.read(currentConversationIdProvider);
    if (convId == null) throw Exception('No conversation selected');
    final message = Message(
      id: _uuid.v4(),
      conversationId: convId,
      role: MessageRole.user,
      content: content,
      createdAt: DateTime.now(),
    );
    await ref.read(conversationRepoProvider).insertMessage(message);
    await refresh();
    return message;
  }

  Future<Message> addAssistantMessage(String content) async {
    final convId = ref.read(currentConversationIdProvider);
    if (convId == null) throw Exception('No conversation selected');
    final message = Message(
      id: _uuid.v4(),
      conversationId: convId,
      role: MessageRole.assistant,
      content: content,
      createdAt: DateTime.now(),
    );
    await ref.read(conversationRepoProvider).insertMessage(message);
    return message;
  }

  Future<void> updateMessage(Message message) async {
    await ref.read(conversationRepoProvider).updateMessage(message);
    await refresh();
  }

  /// Delete a message and all subsequent messages in the conversation.
  Future<void> deleteMessagesFrom(Message message) async {
    await ref.read(conversationRepoProvider).deleteMessagesFrom(
      message.conversationId,
      message.createdAt,
    );
    await refresh();
  }
}

/// Whether the AI is currently generating a response
final isGeneratingProvider = StateProvider<bool>((ref) => false);

/// Streaming response text (accumulated)
final streamingTextProvider = StateProvider<String>((ref) => '');

/// Chat controller for managing generation
final chatControllerProvider = Provider((ref) => ChatController(ref));

class ChatController {
  final Ref _ref;
  StreamSubscription<String>? _subscription;
  final StringBuffer _buffer = StringBuffer();

  ChatController(this._ref);

  Future<void> sendMessage(String content) async {
    final llmService = _ref.read(llmServiceProvider);
    final selectedModel = _ref.read(selectedModelProvider);

    if (!llmService.isLoaded || selectedModel == null) return;
    if (content.trim().isEmpty) return;

    _ref.read(isGeneratingProvider.notifier).state = true;
    _ref.read(streamingTextProvider.notifier).state = '';
    _buffer.clear();

    // Add user message
    await _ref.read(messagesProvider.notifier).addUserMessage(content);

    // Read conversation-level settings
    final convId = _ref.read(currentConversationIdProvider)!;
    final conv =
        await _ref.read(conversationRepoProvider).getConversation(convId);

    // Get all messages for context
    final messages =
        await _ref.read(conversationRepoProvider).getMessages(convId);

    // Start streaming generation with per-conversation params
    final stream = llmService.generateStream(
      messages,
      temperature: conv?.temperature ?? AppConstants.defaultTemperature,
      maxTokens: conv?.maxTokens ?? AppConstants.defaultMaxTokens,
      topP: conv?.topP ?? AppConstants.defaultTopP,
      topK: conv?.topK ?? AppConstants.defaultTopK,
      systemPrompt: conv?.systemPrompt ?? '',
    );

    _subscription = stream.listen(
      (token) {
        _buffer.write(token);
        _ref.read(streamingTextProvider.notifier).state = _buffer.toString();
      },
      onDone: () async {
        final finalText = _buffer.toString();
        if (finalText.isNotEmpty) {
          final msg = await _ref
              .read(messagesProvider.notifier)
              .addAssistantMessage(finalText);
          // Auto-generate title from first exchange
          await _autoGenerateTitle(content, msg);
        }
        _ref.read(isGeneratingProvider.notifier).state = false;
        _ref.read(streamingTextProvider.notifier).state = '';
        _buffer.clear();
        await _ref.read(messagesProvider.notifier).refresh();
      },
      onError: (error) {
        _ref.read(isGeneratingProvider.notifier).state = false;
        _ref.read(streamingTextProvider.notifier).state = '';
        _buffer.clear();
      },
    );
  }

  Future<void> _autoGenerateTitle(String userMsg, Message assistantMsg) async {
    final convId = _ref.read(currentConversationIdProvider);
    if (convId == null) return;
    final conv =
        await _ref.read(conversationRepoProvider).getConversation(convId);
    if (conv == null || conv.title != '新对话') return;

    // Try to generate a summary title using the model (background, best-effort)
    final llmService = _ref.read(llmServiceProvider);
    if (llmService.isLoaded) {
      try {
        final prompt =
            '<|im_start|>system\n你是标题生成助手。根据用户的问题，生成一个简短的对话标题，不超过15个字，只输出标题本身。<|im_end|>\n'
            '<|im_start|>user\n$userMsg<|im_end|>\n'
            '<|im_start|>assistant\n';
        final title = await llmService.generateOnce(prompt, maxTokens: 32);
        if (title.isNotEmpty && title.length <= 30) {
          await _ref
              .read(conversationsProvider.notifier)
              .updateTitle(convId, title, updateTime: false);
          return;
        }
      } catch (e) {
        debugPrint('[Chat] Title generation failed: $e');
      }
    }

    // Fallback: truncate user message as title
    final fallback =
        userMsg.length > 20 ? '${userMsg.substring(0, 20)}...' : userMsg;
    await _ref
        .read(conversationsProvider.notifier)
        .updateTitle(convId, fallback, updateTime: false);
  }

  void stopGeneration() {
    _ref.read(llmServiceProvider).stopGeneration();
    _subscription?.cancel();
    _subscription = null;

    // Save partial response if any content was generated
    final partialText = _buffer.toString();
    if (partialText.isNotEmpty) {
      _ref.read(messagesProvider.notifier).addAssistantMessage(partialText).then(
        (_) => _ref.read(messagesProvider.notifier).refresh(),
      );
    }

    _ref.read(isGeneratingProvider.notifier).state = false;
    _ref.read(streamingTextProvider.notifier).state = '';
    _buffer.clear();
  }
}
