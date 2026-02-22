import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/data/models/hf_model.dart';
import 'package:shiba/data/models/local_model.dart';
import 'package:shiba/providers/service_providers.dart';

/// Local models state
final localModelsProvider =
    AsyncNotifierProvider<LocalModelsNotifier, List<LocalModel>>(
        LocalModelsNotifier.new);

class LocalModelsNotifier extends AsyncNotifier<List<LocalModel>> {
  @override
  Future<List<LocalModel>> build() async {
    return ref.read(modelRepoProvider).getAllModels();
  }

  Future<void> refresh() async {
    state = AsyncData(await ref.read(modelRepoProvider).getAllModels());
  }

  Future<void> addModel(LocalModel model) async {
    await ref.read(modelRepoProvider).insertModel(model);
    await refresh();
  }

  Future<void> deleteModel(String id) async {
    await ref.read(modelRepoProvider).deleteModel(id);
    await refresh();
  }

  Future<void> updateModel(LocalModel model) async {
    await ref.read(modelRepoProvider).updateModel(model);
    await refresh();
  }
}

/// Currently selected model for chat
final selectedModelProvider = StateProvider<LocalModel?>((ref) => null);

/// Download progress tracking: modelId -> DownloadProgress
class DownloadProgress {
  final int received;
  final int total;
  final double speed; // bytes per second
  final DateTime timestamp;
  final bool isActive; // true when download is actively running

  const DownloadProgress({
    this.received = 0,
    this.total = 0,
    this.speed = 0,
    this.isActive = false,
    required this.timestamp,
  });

  double get fraction => total > 0 ? received / total : 0.0;

  String get speedFormatted {
    if (speed <= 0) return '--';
    if (speed < 1024) return '${speed.toStringAsFixed(0)} B/s';
    if (speed < 1024 * 1024) {
      return '${(speed / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  String get etaFormatted {
    if (speed <= 0 || total <= 0) return '--';
    final remaining = total - received;
    final seconds = (remaining / speed).round();
    if (seconds < 60) return '$seconds 秒';
    if (seconds < 3600) return '${seconds ~/ 60} 分钟';
    return '${seconds ~/ 3600} 小时 ${(seconds % 3600) ~/ 60} 分钟';
  }
}

final downloadProgressProvider =
    StateProvider.family<DownloadProgress, String>(
        (ref, modelId) => DownloadProgress(timestamp: DateTime.now()));

/// HuggingFace model search
final hfSearchQueryProvider = StateProvider<String>((ref) => '');

final hfSearchResultsProvider =
    FutureProvider.family<List<HfModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final api = ref.read(hfApiServiceProvider);
  return api.searchModels(query);
});

/// Model files for a specific repo
final hfModelFilesProvider =
    FutureProvider.family<List<HfModelFile>, String>((ref, repoId) async {
  final api = ref.read(hfApiServiceProvider);
  return api.getModelFiles(repoId);
});

/// Device memory info — reads total physical RAM at runtime.
///
/// Android: parses /proc/meminfo for MemTotal.
/// iOS/other: falls back to a conservative 4 GB estimate.
final deviceMemoryProvider = FutureProvider<int>((ref) async {
  int totalBytes = 4 * 1024 * 1024 * 1024; // 4 GB fallback

  if (Platform.isAndroid) {
    try {
      final meminfo = await File('/proc/meminfo').readAsString();
      final match = RegExp(r'MemTotal:\s+(\d+)\s+kB').firstMatch(meminfo);
      if (match != null) {
        totalBytes = int.parse(match.group(1)!) * 1024;
      }
    } catch (_) {}
  }

  return totalBytes;
});
