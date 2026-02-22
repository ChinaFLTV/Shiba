import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

/// TTS engine states
enum TtsState { idle, initializing, speaking, downloading }

/// Lazy-loaded TTS service using sherpa_onnx with MeloTTS zh-en model.
///
/// Key design decisions:
/// - Isolate: TTS generation runs in a background isolate to avoid ANR
/// - Model download: model files are downloaded on first use (~170MB)
/// - Memory: TTS engine is created and freed per-generation in the isolate
class TtsService {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _playerCompleteSub;

  TtsState _state = TtsState.idle;
  TtsState get state => _state;

  /// Callback for state changes (UI can listen to this)
  void Function(TtsState state)? onStateChanged;

  /// Callback for model download progress
  void Function(int received, int total)? onDownloadProgress;

  /// Cached model directory path (avoids repeated async lookup)
  String? _cachedModelDir;

  /// Model file definitions for MeloTTS zh-en
  static const String _modelDirName = 'vits-melo-tts-zh_en';
  static const List<_ModelFile> _modelFiles = [
    _ModelFile('model.onnx', 170917888),       // ~163MB
    _ModelFile('lexicon.txt', 6815744),         // ~6.5MB
    _ModelFile('tokens.txt', 655),              // ~655B
    _ModelFile('date.fst', 59392),              // ~58KB
    _ModelFile('number.fst', 64512),            // ~63KB
    _ModelFile('phone.fst', 89088),             // ~87KB
    _ModelFile('new_heteronym.fst', 22528),     // ~22KB
  ];

  // Dict files needed by MeloTTS
  static const List<String> _dictFiles = [
    'dict/jieba.dict.utf8',
    'dict/hmm_model.utf8',
    'dict/idf.utf8',
    'dict/user.dict.utf8',
    'dict/stop_words.utf8',
    'dict/pos_dict/char_state_tab.utf8',
    'dict/pos_dict/prob_emit.utf8',
    'dict/pos_dict/prob_start.utf8',
    'dict/pos_dict/prob_trans.utf8',
  ];

  /// Mirror sources for downloading model files (ordered by priority)
  /// Falls back to next mirror if current one is too slow or fails.
  static const List<String> _mirrorBaseUrls = [
    'https://hf-mirror.com/csukuangfj/vits-melo-tts-zh_en/resolve/main',
    'https://huggingface.co/csukuangfj/vits-melo-tts-zh_en/resolve/main',
  ];

  /// Minimum acceptable download speed (bytes/sec).
  /// If speed drops below this for [_slowSpeedTimeout], switch mirror.
  static const int _minSpeedBytes = 50 * 1024; // 50 KB/s
  static const Duration _slowSpeedTimeout = Duration(seconds: 15);

