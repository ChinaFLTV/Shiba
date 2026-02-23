import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiba/data/services/stt_service.dart';
import 'package:shiba/l10n/app_localizations.dart';
import 'package:shiba/ui/shared/stt_download_dialog.dart';

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
  final SttService? sttService;

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
    this.sttService,
  });

  @override
  State<ChatInputBar> createState() => ChatInputBarState();
}

class ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();
  bool _hasText = false;

  // STT state
  bool _isListening = false;
  bool _isRecognizing = false;

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
    widget.sttService?.stopListening();
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
      maxWidth: compress ? (widget.imageMaxResolution ?? 1024).toDouble() : null,
      maxHeight: compress ? (widget.imageMaxResolution ?? 1024).toDouble() : null,
      imageQuality: compress ? (widget.imageQuality ?? 85) : null,
    );
    if (xFile != null) {
      widget.onImageChanged(xFile.path);
    }
  }

  // ---- STT methods ----

  Future<void> _toggleListening() async {
    final stt = widget.sttService;
    if (stt == null) return;

    // If currently listening, stop and recognize
    if (_isListening) {
      setState(() { _isListening = false; _isRecognizing = true; });
      final text = await stt.stopAndRecognize();
      if (mounted) {
        setState(() => _isRecognizing = false);
        if (text.isNotEmpty) {
          final current = _controller.text;
          final separator = current.isNotEmpty && !current.endsWith(' ') ? ' ' : '';
          _controller.text = '$current$separator$text';
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      }
      return;
    }

    // Check if model is downloaded
    final isReady = await stt.isModelDownloaded();
    if (!isReady) {
      if (!mounted) return;
      final shouldDownload = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(S.of(context).sttDownloadTitle),
          content: Text(S.of(context).sttDownloadPrompt),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(S.of(context).cancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(S.of(context).download)),
          ],
        ),
      );
      if (shouldDownload != true || !mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => SttDownloadDialog(sttService: stt),
      );
      return;
    }

    // Start listening
    final ok = await stt.startListening();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).sttMicPermissionDenied),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (mounted) setState(() => _isListening = true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = widget.pendingImagePath != null;
    final canSend = (_hasText || hasImage) && widget.enabled;
    final sttBusy = _isListening || _isRecognizing;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
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
                    child: Image.file(File(widget.pendingImagePath!), height: 80, width: 80, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2, right: 2,
                    child: GestureDetector(
                      onTap: () => widget.onImageChanged(null),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: colorScheme.surface.withValues(alpha: 0.8), shape: BoxShape.circle),
                        child: Icon(Icons.close, size: 14, color: colorScheme.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Listening / Recognizing indicator
          if (sttBusy)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _isListening ? colorScheme.error : colorScheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isListening ? S.of(context).sttListening : S.of(context).sttRecognizing,
                    style: TextStyle(fontSize: 12, color: _isListening ? colorScheme.error : colorScheme.primary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

          // Input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.visionEnabled)
                IconButton(
                  onPressed: widget.enabled && !widget.isGenerating ? _pickImage : null,
                  icon: Icon(Icons.image_outlined, size: 22, color: hasImage ? colorScheme.primary : null),
                  tooltip: S.of(context).selectImage,
                ),
              // Microphone button
              if (widget.sttService != null)
                IconButton(
                  onPressed: widget.enabled && !widget.isGenerating && !_isRecognizing ? _toggleListening : null,
                  icon: Icon(
                    _isListening ? Icons.stop_circle : (_isRecognizing ? Icons.hourglass_top : Icons.mic_none),
                    size: 22,
                    color: _isListening ? colorScheme.error : null,
                  ),
                  tooltip: S.of(context).sttTooltip,
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
                      style: IconButton.styleFrom(backgroundColor: colorScheme.errorContainer, foregroundColor: colorScheme.onErrorContainer),
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
