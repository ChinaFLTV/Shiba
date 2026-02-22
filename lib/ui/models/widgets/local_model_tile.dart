import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/data/models/local_model.dart';
import 'package:shiba/providers/model_providers.dart';
import 'package:shiba/providers/service_providers.dart';

class LocalModelTile extends ConsumerStatefulWidget {
  final LocalModel model;
  const LocalModelTile({super.key, required this.model});

  @override
  ConsumerState<LocalModelTile> createState() => _LocalModelTileState();
}

class _LocalModelTileState extends ConsumerState<LocalModelTile> {
  bool _expanded = false;

  LocalModel get model => widget.model;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dp = ref.watch(downloadProgressProvider(model.id));

    final ModelStatus effectiveStatus;
    if (dp.isActive) {
      effectiveStatus = ModelStatus.downloading;
    } else {
      effectiveStatus = model.status;
    }

    final isActive = effectiveStatus == ModelStatus.downloading ||
        effectiveStatus == ModelStatus.paused ||
        effectiveStatus == ModelStatus.pending;

    final progressFraction = dp.received > 0 ? dp.fraction : model.progress;
    final receivedText = dp.received > 0
        ? _formatBytes(dp.received)
        : model.downloadedSizeFormatted;
    final totalText =
        dp.total > 0 ? _formatBytes(dp.total) : model.fileSizeFormatted;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: effectiveStatus == ModelStatus.completed
            ? () => setState(() => _expanded = !_expanded)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: status icon + name + actions
              Row(
                children: [
                  _StatusDot(status: effectiveStatus),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      model.displayName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildActions(context, ref, effectiveStatus),
                ],
              ),

              const SizedBox(height: 6),

