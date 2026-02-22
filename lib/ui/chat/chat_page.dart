import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/core/constants.dart';
import 'package:shiba/data/models/conversation.dart';
import 'package:shiba/data/models/local_model.dart';
import 'package:shiba/data/models/message.dart';
import 'package:shiba/data/services/tts_service.dart';
import 'package:shiba/providers/chat_providers.dart';
import 'package:shiba/providers/image_settings_provider.dart';
import 'package:shiba/providers/model_providers.dart';
import 'package:shiba/providers/service_providers.dart';
import 'package:shiba/providers/tts_providers.dart';
import 'package:shiba/ui/chat/widgets/chat_input_bar.dart';
import 'package:shiba/ui/chat/widgets/message_bubble.dart';
import 'package:shiba/ui/shared/tts_download_dialog.dart';

class ChatPage extends ConsumerStatefulWidget {
  final Conversation conversation;
  const ChatPage({super.key, required this.conversation});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ChatInputBarState> _inputBarKey = GlobalKey();
  bool _modelLoading = false;
  String? _loadError;
  String? _expandedMessageId;
  /// Message pending edit-and-resend (set when user taps edit, cleared on send).
  Message? _editPendingMessage;
  /// Cached reference to TtsService for use in dispose() where ref is unavailable.
  late final TtsService _ttsService;
  /// Cached notifier references for cleanup in dispose().
  late final StateController<String?> _ttsPlayingIdNotifier;
  late final StateController<TtsState> _ttsStateNotifier;
  /// True while speak() is in progress, suppresses auto-clearing of playing ID.
  bool _ttsSpeaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureModelLoaded();
      _setupTtsCallbacks();
    });
  }

  void _setupTtsCallbacks() {
    _ttsService = ref.read(ttsServiceProvider);
    _ttsPlayingIdNotifier = ref.read(ttsPlayingMessageIdProvider.notifier);
    _ttsStateNotifier = ref.read(ttsStateProvider.notifier);
    _ttsService.onStateChanged = (state) {
      if (mounted) {
        _ttsStateNotifier.state = state;
      }
    };
  }

  Future<void> _ensureModelLoaded() async {
    final llmService = ref.read(llmServiceProvider);
    final selectedModel = ref.read(selectedModelProvider);

    if (llmService.isLoaded) return;
    if (selectedModel == null) {
      setState(() => _loadError = '未选择模型');
      return;
    }

    setState(() {
      _modelLoading = true;
      _loadError = null;
    });

    // Verify file exists before loading
    final file = File(selectedModel.filePath);
    if (!await file.exists()) {
      if (mounted) {
        setState(() {
          _modelLoading = false;
          _loadError = '模型文件不存在，请重新下载\n路径: ${selectedModel.filePath}';
        });
      }
      return;
    }

    final (success, error) = await llmService.loadModel(selectedModel.filePath);

    if (mounted) {
      setState(() {
        _modelLoading = false;
        if (success) {
          _loadError = null;
          // Try to load vision projector if available
          _tryLoadVisionProjector(llmService, selectedModel.repoId);
        } else {
          _loadError = _buildLoadErrorMessage(error, selectedModel.filePath);
        }
      });
    }
  }

  /// Attempt to find and load a mmproj file for vision support.
  /// Searches downloaded models from the same repo for mmproj files.
  Future<void> _tryLoadVisionProjector(dynamic llmService, String repoId) async {
    final models = await ref.read(modelRepoProvider).getCompletedModels();
    final mmproj = models.where((m) =>
        m.repoId == repoId &&
        m.filename.toLowerCase().contains('mmproj') &&
        m.status == ModelStatus.completed).firstOrNull;
    if (mmproj != null) {
      final file = File(mmproj.filePath);
      if (await file.exists()) {
        await llmService.loadVisionProjector(mmproj.filePath);
        if (mounted) setState(() {}); // refresh UI to show image button
        return;
      }
    }
    // Show hint if model looks multimodal but mmproj is missing
    if (_looksMultimodal(repoId) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('该模型支持图片输入，但缺少视觉投影器(mmproj)文件，请在模型仓库中下载对应的 mmproj 文件'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 6),
        ),
      );
    }
  }

  /// Heuristic check if a repo likely contains a multimodal (vision) model.
  static bool _looksMultimodal(String repoId) {
    final lower = repoId.toLowerCase();
    return lower.contains('-vl') ||
        lower.contains('vision') ||
        lower.contains('multimodal') ||
        lower.contains('llava') ||
        lower.contains('minicpm-v');
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _ttsService.onStateChanged = null;
    _ttsService.stop();
    // Defer provider state reset to after the widget tree finalize phase,
    // as Riverpod forbids synchronous state modifications during dispose/unmount.
    Future.microtask(() {
      _ttsPlayingIdNotifier.state = null;
      _ttsStateNotifier.state = TtsState.idle;
    });
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider);
    final isGenerating = ref.watch(isGeneratingProvider);
    final streamingText = ref.watch(streamingTextProvider);
    final currentConv = ref.watch(currentConversationProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final displayTitle = currentConv?.title ?? widget.conversation.title;
    final displayModel = currentConv?.modelName ?? widget.conversation.modelName;

    // Auto-scroll when streaming
    ref.listen(streamingTextProvider, (_, __) => _scrollToBottom());

    // Clear playing message ID when TTS finishes naturally (state goes idle).
    // Suppressed during speak() calls to avoid clearing the ID mid-switch.
    ref.listen(ttsStateProvider, (prev, next) {
      if (next == TtsState.idle && !_ttsSpeaking && _ttsPlayingIdNotifier.state != null) {
        _ttsPlayingIdNotifier.state = null;
      }
    });

    // Show generation errors (e.g. native crash / CPU incompatibility)
    ref.listen(generationErrorProvider, (_, error) {
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, maxLines: 4, overflow: TextOverflow.ellipsis),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: '详情',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('推理错误'),
                    content: SingleChildScrollView(
                      child: SelectableText(error,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(displayTitle,
                style: const TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(displayModel,
                style: TextStyle(fontSize: 11, color: colorScheme.outline)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, size: 22),
            tooltip: '对话设置',
            onPressed: () => _showConversationSettings(context),
          ),
          if (_modelLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Error banner
          if (_loadError != null)
            MaterialBanner(
              content: GestureDetector(
                onLongPress: () {
                  // Long press to copy full error for sharing
                  final data = ClipboardData(text: _loadError!);
                  Clipboard.setData(data);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('错误信息已复制到剪贴板'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(_loadError!,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 20,
                    overflow: TextOverflow.ellipsis),
              ),
              backgroundColor: colorScheme.errorContainer,
              actions: [
                TextButton(
                  onPressed: _ensureModelLoaded,
                  child: const Text('重试'),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('错误详情'),
                        content: SingleChildScrollView(
                          child: SelectableText(
                            _loadError!,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _loadError!));
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('已复制'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Text('复制'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('关闭'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('详情'),
                ),
              ],
            ),

          // Messages list
          Expanded(
            child: messagesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (messages) {
                if (messages.isEmpty && !isGenerating) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  itemCount: messages.length + (isGenerating ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < messages.length) {
                      final msg = messages[index];
                      final ttsPlayingId = ref.watch(ttsPlayingMessageIdProvider);
                      return MessageBubble(
                        message: msg,
                        key: ValueKey(msg.id),
                        onEdit: msg.role == MessageRole.user && !isGenerating
                            ? () => _editAndResend(msg)
                            : null,
                        isTtsPlaying: ttsPlayingId == msg.id,
                        onTtsPlay: () => _handleTtsPlay(msg),
                        onTtsStop: () => _handleTtsStop(),
                        showActions: _expandedMessageId == msg.id,
                        onTap: () {
                          setState(() {
                            _expandedMessageId =
                                _expandedMessageId == msg.id ? null : msg.id;
                          });
                        },
                      );
                    }
                    // Streaming message
                    return MessageBubble(
                      message: Message(
                        id: 'streaming',
                        conversationId: '',
                        role: MessageRole.assistant,
                        content: streamingText.isEmpty
                            ? '...'
                            : streamingText,
                        createdAt: DateTime.now(),
                      ),
                      isStreaming: true,
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          ChatInputBar(
            key: _inputBarKey,
            enabled: !_modelLoading && _loadError == null,
            isGenerating: isGenerating,
            visionEnabled: ref.watch(llmServiceProvider).hasVision,
            pendingImagePath: ref.watch(pendingImageProvider),
            imageCompressEnabled: ref.watch(imageSettingsProvider).compressEnabled,
            imageMaxResolution: ref.watch(imageSettingsProvider).maxResolution,
            imageQuality: ref.watch(imageSettingsProvider).quality,
            onSend: (text, {String? imagePath}) => _handleSend(text, imagePath: imagePath),
            onStop: () {
              ref.read(chatControllerProvider).stopGeneration();
            },
            onImageChanged: (path) {
              ref.read(pendingImageProvider.notifier).state = path;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleTtsPlay(Message message) async {
    // Check if model is downloaded
    final isReady = await _ttsService.isModelDownloaded();
    if (!isReady) {
      // Show download confirmation dialog
      if (!mounted) return;
      final shouldDownload = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('下载语音模型'),
          content: const Text(
            'TTS语音模型尚未下载（约182MB）。\n是否现在下载？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('下载'),
            ),
          ],
        ),
      );

      if (shouldDownload != true || !mounted) return;

      // Show download progress dialog
      _showTtsDownloadDialog();
      return;
    }

    // Model ready — speak
    _ttsPlayingIdNotifier.state = message.id;
    _ttsSpeaking = true;
    final ttsSettings = ref.read(ttsSettingsProvider);
    final ok = await _ttsService.speak(
      message.content,
      speed: ttsSettings.speed,
    );
    _ttsSpeaking = false;
    if (!ok && mounted) {
      _ttsPlayingIdNotifier.state = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('朗读失败，请重试'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleTtsStop() async {
    await _ttsService.stop();
    _ttsPlayingIdNotifier.state = null;
  }

  void _showTtsDownloadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TtsDownloadDialog(ttsService: _ttsService),
    );
  }

  void _showConversationSettings(BuildContext context) {
    final convId = ref.read(currentConversationIdProvider);
    if (convId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ConversationSettingsSheet(
        conversationId: convId,
      ),
    );
  }

  Future<void> _editAndResend(Message message) async {
    setState(() => _editPendingMessage = message);
    _inputBarKey.currentState?.prefill(
      message.content,
      imagePath: message.imagePath,
    );
  }

  /// Called when the user sends from the input bar while an edit is pending.
  void _handleSend(String text, {String? imagePath}) {
    if (_editPendingMessage != null) {
      final pending = _editPendingMessage!;
      setState(() => _editPendingMessage = null);
      ref.read(messagesProvider.notifier).deleteMessagesFrom(pending).then((_) {
        ref.read(chatControllerProvider).sendMessage(text, imagePath: imagePath);
        _scrollToBottom();
      });
    } else {
      ref.read(chatControllerProvider).sendMessage(text, imagePath: imagePath);
      _scrollToBottom();
    }
  }

  String _buildLoadErrorMessage(String? error, String filePath) {
    if (error == null) return '模型加载失败（未知错误）';

    // These are pre-flight check errors with clear messages — show as-is
    if (error.contains('非GGUF') ||
        error.contains('not appear to be GGUF') ||
        error.contains('模型文件为空') ||
        error.contains('模型文件不存在') ||
        error.contains('GGUF版本过低') ||
        error.contains('tensor数量为0')) {
      return error;
    }

    // Multi-stage diagnostics from LlmService — show full detail
    // The error already contains structured stage-by-stage info
    return '模型加载失败\n\n$error';
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined,
                size: 64, color: colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('开始对话',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: colorScheme.primary)),
            const SizedBox(height: 8),
            Text('输入你的问题，与Shiba对话',
                style: TextStyle(color: colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}

class _ConversationSettingsSheet extends ConsumerStatefulWidget {
  final String conversationId;
  const _ConversationSettingsSheet({required this.conversationId});

  @override
  ConsumerState<_ConversationSettingsSheet> createState() =>
      _ConversationSettingsSheetState();
}

class _ConversationSettingsSheetState
    extends ConsumerState<_ConversationSettingsSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _systemPromptCtrl;
  late double _temperature;
  late int _topK;
  late double _topP;
  late int _maxTokens;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _systemPromptCtrl = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final conv = await ref
        .read(conversationRepoProvider)
        .getConversation(widget.conversationId);
    if (conv != null && mounted) {
      setState(() {
        _titleCtrl.text = conv.title;
        _systemPromptCtrl.text = conv.systemPrompt;
        _temperature = conv.temperature;
        _topK = conv.topK;
        _topP = conv.topP;
        _maxTokens = conv.maxTokens;
        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    final conv = await ref
        .read(conversationRepoProvider)
        .getConversation(widget.conversationId);
    if (conv == null) return;
    final updated = conv.copyWith(
      title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : conv.title,
      systemPrompt: _systemPromptCtrl.text.trim(),
      temperature: _temperature,
      topK: _topK,
      topP: _topP,
      maxTokens: _maxTokens,
      updatedAt: DateTime.now(),
    );
    await ref.read(conversationsProvider.notifier).updateConversation(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _systemPromptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('对话设置', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleCtrl,
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: '对话标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // System prompt
            TextField(
              controller: _systemPromptCtrl,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: '系统提示词',
                hintText: '例如：你是一个专业的翻译助手',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Temperature
            _buildSliderRow(
              label: 'Temperature',
              value: _temperature,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              display: _temperature.toStringAsFixed(1),
              onChanged: (v) => setState(() => _temperature = v),
            ),

            // Top K
            _buildSliderRow(
              label: 'Top K',
              value: _topK.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              display: '$_topK',
              onChanged: (v) => setState(() => _topK = v.round()),
            ),

            // Top P
            _buildSliderRow(
              label: 'Top P',
              value: _topP,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              display: _topP.toStringAsFixed(2),
              onChanged: (v) => setState(() => _topP = v),
            ),

            // Max Tokens
            _buildSliderRow(
              label: '最大生成长度',
              value: _maxTokens.toDouble(),
              min: 64,
              max: 4096,
              divisions: 63,
              display: '$_maxTokens',
              onChanged: (v) => setState(() => _maxTokens = v.round()),
            ),

            const SizedBox(height: 8),

            // Reset defaults
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _temperature = AppConstants.defaultTemperature;
                    _topK = AppConstants.defaultTopK;
                    _topP = AppConstants.defaultTopP;
                    _maxTokens = AppConstants.defaultMaxTokens;
                    _systemPromptCtrl.clear();
                  });
                },
                icon: Icon(Icons.restore, size: 18, color: colorScheme.outline),
                label: Text('恢复默认',
                    style: TextStyle(fontSize: 13, color: colorScheme.outline)),
              ),
            ),

            const SizedBox(height: 8),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String display,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(display,
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
