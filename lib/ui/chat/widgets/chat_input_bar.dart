import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiba/l10n/app_localizations.dart';

class ChatInputBar extends StatefulWidget {
  final bool enabled;
  final bool isGenerating;
  final bool visionEnabled;
  final String? pendingImagePath;
  final void Function(String text, {String? imagePath}) onSend;
  final VoidCallback onStop;
  final void Function(String? path) onImageChanged;
  final int? imageMaxResolution;
  final int? imageQuality;
  final bool imageCompressEnabled;

  const ChatInputBar({
    super.key,
    required this.enabled,
    required this.isGenerating,
    required this.onSend,
    required this.onStop,
    required this.onImageChanged,
    this.visionEnabled = false,
    this.pendingImagePath,
    this.imageMaxResolution,
    this.imageQuality,
    this.imageCompressEnabled = true,
  });

  @override
  State<ChatInputBar> createState() => ChatInputBarState();
}

class ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();
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

  /// Prefill the input bar with text and optional image for edit-and-resend.
  void prefill(String text, {String? imagePath}) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    if (imagePath != null) {
      widget.onImageChanged(imagePath);
    }
    _focusNode.requestFocus();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    final hasImage = widget.pendingImagePath != null;
    if (text.isEmpty && !hasImage) return;
    widget.onSend(text, imagePath: widget.pendingImagePath);
    _controller.clear();
    widget.onImageChanged(null);
    _focusNode.requestFocus();
  }

  Future<void> _pickImage() async {
    final compress = widget.imageCompressEnabled;
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth:
          compress ? (widget.imageMaxResolution ?? 1024).toDouble() : null,
      maxHeight:
          compress ? (widget.imageMaxResolution ?? 1024).toDouble() : null,
      imageQuality: compress ? (widget.imageQuality ?? 85) : null,
    );
    if (xFile != null) {
      widget.onImageChanged(xFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = widget.pendingImagePath != null;
    final canSend = (_hasText || hasImage) && widget.enabled;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image preview
          if (hasImage)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 80,
              alignment: Alignment.centerLeft,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.pendingImagePath!),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => widget.onImageChanged(null),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close,
                            size: 14, color: colorScheme.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Image picker button (only when vision is available)
              if (widget.visionEnabled)
                IconButton(
                  onPressed: widget.enabled && !widget.isGenerating
                      ? _pickImage
                      : null,
                  icon: Icon(Icons.image_outlined,
                      size: 22, color: hasImage ? colorScheme.primary : null),
                  tooltip: S.of(context).selectImage,
                ),
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
                      hintText: widget.enabled ? S.of(context).inputMessage : S.of(context).modelLoading,
                      hintStyle: TextStyle(
                          color: colorScheme.outline.withValues(alpha: 0.5)),
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
                      onPressed: canSend ? _handleSend : null,
                      icon: const Icon(Icons.arrow_upward, size: 22),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
