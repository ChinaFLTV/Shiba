import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/data/models/local_model.dart';
import 'package:shiba/core/utils.dart';
import 'package:shiba/l10n/app_localizations.dart';
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
    _cachedL10n = S.of(context);

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
        ? formatBytes(dp.received)
        : model.downloadedSizeFormatted;
    final totalText =
        dp.total > 0 ? formatBytes(dp.total) : model.fileSizeFormatted;

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
                      Text(_cachedL10n.remaining(dp.etaFormatted),
                          style: TextStyle(fontSize: 11, color: colorScheme.outline)),
                    ],
                  ),
                ],
                if (effectiveStatus == ModelStatus.paused) ...[
                  const SizedBox(height: 2),
                  Text(_cachedL10n.paused,
                      style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.outline,
                          fontStyle: FontStyle.italic)),
                ],
              ],

              // Expanded detail section (completed models only)
              if (_expanded && effectiveStatus == ModelStatus.completed) ...[
                const Divider(height: 16),
                _DetailRow(label: _cachedL10n.detailRepo, value: model.repoId),
                _DetailRow(label: _cachedL10n.detailFilename, value: model.filename),
                _DetailRow(
                  label: _cachedL10n.detailPath,
                  value: model.filePath,
                  copiable: true,
                  maxLines: null,
                ),
                _DetailRow(label: _cachedL10n.detailFileSize, value: model.fileSizeFormatted),
                if (model.quantization.isNotEmpty)
                  _DetailRow(label: _cachedL10n.detailQuantType, value: model.quantization),
                _DetailRow(label: _cachedL10n.detailDownloadTime, value: model.createdAtFormatted),
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
    // Note: context is available in build() where this is called
    switch (status) {
      case ModelStatus.completed:
        return _cachedL10n.statusCompleted;
      case ModelStatus.downloading:
        return _cachedL10n.statusDownloading;
      case ModelStatus.pending:
        return _cachedL10n.statusPending;
      case ModelStatus.paused:
        return _cachedL10n.statusPaused;
      case ModelStatus.failed:
        return _cachedL10n.statusFailed;
    }
  }

  late S _cachedL10n;

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
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                icon: const Icon(Icons.pause_rounded, size: 20),
                padding: EdgeInsets.zero,
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
                tooltip: _cachedL10n.pauseAction,
              ),
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                icon: Icon(Icons.cancel_outlined,
                    size: 20, color: Theme.of(context).colorScheme.error),
                padding: EdgeInsets.zero,
                onPressed: () => _confirmCancel(context, ref),
                tooltip: _cachedL10n.cancelDownload,
              ),
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
              tooltip: _cachedL10n.resumeDownload,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _confirmDelete(context, ref),
              tooltip: _cachedL10n.delete,
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
              tooltip: _cachedL10n.retry,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _confirmDelete(context, ref),
              tooltip: _cachedL10n.delete,
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
              tooltip: _cachedL10n.delete,
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
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelDownloadTitle),
        content: Text(l10n.cancelDownloadContent(model.displayName)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.continueDownload)),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.cancelDownload)),
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
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteModel),
        content: Text(l10n.deleteModelContent(model.displayName, model.fileSizeFormatted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.delete)),
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
  final int? maxLines;
  const _DetailRow({
    required this.label,
    required this.value,
    this.copiable = false,
    this.maxLines = 2,
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
                maxLines: maxLines,
                overflow: maxLines != null ? TextOverflow.ellipsis : null),
          ),
          if (copiable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(outerContext).showSnackBar(
                  SnackBar(
                    content: Text(S.of(outerContext).copiedToClipboard),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Icon(Icons.copy, size: 14, color: cs.outline),
            ),
        ],
      ),
    );
  }
}

