import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:local_model/core/constants.dart';
import 'package:local_model/data/models/local_model.dart';
import 'package:local_model/data/repositories/model_repository.dart';

class DownloadService {
  final ModelRepository _modelRepo;
  late final Dio _dio;
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, bool> _isCancelled = {};
  /// Tracks whether a download has been paused/cancelled so that late
  /// onProgress callbacks from the stream are suppressed.
  final Set<String> _suppressedIds = {};

  DownloadService(this._modelRepo) {
    _dio = Dio(BaseOptions(
      connectTimeout: AppConstants.httpTimeout,
      receiveTimeout: const Duration(minutes: 30),
    ));
  }

  /// Get the models storage directory
  Future<String> get _modelsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, AppConstants.modelsSubDir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// Start or resume downloading a model file with resume support
  Future<void> downloadModel(
    LocalModel model, {
    required void Function(int received, int total, double speed) onProgress,
    required void Function() onComplete,
    required void Function(String error) onError,
  }) async {
    final cancelToken = CancelToken();
    _cancelTokens[model.id] = cancelToken;
    _isCancelled[model.id] = false;
    _suppressedIds.remove(model.id);

    try {
      final dir = await _modelsDir;
      final filePath = p.join(dir, model.filename);
      final file = File(filePath);

      int existingBytes = 0;
      if (await file.exists()) {
        existingBytes = await file.length();
      }

      // If file is already fully downloaded, skip network request
      if (model.fileSize > 0 && existingBytes >= model.fileSize) {
        await _modelRepo.updateDownloadProgress(
            model.id, existingBytes, ModelStatus.completed);
        _cancelTokens.remove(model.id);
        _isCancelled.remove(model.id);
        onComplete();
        return;
      }

      await _modelRepo.updateDownloadProgress(
          model.id, existingBytes, ModelStatus.downloading);

      int totalReceived = existingBytes;
      DateTime lastTime = DateTime.now();
      int lastBytes = existingBytes;
      double currentSpeed = 0;

      final response = await _dio.get<ResponseBody>(
        model.downloadUrl,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          headers: existingBytes > 0
              ? {'Range': 'bytes=$existingBytes-'}
              : null,
        ),
      );

      // If server responds 200 (full content) instead of 206 (partial),
      // it doesn't support range requests — restart from scratch to avoid
      // appending the full file after existing bytes (which corrupts it).
      final isPartial = response.statusCode == 206;
      if (existingBytes > 0 && !isPartial) {
        existingBytes = 0;
        totalReceived = 0;
        lastBytes = 0;
      }

      final contentLength = int.tryParse(
              response.headers.value('content-length') ?? '') ??
          -1;
      final actualTotal = isPartial && contentLength != -1
          ? contentLength + existingBytes
          : (contentLength != -1 ? contentLength : model.fileSize);

      final sink = file.openWrite(
          mode: isPartial ? FileMode.append : FileMode.write);

      try {
        await for (final chunk in response.data!.stream) {
          // Check suppression flag first — if paused/cancelled, stop
          // writing immediately without waiting for CancelToken propagation.
          if (_suppressedIds.contains(model.id) ||
              cancelToken.isCancelled) {
            break;
          }

          sink.add(chunk);
          totalReceived += chunk.length;

          // Calculate speed every 500ms
          final now = DateTime.now();
          final elapsed = now.difference(lastTime).inMilliseconds;
          if (elapsed >= 500) {
            currentSpeed =
                (totalReceived - lastBytes) / (elapsed / 1000.0);
            lastBytes = totalReceived;
            lastTime = now;
          }

          // Guard against late callbacks after pause/cancel
          if (!_suppressedIds.contains(model.id)) {
            onProgress(totalReceived, actualTotal, currentSpeed);
          }

          // Persist progress every 1MB
          if (totalReceived % (1024 * 1024) < chunk.length) {
            _modelRepo.updateDownloadProgress(
                model.id, totalReceived, ModelStatus.downloading);
          }
        }
      } finally {
        await sink.flush();
        await sink.close();
      }

      if (cancelToken.isCancelled ||
          _suppressedIds.contains(model.id)) {
        return;
      }

      // Use actual file size as the final truth for completed downloads
      final finalSize = await file.length();
      await _modelRepo.updateDownloadProgress(
          model.id, finalSize, ModelStatus.completed);
      _cancelTokens.remove(model.id);
      _isCancelled.remove(model.id);
      onComplete();
    } on DioException catch (e) {
      final wasCancelled = _isCancelled[model.id] ?? false;
      _cancelTokens.remove(model.id);
      _isCancelled.remove(model.id);

      if (e.type == DioExceptionType.cancel) {
        if (wasCancelled) {
          await _deleteModelFile(model);
          return;
        }
        // Pause — persist current progress from actual file size
        final file = File(model.filePath);
        final currentSize =
            await file.exists() ? await file.length() : model.downloadedSize;
        await _modelRepo.updateDownloadProgress(
            model.id, currentSize, ModelStatus.paused);
        return;
      }

      // HTTP 416: file already complete — treat as success
      if (e.response?.statusCode == 416) {
        final file = File(model.filePath);
        if (await file.exists()) {
          final fileLen = await file.length();
          if (model.fileSize > 0 && fileLen >= model.fileSize) {
            await _modelRepo.updateDownloadProgress(
                model.id, fileLen, ModelStatus.completed);
            _cancelTokens.remove(model.id);
            _isCancelled.remove(model.id);
            onComplete();
            return;
          }
        }
      }

      await _modelRepo.updateDownloadProgress(
          model.id, model.downloadedSize, ModelStatus.failed);
      onError('${ErrorMessages.downloadFailed}: ${e.message}');
    } catch (e) {
      _cancelTokens.remove(model.id);
      _isCancelled.remove(model.id);
      await _modelRepo.updateDownloadProgress(
          model.id, model.downloadedSize, ModelStatus.failed);
      onError('${ErrorMessages.downloadFailed}: $e');
    }
  }

  /// Pause a download (keeps file for resume)
  void pauseDownload(String modelId) {
    _suppressedIds.add(modelId);
    _isCancelled[modelId] = false;
    _cancelTokens[modelId]?.cancel('paused');
    _cancelTokens.remove(modelId);
  }

  /// Cancel a download (deletes file)
  void cancelDownload(String modelId) {
    _suppressedIds.add(modelId);
    _isCancelled[modelId] = true;
    _cancelTokens[modelId]?.cancel('cancelled');
    _cancelTokens.remove(modelId);
  }

  /// Whether a download is currently active
  bool isDownloading(String modelId) => _cancelTokens.containsKey(modelId);

  /// Delete model file from disk
  Future<void> _deleteModelFile(LocalModel model) async {
    try {
      final file = File(model.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Get the file path for a model
  Future<String> getModelFilePath(String filename) async {
    final dir = await _modelsDir;
    return p.join(dir, filename);
  }

  /// Check available storage space
  Future<int> getAvailableSpace() async {
    try {
      final dir = await _modelsDir;
      final stat = await FileStat.stat(dir);
      return stat.size > 0 ? stat.size : 10 * 1024 * 1024 * 1024;
    } catch (_) {
      return 10 * 1024 * 1024 * 1024;
    }
  }
}
