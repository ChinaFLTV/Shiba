import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

/// STT engine states
enum SttState { idle, downloading, listening, recognizing }

/// Offline STT service using sherpa_onnx with SenseVoice zh-en int8 model.
///
/// Design mirrors TtsService:
/// - Model download on first use (~230MB)
/// - Recognition runs in background isolate
/// - Microphone capture via `record` package (PCM 16-bit, 16kHz, mono)
class SttService {
  SttState _state = SttState.idle;
  SttState get state => _state;

  void Function(SttState state)? onStateChanged;
  void Function(int received, int total)? onDownloadProgress;

  String? _cachedModelDir;

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<List<int>>? _audioSub;

  /// Accumulated PCM samples (Float32) from microphone during listening.
  final List<double> _pcmSamples = [];

  static const int _sampleRate = 16000;

  // --- Model files ---
  static const String _modelDirName = 'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17';
  static const List<_ModelFile> _modelFiles = [
    _ModelFile('model.int8.onnx', 239075328), // ~228MB
    _ModelFile('tokens.txt', 315392),          // ~308KB
  ];

  static const List<String> _mirrorBaseUrls = [
    'https://hf-mirror.com/csukuangfj/$_modelDirName/resolve/main',
    'https://huggingface.co/csukuangfj/$_modelDirName/resolve/main',
  ];

  static const int _minSpeedBytes = 50 * 1024; // 50 KB/s
  static const Duration _slowSpeedTimeout = Duration(seconds: 15);

