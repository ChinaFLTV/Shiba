import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:shiba/data/models/hf_model.dart';
import 'package:shiba/data/models/local_model.dart';
import 'package:shiba/l10n/app_localizations.dart';
import 'package:shiba/providers/model_providers.dart';
import 'package:shiba/providers/service_providers.dart';

import 'package:shiba/core/utils.dart';

const _uuid = Uuid();

class ModelFilesPage extends ConsumerWidget {
  final HfModel model;
  const ModelFilesPage({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(hfModelFilesProvider(model.modelId));
    final memoryLimit = ref.watch(deviceMemoryProvider).valueOrNull ??
        (4 * 1024 * 1024 * 1024);

    return Scaffold(
      appBar: AppBar(
        title: Text(model.displayName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model info header
          _ModelHeader(model: model, memoryLimit: memoryLimit),

          // GGUF files list
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(S.of(context).ggufFiles,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          Expanded(
            child: filesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(S.of(context).loadFailed('$e'))),
              data: (files) {
                if (files.isEmpty) {
                  return Center(child: Text(S.of(context).noGgufFiles));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return _FileTile(
                      file: file,
                      repoId: model.modelId,
                      memoryLimit: memoryLimit,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Model header ---

class _ModelHeader extends StatelessWidget {
  final HfModel model;
  final int memoryLimit;
  const _ModelHeader({required this.model, required this.memoryLimit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repo ID
          Text(model.modelId,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Stats row
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (model.author != null && model.author!.isNotEmpty)
                _HeaderChip(
                  icon: Icons.person_outline,
                  label: model.author!,
                  color: colorScheme.secondaryContainer,
                  textColor: colorScheme.onSecondaryContainer,
                ),
              _HeaderChip(
                icon: Icons.download,
                label: S.of(context).downloadsCount(model.downloadsFormatted),
                color: colorScheme.surfaceContainerHighest,
                textColor: colorScheme.onSurface,
              ),
              _HeaderChip(
                icon: Icons.favorite,
                label: S.of(context).likesCount('${model.likes}'),
                color: colorScheme.surfaceContainerHighest,
                textColor: colorScheme.onSurface,
              ),
              if (model.pipelineTag != null && model.pipelineTag!.isNotEmpty)
                _HeaderChip(
                  icon: Icons.category_outlined,
                  label: model.pipelineTag!,
                  color: colorScheme.tertiaryContainer,
                  textColor: colorScheme.onTertiaryContainer,
                ),
              if (model.lastModified != null)
                _HeaderChip(
                  icon: Icons.update,
                  label: _formatDate(model.lastModified!),
                  color: colorScheme.surfaceContainerHighest,
                  textColor: colorScheme.onSurface,
                ),
            ],
          ),

          // Tags
          if (model.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: model.tags
                  .take(8)
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: colorScheme.outlineVariant, width: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(tag,
                            style: TextStyle(
                                fontSize: 10, color: colorScheme.outline)),
                      ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 8),

          // Memory hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.memory, size: 14,
                    color: colorScheme.onTertiaryContainer),
                const SizedBox(width: 4),
                Text(
                  S.of(context).availableMemory(formatBytes(memoryLimit)),
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onTertiaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  const _HeaderChip({
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

// --- Suitability evaluation ---

enum _Suitability { recommended, ok, risky, tooLarge }

_Suitability _evaluateSuitability(int fileSize, int memoryLimit) {
  if (fileSize <= 0 || memoryLimit <= 0) return _Suitability.ok;
  final ratio = fileSize / memoryLimit;
  if (ratio <= 0.6) return _Suitability.recommended;
  if (ratio <= 0.85) return _Suitability.ok;
  if (ratio <= 1.0) return _Suitability.risky;
  return _Suitability.tooLarge;
}

// --- File tile ---

class _FileTile extends ConsumerWidget {
  final HfModelFile file;
  final String repoId;
  final int memoryLimit;

  const _FileTile({
    required this.file,
    required this.repoId,
    required this.memoryLimit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final suitability = _evaluateSuitability(file.size, memoryLimit);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: filename + download button
            Row(
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 20,
                  color: switch (suitability) {
                    _Suitability.recommended => colorScheme.primary,
                    _Suitability.ok => colorScheme.primary,
                    _Suitability.risky => colorScheme.tertiary,
                    _Suitability.tooLarge => colorScheme.error,
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.filename,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (suitability != _Suitability.tooLarge)
                  FilledButton.tonal(
                    onPressed: () => _startDownload(context, ref),
                    child: Text(S.of(context).download),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Row 2: metadata chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _HeaderChip(
                  icon: Icons.storage,
                  label: file.sizeFormatted,
                  color: colorScheme.surfaceContainerHighest,
                  textColor: colorScheme.onSurface,
                ),
                if (file.quantization.isNotEmpty)
                  _HeaderChip(
                    icon: Icons.memory,
                    label: file.quantization,
                    color: colorScheme.tertiaryContainer,
                    textColor: colorScheme.onTertiaryContainer,
                  ),
                if (file.isMmproj)
                  _HeaderChip(
                    icon: Icons.visibility,
                    label: 'Vision Projector',
                    color: colorScheme.primaryContainer,
                    textColor: colorScheme.onPrimaryContainer,
                  ),
                _buildSuitabilityChip(context, suitability),
              ],
            ),

            // Row 3: full path if different from filename
            if (file.rfilename != file.filename) ...[
              const SizedBox(height: 4),
              Text(
                file.rfilename,
                style: TextStyle(fontSize: 11, color: colorScheme.outline),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuitabilityChip(BuildContext context, _Suitability suitability) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = S.of(context);
    final (label, icon, bgColor, fgColor) = switch (suitability) {
      _Suitability.recommended => (
        l10n.suitabilityRecommended,
        Icons.thumb_up_outlined,
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
      _Suitability.ok => (
        l10n.suitabilityOk,
        Icons.check_circle_outline,
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      _Suitability.risky => (
        l10n.suitabilityRisky,
        Icons.warning_amber,
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),
      _Suitability.tooLarge => (
        l10n.suitabilityTooLarge,
        Icons.block,
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
    };
    return _HeaderChip(icon: icon, label: label, color: bgColor, textColor: fgColor);
  }

  /// Enqueue a single file for download and wire up progress/completion callbacks.
  Future<void> _enqueueDownload(
    BuildContext context,
    WidgetRef ref,
    HfModelFile targetFile,
    String targetRepoId,
  ) async {
    // Prevent duplicate downloads of the same file
    final existingModels = ref.read(localModelsProvider).valueOrNull ?? [];
    final alreadyExists = existingModels.any((m) =>
        m.repoId == targetRepoId &&
        m.filename == targetFile.filename &&
        m.status != ModelStatus.failed);
    if (alreadyExists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).alreadyInList(targetFile.filename)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final hfApi = ref.read(hfApiServiceProvider);
    final downloadService = ref.read(downloadServiceProvider);
    final filePath = await downloadService.getModelFilePath(targetFile.filename);
    final downloadUrl = hfApi.getDownloadUrl(targetRepoId, targetFile.rfilename);

    final localModel = LocalModel(
      id: _uuid.v4(),
      repoId: targetRepoId,
      filename: targetFile.filename,
      filePath: filePath,
      fileSize: targetFile.size,
      downloadedSize: 0,
      status: ModelStatus.pending,
      downloadUrl: downloadUrl,
      createdAt: DateTime.now(),
    );

    await ref.read(localModelsProvider.notifier).addModel(localModel);

    final progressNotifier =
        ref.read(downloadProgressProvider(localModel.id).notifier);
    final modelsNotifier = ref.read(localModelsProvider.notifier);

    downloadService.downloadModel(
      localModel,
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
        modelsNotifier.refresh();
      },
      onError: (error) {
        progressNotifier.state = DownloadProgress(
          received: progressNotifier.state.received,
          total: progressNotifier.state.total,
          isActive: false,
          timestamp: DateTime.now(),
        );
        modelsNotifier.refresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
          );
        }
      },
    );
  }

  Future<void> _startDownload(BuildContext context, WidgetRef ref) async {
    await _enqueueDownload(context, ref, file, repoId);
    if (!context.mounted) return;

    // Auto-download mmproj file for multimodal models
    bool mmprojQueued = false;
    if (!file.isMmproj) {
      final allFiles = ref.read(hfModelFilesProvider(repoId)).valueOrNull ?? [];
      final mmprojFile = allFiles.where((f) => f.isMmproj).firstOrNull;
      if (mmprojFile != null) {
        // Check if mmproj is already downloaded or queued
        final localModels = ref.read(localModelsProvider).valueOrNull ?? [];
        final alreadyExists = localModels.any((m) =>
            m.repoId == repoId &&
            m.filename.toLowerCase().contains('mmproj'));
        if (!alreadyExists) {
          await _enqueueDownload(context, ref, mmprojFile, repoId);
          mmprojQueued = true;
        }
      }
    }

    if (context.mounted) {
      final msg = mmprojQueued
          ? S.of(context).startDownloadWithVision(file.filename)
          : S.of(context).startDownload(file.filename);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context);
    }
  }
}