              // Row 2: metadata chips (author, quant, size, status)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (model.author.isNotEmpty)
                    _InfoChip(
                      icon: Icons.person_outline,
                      label: model.author,
                      color: colorScheme.secondaryContainer,
                      textColor: colorScheme.onSecondaryContainer,
                    ),
                  if (model.quantization.isNotEmpty)
                    _InfoChip(
                      icon: Icons.memory,
                      label: model.quantization,
                      color: colorScheme.tertiaryContainer,
                      textColor: colorScheme.onTertiaryContainer,
                    ),
                  _InfoChip(
                    icon: Icons.storage,
                    label: model.fileSizeFormatted,
                    color: colorScheme.surfaceContainerHighest,
                    textColor: colorScheme.onSurface,
                  ),
                  _InfoChip(
                    icon: _statusIcon(effectiveStatus),
                    label: _statusLabel(effectiveStatus),
                    color: _statusBgColor(colorScheme, effectiveStatus),
                    textColor: _statusFgColor(colorScheme, effectiveStatus),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Row 3: filename
              Text(
                model.filename,
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Progress section for active downloads
              if (isActive) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressFraction > 0 ? progressFraction : null,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '$receivedText / $totalText',
                      style: TextStyle(fontSize: 11, color: colorScheme.outline),
                    ),
                    const Spacer(),
                    Text(
                      '${(progressFraction * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (effectiveStatus == ModelStatus.downloading ||
                    effectiveStatus == ModelStatus.pending) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.speed, size: 12, color: colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(dp.speedFormatted,
                          style: TextStyle(fontSize: 11, color: colorScheme.outline)),
                      const SizedBox(width: 12),
                      Icon(Icons.timer_outlined, size: 12, color: colorScheme.outline),
                      const SizedBox(width: 4),
                      Text('剩余 ${dp.etaFormatted}',
                          style: TextStyle(fontSize: 11, color: colorScheme.outline)),
                    ],
                  ),
                ],
                if (effectiveStatus == ModelStatus.paused) ...[
                  const SizedBox(height: 2),
                  Text('已暂停',
                      style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.outline,
                          fontStyle: FontStyle.italic)),
                ],
              ],

              // Expanded detail section (completed models only)
              if (_expanded && effectiveStatus == ModelStatus.completed) ...[
                const Divider(height: 16),
                _DetailRow(label: '仓库', value: model.repoId),
                _DetailRow(label: '文件名', value: model.filename),
                _DetailRow(
                  label: '路径',
                  value: model.filePath,
                  copiable: true,
                  context: context,
                ),
                _DetailRow(label: '文件大小', value: model.fileSizeFormatted),
                if (model.quantization.isNotEmpty)
                  _DetailRow(label: '量化类型', value: model.quantization),
                _DetailRow(label: '下载时间', value: model.createdAtFormatted),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- Status helpers ---

  IconData _statusIcon(ModelStatus status) {
    switch (status) {
      case ModelStatus.completed:
        return Icons.check_circle_outline;
      case ModelStatus.downloading:
      case ModelStatus.pending:
        return Icons.downloading;
      case ModelStatus.paused:
        return Icons.pause_circle_outline;
      case ModelStatus.failed:
        return Icons.error_outline;
    }
  }

  String _statusLabel(ModelStatus status) {
    switch (status) {
      case ModelStatus.completed:
        return '已完成';
      case ModelStatus.downloading:
        return '下载中';
      case ModelStatus.pending:
        return '等待中';
      case ModelStatus.paused:
        return '已暂停';
      case ModelStatus.failed:
        return '失败';
    }
  }

  Color _statusBgColor(ColorScheme cs, ModelStatus status) {
    switch (status) {
      case ModelStatus.completed:
        return cs.primaryContainer;
      case ModelStatus.downloading:
      case ModelStatus.pending:
        return cs.tertiaryContainer;
      case ModelStatus.paused:
        return cs.surfaceContainerHighest;
      case ModelStatus.failed:
        return cs.errorContainer;
    }
  }

  Color _statusFgColor(ColorScheme cs, ModelStatus status) {
    switch (status) {
      case ModelStatus.completed:
        return cs.onPrimaryContainer;
      case ModelStatus.downloading:
      case ModelStatus.pending:
        return cs.onTertiaryContainer;
      case ModelStatus.paused:
        return cs.onSurface;
      case ModelStatus.failed:
        return cs.onErrorContainer;
    }
  }

  // --- Action buttons ---

  Widget _buildActions(BuildContext context, WidgetRef ref, ModelStatus status) {
    switch (status) {
      case ModelStatus.downloading:
      case ModelStatus.pending:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.pause, size: 20),
              onPressed: () {
                ref.read(downloadServiceProvider).pauseDownload(model.id);
                ref.read(downloadProgressProvider(model.id).notifier).state =
                    DownloadProgress(
                  received: ref.read(downloadProgressProvider(model.id)).received,
                  total: ref.read(downloadProgressProvider(model.id)).total,
                  isActive: false,
                  timestamp: DateTime.now(),
                );
                ref.read(localModelsProvider.notifier).refresh();
              },
              tooltip: '暂停',
            ),
            IconButton(
              icon: Icon(Icons.stop_circle_outlined,
                  size: 20, color: Theme.of(context).colorScheme.error),
              onPressed: () => _confirmCancel(context, ref),
              tooltip: '取消下载',
            ),
          ],
        );
      case ModelStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow, size: 20),
              onPressed: () => _resumeDownload(context, ref),
              tooltip: '继续下载',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _confirmDelete(context, ref),
              tooltip: '删除',
            ),
          ],
        );
      case ModelStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () => _resumeDownload(context, ref),
              tooltip: '重试',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _confirmDelete(context, ref),
              tooltip: '删除',
            ),
          ],
        );
      case ModelStatus.completed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: Theme.of(context).colorScheme.outline,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _confirmDelete(context, ref),
              tooltip: '删除',
            ),
          ],
        );
    }
  }

  void _resumeDownload(BuildContext context, WidgetRef ref) {
    final downloadService = ref.read(downloadServiceProvider);
    final progressNotifier =
        ref.read(downloadProgressProvider(model.id).notifier);
    downloadService.downloadModel(
      model,
      onProgress: (received, total, speed) {
        progressNotifier.state = DownloadProgress(
          received: received,
          total: total,
          speed: speed,
          isActive: true,
          timestamp: DateTime.now(),
        );
      },
      onComplete: () {
        progressNotifier.state = DownloadProgress(
          received: progressNotifier.state.received,
          total: progressNotifier.state.total,
          isActive: false,
          timestamp: DateTime.now(),
        );
        ref.read(localModelsProvider.notifier).refresh();
      },
      onError: (error) {
        progressNotifier.state = DownloadProgress(
          received: progressNotifier.state.received,
          total: progressNotifier.state.total,
          isActive: false,
          timestamp: DateTime.now(),
        );
        ref.read(localModelsProvider.notifier).refresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
          );
        }
      },
    );
    ref.read(localModelsProvider.notifier).refresh();
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('取消下载'),
        content: Text('确定要取消下载 ${model.displayName} 吗？\n已下载的文件将被删除。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('继续下载')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('取消下载')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(downloadServiceProvider).cancelDownload(model.id);
      await Future.delayed(const Duration(milliseconds: 300));
      await ref.read(localModelsProvider.notifier).deleteModel(model.id);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除模型'),
        content: Text(
            '确定要删除 ${model.displayName} 吗？\n这将释放 ${model.fileSizeFormatted} 的存储空间。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(localModelsProvider.notifier).deleteModel(model.id);
    }
  }
}

// --- Reusable sub-widgets ---

class _StatusDot extends StatelessWidget {
  final ModelStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (status) {
      ModelStatus.completed => cs.primary,
      ModelStatus.downloading || ModelStatus.pending => cs.tertiary,
      ModelStatus.paused => cs.outline,
      ModelStatus.failed => cs.error,
    };
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: textColor)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copiable;
  final BuildContext? context;
  const _DetailRow({
    required this.label,
    required this.value,
    this.copiable = false,
    this.context,
  });

  @override
  Widget build(BuildContext outerContext) {
    final cs = Theme.of(outerContext).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: cs.outline)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          if (copiable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                if (context != null && context!.mounted) {
                  ScaffoldMessenger.of(context!).showSnackBar(
                    const SnackBar(
                      content: Text('已复制到剪贴板'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: Icon(Icons.copy, size: 14, color: cs.outline),
            ),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
