import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shiba/data/models/message.dart';
import 'package:shiba/ui/chat/widgets/image_preview_page.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isStreaming;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTtsPlay;
  final VoidCallback? onTtsStop;
  final bool isTtsPlaying;
  final bool showActions;
  final VoidCallback? onTap;
  final bool selectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectionChanged;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.onEdit,
    this.onDelete,
    this.onTtsPlay,
    this.onTtsStop,
    this.isTtsPlaying = false,
    this.showActions = false,
    this.onTap,
    this.selectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Selection checkbox
          if (selectionMode)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onSelectionChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          if (!isUser && !selectionMode) _buildAvatar(context, isUser),
          if (!isUser && !selectionMode) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Bubble
                GestureDetector(
                  onTap: isStreaming ? null : onTap,
                  onLongPress: isStreaming ? null : onLongPress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image attachment
                        if (message.hasImage)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImagePreviewPage(
                                      imagePath: message.imagePath!,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(message.imagePath!),
                                  width: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 200,
                                    height: 100,
                                    color: colorScheme.surfaceContainerHighest,
                                    child: const Center(
                                      child: Icon(Icons.broken_image_outlined),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (isUser)
                          Text(
                            message.content,
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontSize: 15,
                            ),
                          )
                        else
                          _buildMarkdownContent(context),
                        if (isStreaming)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Action buttons (shown on tap)
                if (showActions && !isStreaming)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionBtn(
                          icon: Icons.copy_outlined,
                          tooltip: '复制',
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: message.content));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('已复制到剪贴板'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        if (isUser && onEdit != null)
                          _ActionBtn(
                            icon: Icons.edit_outlined,
                            tooltip: '编辑并重发',
                            onTap: onEdit!,
                          ),
                        if (onDelete != null)
                          _ActionBtn(
                            icon: Icons.delete_outline,
                            tooltip: '删除',
                            onTap: onDelete!,
                          ),
                        // TTS read-aloud button (for assistant messages)
                        if (!isUser)
                          isTtsPlaying
                              ? _ActionBtn(
                                  icon: Icons.stop_circle_outlined,
                                  tooltip: '停止朗读',
                                  onTap: onTtsStop ?? () {},
                                )
                              : _ActionBtn(
                                  icon: Icons.volume_up_outlined,
                                  tooltip: '朗读',
                                  onTap: onTtsPlay ?? () {},
                                ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isUser && !selectionMode) const SizedBox(width: 8),
          if (isUser && !selectionMode) _buildAvatar(context, isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          isUser ? colorScheme.primary : colorScheme.tertiaryContainer,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 18,
        color: isUser
            ? colorScheme.onPrimary
            : colorScheme.onTertiaryContainer,
      ),
    );
  }

  Widget _buildMarkdownContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GptMarkdown(
      message.content,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 15,
        height: 1.5,
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 28,
      child: IconButton(
        icon: Icon(icon, size: 15),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        color: Theme.of(context).colorScheme.outline,
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}