  /// Get the local model directory path
  Future<String> get _modelDir async {
    if (_cachedModelDir != null) return _cachedModelDir!;
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(path_lib.join(appDir.path, 'tts', _modelDirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cachedModelDir = dir.path;
    return dir.path;
  }

  /// Check if all required model files exist locally
  Future<bool> isModelDownloaded() async {
    final dir = await _modelDir;
    for (final mf in _modelFiles) {
      final file = File(path_lib.join(dir, mf.name));
      if (!await file.exists()) return false;
    }
    // Check dict directory
    for (final df in _dictFiles) {
      final file = File(path_lib.join(dir, df));
      if (!await file.exists()) return false;
    }
    return true;
  }

  /// Download all model files. Returns true on success.
  /// Tries multiple mirror sources, auto-switching if speed is too slow.
  Future<bool> downloadModel({CancelToken? cancelToken}) async {
    _setState(TtsState.downloading);
    final dir = await _modelDir;

    // Create dict subdirectories
    final dictDir = Directory(path_lib.join(dir, 'dict'));
    if (!await dictDir.exists()) {
      await dictDir.create(recursive: true);
    }
    final posDictDir = Directory(path_lib.join(dir, 'dict', 'pos_dict'));
    if (!await posDictDir.exists()) {
      await posDictDir.create(recursive: true);
    }

    // Collect all files to download
    final allFiles = <String>[
      ..._modelFiles.map((f) => f.name),
      ..._dictFiles,
    ];

    // Calculate already-downloaded bytes for progress
    int totalDownloaded = 0;
    const estimatedTotal = 191196365; // ~182.4MB

    for (final fileName in allFiles) {
      final file = File(path_lib.join(dir, fileName));
      if (await file.exists() && await file.length() > 0) {
        totalDownloaded += await file.length();
      }
    }
    onDownloadProgress?.call(totalDownloaded, estimatedTotal);

    // Try each mirror in order
    for (int mirrorIdx = 0; mirrorIdx < _mirrorBaseUrls.length; mirrorIdx++) {
      final baseUrl = _mirrorBaseUrls[mirrorIdx];
      debugPrint('[TTS] Trying mirror ${mirrorIdx + 1}/${_mirrorBaseUrls.length}: $baseUrl');

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
        _setState(TtsState.idle);
        return true;
      }

      // If cancelled by user, don't try next mirror
      if (cancelToken?.isCancelled == true) {
        _setState(TtsState.idle);
        return false;
      }

      // Recalculate totalDownloaded (some files may have been downloaded)
      totalDownloaded = 0;
      for (final fileName in allFiles) {
        final file = File(path_lib.join(dir, fileName));
        if (await file.exists() && await file.length() > 0) {
          totalDownloaded += await file.length();
        }
      }

      debugPrint('[TTS] Mirror $baseUrl failed, trying next...');
    }

    _setState(TtsState.idle);
    return false;
  }

  /// Download remaining files from a single mirror source.
  /// Returns true if all files downloaded successfully.
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
        // Check user cancellation before each file
        if (cancelToken?.isCancelled == true) return false;

        final localPath = path_lib.join(dir, fileName);
        final file = File(localPath);

        // Skip already downloaded files
        if (await file.exists() && await file.length() > 0) {
          continue;
        }

        final url = '$baseUrl/$fileName';
        debugPrint('[TTS] Downloading: $fileName from $baseUrl');

        // Speed monitoring variables
        DateTime lastSpeedCheck = DateTime.now();
        int lastCheckBytes = 0;
        DateTime? slowSince;
        // Per-file cancel token for speed-based switching
        final fileCancelToken = CancelToken();

        // Poll user cancel token — onReceiveProgress won't fire during
        // connection phase, so we need a timer to propagate cancellation.
        Timer? cancelPollTimer;
        if (cancelToken != null) {
          cancelPollTimer = Timer.periodic(
            const Duration(milliseconds: 500),
            (_) {
              if (cancelToken.isCancelled && !fileCancelToken.isCancelled) {
                fileCancelToken.cancel('user_cancelled');
                cancelPollTimer?.cancel();
              }
            },
          );
        }

        try {
          await dio.download(
            url,
            localPath,
            cancelToken: fileCancelToken,
            onReceiveProgress: (received, total) {
              // Check user cancellation during download
              if (cancelToken?.isCancelled == true && !fileCancelToken.isCancelled) {
                fileCancelToken.cancel('user_cancelled');
                return;
              }

              onDownloadProgress?.call(
                currentTotal + received,
                estimatedTotal,
              );

              // Speed check every 3 seconds
              final now = DateTime.now();
              final elapsed = now.difference(lastSpeedCheck).inMilliseconds;
              if (elapsed >= 3000) {
                final speed = ((received - lastCheckBytes) * 1000) / elapsed;
                lastCheckBytes = received;
                lastSpeedCheck = now;

                if (speed < _minSpeedBytes && received > 0) {
                  slowSince ??= now;
                  final slowDuration = now.difference(slowSince!);
                  debugPrint('[TTS] Slow speed: ${(speed / 1024).toStringAsFixed(1)} KB/s '
                      'for ${slowDuration.inSeconds}s');
                  // If slow for too long and not the last mirror, abort
                  if (slowDuration > _slowSpeedTimeout && !isLastMirror) {
                    debugPrint('[TTS] Speed too slow, switching mirror');
                    fileCancelToken.cancel('slow_speed');
                  }
                } else {
                  slowSince = null;
                }
              }
            },
          );

          cancelPollTimer?.cancel();
          final downloadedSize = await File(localPath).length();
          currentTotal += downloadedSize;
        } on DioException catch (e) {
          cancelPollTimer?.cancel();
          if (e.type == DioExceptionType.cancel) {
            final reason = fileCancelToken.cancelError?.message ?? '';
            if (reason == 'user_cancelled' || cancelToken?.isCancelled == true) {
              rethrow; // Propagate user cancellation
            }
            if (reason == 'slow_speed') {
              // Delete incomplete file before switching mirror
              if (await File(localPath).exists()) {
                await File(localPath).delete();
              }
              return false; // Try next mirror
            }
          }
          rethrow;
        }
      }

      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint('[TTS] Download cancelled');
      } else {
        debugPrint('[TTS] Download failed from $baseUrl: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint('[TTS] Download error from $baseUrl: $e');
      return false;
    }
  }

  /// Delete all downloaded model files
  Future<void> deleteModel() async {
    await stop();
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(path_lib.join(appDir.path, 'tts'));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    _cachedModelDir = null;
  }

  /// Get total size of downloaded model files
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

  /// Speak the given text. Runs TTS generation in a background isolate
  /// to avoid blocking the UI thread (which causes ANR on Android).
  Future<bool> speak(String text, {double speed = 1.0, int sid = 0}) async {
    if (text.trim().isEmpty) return false;

    // Stop any current playback
    await stop();

    if (!await isModelDownloaded()) {
      debugPrint('[TTS] Model not downloaded');
      return false;
    }

    _setState(TtsState.speaking);

    try {
      var processText = text.trim();
      if (processText.length > 500) {
        processText = '${processText.substring(0, 500)}...';
      }
      processText = _stripMarkdown(processText);
      // Strip characters that cause OOV warnings and slow processing
      processText = _stripUnsupportedChars(processText);

      if (processText.trim().isEmpty) {
        debugPrint('[TTS] Text empty after processing');
        _setState(TtsState.idle);
        return false;
      }

      final dir = await _modelDir;
      final wavPath = path_lib.join(dir, '..', 'tts_output.wav');

      // Run TTS generation in a background isolate to prevent ANR.
      // All parameters must be extracted to local variables before the
      // closure to avoid capturing `this` (which contains unsendable objects).
      final params = _TtsGenerateParams(
        modelDir: dir,
        text: processText,
        sid: sid,
        speed: speed,
        wavPath: wavPath,
      );
      final ok = await Isolate.run(() => _generateInIsolate(params));

      if (!ok) {
        debugPrint('[TTS] Generation failed in isolate');
        _setState(TtsState.idle);
        return false;
      }

      // Verify WAV file exists and has content
      final wavFile = File(wavPath);
      if (!await wavFile.exists() || await wavFile.length() < 100) {
        debugPrint('[TTS] WAV file missing or empty');
        _setState(TtsState.idle);
        return false;
      }

      // Play the audio on the main thread
      await _player.play(DeviceFileSource(wavPath));

      _playerCompleteSub?.cancel();
      _playerCompleteSub = _player.onPlayerComplete.listen((_) {
        if (_state == TtsState.speaking) {
          _setState(TtsState.idle);
        }
        _playerCompleteSub?.cancel();
        _playerCompleteSub = null;
      });

      return true;
    } catch (e) {
      debugPrint('[TTS] Speak error: $e');
      _setState(TtsState.idle);
      return false;
    }
  }

  /// TTS generation entry point that runs inside an isolate.
  /// Creates engine, generates audio, writes WAV, frees engine.
  static bool _generateInIsolate(_TtsGenerateParams p) {
    try {
      sherpa_onnx.initBindings();

      final modelPath = path_lib.join(p.modelDir, 'model.onnx');
      final lexiconPath = path_lib.join(p.modelDir, 'lexicon.txt');
      final tokensPath = path_lib.join(p.modelDir, 'tokens.txt');
      final dateFst = path_lib.join(p.modelDir, 'date.fst');
      final numberFst = path_lib.join(p.modelDir, 'number.fst');
      final phoneFst = path_lib.join(p.modelDir, 'phone.fst');
      final heteronymFst = path_lib.join(p.modelDir, 'new_heteronym.fst');

      final vits = sherpa_onnx.OfflineTtsVitsModelConfig(
        model: modelPath,
        lexicon: lexiconPath,
        tokens: tokensPath,
      );

      final modelConfig = sherpa_onnx.OfflineTtsModelConfig(
        vits: vits,
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      );

      final config = sherpa_onnx.OfflineTtsConfig(
        model: modelConfig,
        ruleFsts: '$phoneFst,$dateFst,$numberFst,$heteronymFst',
        maxNumSenetences: 2,
      );

      final tts = sherpa_onnx.OfflineTts(config);

      final audio = tts.generate(text: p.text, sid: p.sid, speed: p.speed);

      if (audio.samples.isEmpty) {
        tts.free();
        return false;
      }

      final ok = sherpa_onnx.writeWave(
        filename: p.wavPath,
        samples: audio.samples,
        sampleRate: audio.sampleRate,
      );

      tts.free();
      return ok;
    } catch (e) {
      // Can't use debugPrint in isolate, but the error will propagate
      return false;
    }
  }

  /// Strip markdown formatting for cleaner TTS output
  static String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'```[\s\S]*?```'), '') // code blocks
        .replaceAll(RegExp(r'`[^`]+`'), '')        // inline code
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // bold
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1')     // italic
        .replaceAll(RegExp(r'#{1,6}\s+'), '')           // headers
        .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '') // list items
        .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '') // numbered lists
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1') // links
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')  // excessive newlines
        .trim();
  }

  /// Strip characters unsupported by MeloTTS lexicon (cause OOV warnings
  /// and slow down processing significantly).
  static String _stripUnsupportedChars(String text) {
    return text
        .replaceAll(RegExp(r'[《》（）【】「」『』〈〉""'']'), '')
        .replaceAll(RegExp(r'[&|\\~^]'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  /// Stop current playback
  Future<void> stop() async {
    _playerCompleteSub?.cancel();
    _playerCompleteSub = null;
    await _player.stop();
    if (_state == TtsState.speaking) {
      _setState(TtsState.idle);
    }
  }

  void _setState(TtsState newState) {
    if (_state != newState) {
      _state = newState;
      onStateChanged?.call(newState);
    }
  }

  /// Fully dispose the service (call on app shutdown)
  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}

/// Model file descriptor
class _ModelFile {
  final String name;
  final int approximateSize;
  const _ModelFile(this.name, this.approximateSize);
}

/// Parameters for isolate-based TTS generation.
/// All fields must be sendable across isolate boundaries.
class _TtsGenerateParams {
  final String modelDir;
  final String text;
  final int sid;
  final double speed;
  final String wavPath;

  const _TtsGenerateParams({
    required this.modelDir,
    required this.text,
    required this.sid,
    required this.speed,
    required this.wavPath,
  });
}
