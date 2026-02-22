import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final bool enabled;
  final bool isGenerating;
  final void Function(String text) onSend;
  final VoidCallback onStop;

  const ChatInputBar({
    super.key,
    required this.enabled,
    required this.isGenerating,
    required this.onSend,
    required this.onStop,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: widget.enabled ? '输入消息...' : '模型加载中...',
                  hintStyle: TextStyle(color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          widget.isGenerating
              ? IconButton.filled(
                  onPressed: widget.onStop,
                  icon: const Icon(Icons.stop, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                  ),
                )
              : IconButton.filled(
                  onPressed:
                      _hasText && widget.enabled ? _handleSend : null,
                  icon: const Icon(Icons.arrow_upward, size: 22),
                ),
        ],
      ),
    );
  }
}
