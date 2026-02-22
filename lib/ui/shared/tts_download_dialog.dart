import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shiba/core/utils.dart';
import 'package:shiba/data/services/tts_service.dart';

/// Reusable dialog for downloading TTS model with progress, speed, and cancel.
class TtsDownloadDialog extends StatefulWidget {
  final TtsService ttsService;
  /// Called when download completes successfully.
  final VoidCallback? onComplete;

  const TtsDownloadDialog({
    super.key,
    required this.ttsService,
    this.onComplete,
  });

  @override
  State<TtsDownloadDialog> createState() => _TtsDownloadDialogState();
}

class _TtsDownloadDialogState extends State<TtsDownloadDialog> {
  int _received = 0;
  int _total = 1;
  bool _downloading = false;
  bool _done = false;
  String? _error;
  int _lastReceived = 0;
  DateTime _lastSpeedTime = DateTime.now();
  double _speed = 0;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  @override
  void dispose() {
    if (_downloading && _cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('dialog_dismissed');
    }
    widget.ttsService.onDownloadProgress = null;
    super.dispose();
  }

  Future<void> _startDownload() async {
    final cancelToken = CancelToken();
    setState(() {
      _downloading = true;
      _error = null;
      _received = 0;
      _speed = 0;
      _cancelToken = cancelToken;
    });

    _lastSpeedTime = DateTime.now();
    _lastReceived = 0;

    widget.ttsService.onDownloadProgress = (received, total) {
      if (mounted) {
        final now = DateTime.now();
        final elapsed = now.difference(_lastSpeedTime).inMilliseconds;
        if (elapsed >= 1000) {
          _speed = ((received - _lastReceived) * 1000.0) / elapsed;
          _lastReceived = received;
          _lastSpeedTime = now;
        }
        setState(() {
          _received = received;
          _total = total > 0 ? total : 1;
        });
      }
    };

    final ok = await widget.ttsService.downloadModel(cancelToken: cancelToken);
    widget.ttsService.onDownloadProgress = null;

    if (mounted) {
      if (ok) {
        setState(() {
          _downloading = false;
          _done = true;
        });
        widget.onComplete?.call();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        setState(() {
          _downloading = false;
          if (!cancelToken.isCancelled) {
            _error = '下载失败，请检查网络后重试';
          }
        });
        if (cancelToken.isCancelled && mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel('user_cancelled');
  }

  @override
  Widget build(BuildContext context) {
    final fraction = _total > 0 ? _received / _total : 0.0;
    final mbReceived = (_received / (1024 * 1024)).toStringAsFixed(1);
    final mbTotal = (_total / (1024 * 1024)).toStringAsFixed(0);

    return AlertDialog(
      title: Text(_done ? '下载完成' : '下载语音模型'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_downloading) ...[
            LinearProgressIndicator(value: fraction),
            const SizedBox(height: 8),
            Text('$mbReceived / $mbTotal MB',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(fraction * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(formatSpeed(_speed),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text('速度过慢时会自动切换下载源',
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.outline)),
          ],
          if (_done)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('语音模型下载完成'),
              ],
            ),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _startDownload,
              child: const Text('重试'),
            ),
          ],
        ],
      ),
      actions: [
        if (_downloading)
          TextButton(
            onPressed: _cancelDownload,
            child: const Text('取消'),
          ),
        if (_error != null)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
      ],
    );
  }
}