  // --- Model directory ---
  Future<String> get _modelDir async {
    if (_cachedModelDir != null) return _cachedModelDir!;
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(path_lib.join(appDir.path, 'stt', _modelDirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cachedModelDir = dir.path;
    return dir.path;
  }

  Future<bool> isModelDownloaded() async {
    final dir = await _modelDir;
    for (final mf in _modelFiles) {
      final file = File(path_lib.join(dir, mf.name));
      if (!await file.exists()) return false;
    }
    return true;
  }

  Future<int> getModelSize() async {
    final dir = await _modelDir;
    int total = 0;
    final d = Directory(dir);
    if (!await d.exists()) return 0;
    await for (final entity in d.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<void> deleteModel() async {
    await stopListening();
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(path_lib.join(appDir.path, 'stt'));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    _cachedModelDir = null;
  }

  // --- Download (mirrors TtsService pattern) ---
  Future<bool> downloadModel({CancelToken? cancelToken}) async {
    _setState(SttState.downloading);
    final dir = await _modelDir;

    final allFiles = _modelFiles.map((f) => f.name).toList();
    const estimatedTotal = 239390720; // ~228MB

    int totalDownloaded = 0;
    for (final fileName in allFiles) {
      final file = File(path_lib.join(dir, fileName));
      if (await file.exists() && await file.length() > 0) {
        totalDownloaded += await file.length();
      }
    }
    onDownloadProgress?.call(totalDownloaded, estimatedTotal);

    for (int mirrorIdx = 0; mirrorIdx < _mirrorBaseUrls.length; mirrorIdx++) {
      final baseUrl = _mirrorBaseUrls[mirrorIdx];
      debugPrint('[STT] Trying mirror ${mirrorIdx + 1}/${_mirrorBaseUrls.length}: $baseUrl');

      final success = await _downloadFromMirror(
        baseUrl: baseUrl,
        dir: dir,
        allFiles: allFiles,
        totalDownloaded: totalDownloaded,
        estimatedTotal: estimatedTotal,
        cancelToken: cancelToken,
        isLastMirror: mirrorIdx == _mirrorBaseUrls.length - 1,
      );

      if (success) {
        _setState(SttState.idle);
        return true;
      }

      if (cancelToken?.isCancelled == true) {
        _setState(SttState.idle);
        return false;
      }

      totalDownloaded = 0;
      for (final fileName in allFiles) {
        final file = File(path_lib.join(dir, fileName));
        if (await file.exists() && await file.length() > 0) {
          totalDownloaded += await file.length();
        }
      }
      debugPrint('[STT] Mirror $baseUrl failed, trying next...');
    }

    _setState(SttState.idle);
    return false;
  }

  Future<bool> _downloadFromMirror({
    required String baseUrl,
    required String dir,
    required List<String> allFiles,
    required int totalDownloaded,
    required int estimatedTotal,
    CancelToken? cancelToken,
    bool isLastMirror = false,
  }) async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 30),
    ));

    int currentTotal = totalDownloaded;

    try {
      for (final fileName in allFiles) {
        if (cancelToken?.isCancelled == true) return false;

        final localPath = path_lib.join(dir, fileName);
        final file = File(localPath);
        if (await file.exists() && await file.length() > 0) continue;

        final url = '$baseUrl/$fileName';
        debugPrint('[STT] Downloading: $fileName');

        DateTime lastSpeedCheck = DateTime.now();
        int lastCheckBytes = 0;
        DateTime? slowSince;
        final fileCancelToken = CancelToken();

        Timer? cancelPollTimer;
        if (cancelToken != null) {
          cancelPollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
            if (cancelToken.isCancelled && !fileCancelToken.isCancelled) {
              fileCancelToken.cancel('user_cancelled');
              cancelPollTimer?.cancel();
            }
          });
        }

        try {
          await dio.download(url, localPath, cancelToken: fileCancelToken,
            onReceiveProgress: (received, total) {
              if (cancelToken?.isCancelled == true && !fileCancelToken.isCancelled) {
                fileCancelToken.cancel('user_cancelled');
                return;
              }
              onDownloadProgress?.call(currentTotal + received, estimatedTotal);

              final now = DateTime.now();
              final elapsed = now.difference(lastSpeedCheck).inMilliseconds;
              if (elapsed >= 3000) {
                final speed = ((received - lastCheckBytes) * 1000) / elapsed;
                lastCheckBytes = received;
                lastSpeedCheck = now;
                if (speed < _minSpeedBytes && received > 0) {
                  slowSince ??= now;
                  if (now.difference(slowSince!) > _slowSpeedTimeout && !isLastMirror) {
                    debugPrint('[STT] Speed too slow, switching mirror');
                    fileCancelToken.cancel('slow_speed');
                  }
                } else {
                  slowSince = null;
                }
              }
            },
          );
          cancelPollTimer?.cancel();
          currentTotal += await File(localPath).length();
        } on DioException catch (e) {
          cancelPollTimer?.cancel();
          if (e.type == DioExceptionType.cancel) {
            final reason = fileCancelToken.cancelError?.message ?? '';
            if (reason == 'user_cancelled' || cancelToken?.isCancelled == true) rethrow;
            if (reason == 'slow_speed') {
              if (await File(localPath).exists()) await File(localPath).delete();
              return false;
            }
          }
          rethrow;
        }
      }
      return true;
    } on DioException catch (e) {
      debugPrint('[STT] Download ${e.type == DioExceptionType.cancel ? "cancelled" : "failed"}: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[STT] Download error: $e');
      return false;
    }
  }

  // --- Listening & Recognition ---

  /// Start capturing microphone audio. Accumulates PCM samples internally.
  Future<bool> startListening() async {
    if (_state == SttState.listening) return true;
    if (!await isModelDownloaded()) return false;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    _pcmSamples.clear();
    _setState(SttState.listening);

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      ),
    );

    _audioSub = stream.listen((data) {
      // Convert PCM 16-bit LE bytes to Float32 samples [-1.0, 1.0]
      final bytes = Uint8List.fromList(data);
      final int16View = bytes.buffer.asInt16List();
      for (int i = 0; i < int16View.length; i++) {
        _pcmSamples.add(int16View[i] / 32768.0);
      }
    });

    return true;
  }

  /// Stop listening and run offline recognition. Returns recognized text.
  Future<String> stopAndRecognize() async {
    if (_state != SttState.listening) return '';

    // Stop recording
    await _audioSub?.cancel();
    _audioSub = null;
    await _recorder.stop();

    if (_pcmSamples.isEmpty) {
      _setState(SttState.idle);
      return '';
    }

    _setState(SttState.recognizing);

    try {
      final dir = await _modelDir;
      final samples = Float32List.fromList(_pcmSamples.map((e) => e.toDouble()).toList());
      _pcmSamples.clear();

      final params = _SttRecognizeParams(
        modelDir: dir,
        samples: samples,
        sampleRate: _sampleRate,
      );

      final result = await Isolate.run(() => _recognizeInIsolate(params));
      _setState(SttState.idle);
      return result;
    } catch (e) {
      debugPrint('[STT] Recognition error: $e');
      _setState(SttState.idle);
      return '';
    }
  }

  /// Cancel listening without recognition.
  Future<void> stopListening() async {
    await _audioSub?.cancel();
    _audioSub = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    _pcmSamples.clear();
    if (_state != SttState.idle) {
      _setState(SttState.idle);
    }
  }

  static String _recognizeInIsolate(_SttRecognizeParams p) {
    try {
      sherpa_onnx.initBindings();

      final modelPath = path_lib.join(p.modelDir, 'model.int8.onnx');
      final tokensPath = path_lib.join(p.modelDir, 'tokens.txt');

      final senseVoice = sherpa_onnx.OfflineSenseVoiceModelConfig(
        model: modelPath,
        useInverseTextNormalization: true,
      );

      final modelConfig = sherpa_onnx.OfflineModelConfig(
        senseVoice: senseVoice,
        tokens: tokensPath,
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      );

      final config = sherpa_onnx.OfflineRecognizerConfig(model: modelConfig);
      final recognizer = sherpa_onnx.OfflineRecognizer(config);
      final stream = recognizer.createStream();

      stream.acceptWaveform(samples: p.samples, sampleRate: p.sampleRate);
      recognizer.decode(stream);

      final result = recognizer.getResult(stream);
      final text = result.text.trim();

      stream.free();
      recognizer.free();

      return text;
    } catch (e) {
      return '';
    }
  }

  void _setState(SttState newState) {
    if (_state != newState) {
      _state = newState;
      onStateChanged?.call(newState);
    }
  }

  Future<void> dispose() async {
    await stopListening();
    _recorder.dispose();
  }
}

class _ModelFile {
  final String name;
  final int approximateSize;
  const _ModelFile(this.name, this.approximateSize);
}

class _SttRecognizeParams {
  final String modelDir;
  final Float32List samples;
  final int sampleRate;
  const _SttRecognizeParams({
    required this.modelDir,
    required this.samples,
    required this.sampleRate,
  });
}
