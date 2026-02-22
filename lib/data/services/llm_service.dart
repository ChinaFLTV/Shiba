import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:llamadart/llamadart.dart';
import 'package:shiba/core/constants.dart';
import 'package:shiba/core/cpu_feature_checker.dart';
import 'package:shiba/core/gpu_stability_checker.dart';
import 'package:shiba/core/utils.dart' show formatBytes;
import 'package:shiba/data/models/message.dart';

/// Service for local LLM inference using llamadart (llama.cpp binding).
///
/// Maintains a single [LlamaEngine] + [LlamaBackend] instance to avoid
/// repeated backend registration and isolate spawning.
class LlmService {
  LlamaEngine? _engine;
  LlamaBackend? _backend;
  bool _isLoaded = false;
  bool _hasVision = false;
  String? _loadedModelPath;

  /// Set to true after a Vulkan DeviceLost crash during vision inference.
  /// Prevents further vision attempts on this device until app restart.
  bool _vulkanVisionBlocked = false;

  /// Set to true when the native engine isolate is suspected to have crashed.
  /// Requires a full engine reset before any further operations.
  bool _engineCrashed = false;

  bool get isLoaded => _isLoaded;
  bool get hasVision => _hasVision && !_vulkanVisionBlocked;

  /// Lazily initialize the engine (and its backend isolate) once.
  Future<LlamaEngine> _ensureEngine() async {
    if (_engine != null) return _engine!;
    _backend = LlamaBackend();
    _engine = LlamaEngine(_backend!);
    // Enable native llama.cpp logging so model-load errors are visible
    // in logcat / debug console.
    try {
      await _engine!.setNativeLogLevel(LlamaLogLevel.info);
    } catch (e) {
      debugPrint('[LLM] setNativeLogLevel failed: $e');
    }
    return _engine!;
  }

  /// Destroy the current engine completely and allow re-creation.
  Future<void> _resetEngine() async {
    if (_engine != null) {
      try {
        await _engine!.dispose();
      } catch (e) {
        debugPrint('[LLM] engine.dispose() error (ignored): $e');
      }
      _engine = null;
      _backend = null;
    }
    _isLoaded = false;
    _hasVision = false;
    _loadedModelPath = null;
    _engineCrashed = false;
  }

  /// Safely unload model, tolerating errors.
  Future<void> _safeUnload(LlamaEngine engine) async {
    try {
      if (engine.isReady) {
        await engine.unloadModel();
      }
    } catch (e) {
      debugPrint('[LLM] safeUnload error (ignored): $e');
    }
  }

  void _markModelLoaded(String modelPath) {
    _isLoaded = true;
    _hasVision = false; // mmproj must be reloaded after each model load
    _loadedModelPath = modelPath;
  }

  /// Validate that a file starts with the GGUF magic bytes.
  static bool _isValidGguf(File file) {
    try {
      final raf = file.openSync(mode: FileMode.read);
      try {
        final magic = raf.readSync(4);
        if (magic.length < 4) return false;
        return magic[0] == 0x47 &&
            magic[1] == 0x47 &&
            magic[2] == 0x55 &&
            magic[3] == 0x46;
      } finally {
        raf.closeSync();
      }
    } catch (_) {
      return false;
    }
  }

  /// Read GGUF header info: version, tensor count, metadata kv count.
  static Map<String, int> _readGgufHeader(File file) {
    final result = <String, int>{};
    try {
      final raf = file.openSync(mode: FileMode.read);
      try {
        raf.setPositionSync(4); // skip magic
        final bytes = raf.readSync(
            24); // version(4) + tensor_count(8) + metadata_kv_count(8)
        if (bytes.length >= 4) {
          result['version'] =
              bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | (bytes[3] << 24);
        }
        if (bytes.length >= 12) {
          // tensor_count is uint64 LE, but we only need lower 32 bits for practical models
          result['tensor_count'] =
              bytes[4] | (bytes[5] << 8) | (bytes[6] << 16) | (bytes[7] << 24);
        }
        if (bytes.length >= 20) {
          result['metadata_kv_count'] = bytes[12] |
              (bytes[13] << 8) |
              (bytes[14] << 16) |
              (bytes[15] << 24);
        }
      } finally {
        raf.closeSync();
      }
    } catch (_) {}
    return result;
  }

  /// Compute SHA256 of the first 1MB of a file (fast integrity fingerprint).
  static Future<String> _fileHeadHash(File file) async {
    try {
      final raf = file.openSync(mode: FileMode.read);
      try {
        final chunk = raf.readSync(1024 * 1024); // first 1MB
        final digest = sha256.convert(chunk);
        return digest.toString().substring(0, 16); // short hash
      } finally {
        raf.closeSync();
      }
    } catch (_) {
      return 'error';
    }
  }

  /// Resolve the best GPU backend for the current device.
  /// Mirrors the official llamadart example app's _resolveAutoPreferredBackend.
  Future<GpuBackend> _resolveBackend(LlamaEngine engine) async {
    try {
      final info = await engine.getBackendName();
      final lower = info.toLowerCase();
      if (lower.contains('metal')) return GpuBackend.metal;
      if (lower.contains('cuda')) return GpuBackend.cuda;
      if (lower.contains('vulkan')) return GpuBackend.vulkan;
    } catch (_) {}
    return GpuBackend.cpu;
  }

  /// Load a GGUF model into memory.
  ///
  /// Uses a multi-stage fallback strategy, collecting detailed error
  /// information from each stage for diagnostics.
  ///
  /// Returns (success, errorMessage).
  Future<(bool, String?)> loadModel(
    String modelPath, {
    void Function(double progress)? onLoadProgress,
    bool forceCpuOnly = false,
  }) async {
    final diagnostics = StringBuffer();
    final fileName = modelPath.split('/').last;

    try {
      // --- Pre-flight checks ---
      final file = File(modelPath);
      if (!await file.exists()) {
        return (false, '模型文件不存在: $modelPath');
      }

      // If engine previously crashed, force a full reset before reloading
      if (_engineCrashed) {
        debugPrint('[LLM] Engine was in crashed state, performing full reset');
        await _resetEngine();
      }
      final fileSize = await file.length();
      if (fileSize == 0) {
        return (false, '模型文件为空（0字节），请删除后重新下载');
      }
      if (!_isValidGguf(file)) {
        return (
          false,
          '模型文件格式无效（非GGUF），可能下载不完整，请删除后重新下载\n'
              '文件大小: ${formatBytes(fileSize)}'
        );
      }

      // --- GGUF header deep validation ---
      final header = _readGgufHeader(file);
      final ggufVersion = header['version'] ?? 0;
      final tensorCount = header['tensor_count'] ?? -1;
      final metadataKvCount = header['metadata_kv_count'] ?? -1;

      // GGUF v3 is required for llama.cpp b7898+
      if (ggufVersion < 3) {
        return (
          false,
          'GGUF版本过低 (v$ggufVersion)，需要 v3+\n'
              '请下载更新版本的GGUF模型文件'
        );
      }

      // Sanity check: tensor count should be > 0 for any valid model
      if (tensorCount == 0) {
        return (false, '模型文件损坏：tensor数量为0\n请删除后重新下载');
      }

      final headHash = await _fileHeadHash(file);

      diagnostics.writeln('文件: $fileName');
      diagnostics.writeln('大小: ${formatBytes(fileSize)}');
      diagnostics.writeln('路径: $modelPath');
      diagnostics.writeln('GGUF版本: $ggufVersion');
      diagnostics.writeln('Tensor数: $tensorCount');
      diagnostics.writeln('元数据KV数: $metadataKvCount');
      diagnostics.writeln('文件指纹: $headHash');
      diagnostics.writeln('GGUF校验: 通过');
      if (forceCpuOnly) {
        diagnostics.writeln('加载策略: 强制CPU（多模态稳定性模式）');
      }

      // --- CPU feature compatibility check (Android arm64) ---
      final cpuCompatible = await CpuFeatureChecker.isCompatible();
      final socName = CpuFeatureChecker.socInfo;
      if (socName != null) {
        diagnostics.writeln('SoC: $socName');
      }
      diagnostics.writeln('I8MM支持: $cpuCompatible');
      if (!cpuCompatible) {
        _isLoaded = false;
        diagnostics.writeln('');
        diagnostics.writeln('=== CPU不兼容 ===');
        diagnostics.writeln(ErrorMessages.cpuIncompatible);
        final fullDiag = diagnostics.toString();
        debugPrint('[LLM] CPU INCOMPATIBLE:\n$fullDiag');
        return (false, fullDiag);
      }

      // --- Collect engine diagnostics ---
      final engine = await _ensureEngine();

      // Resolve best backend for this device (like official example)
      GpuBackend resolvedBackend = GpuBackend.cpu;
      try {
        resolvedBackend = await _resolveBackend(engine);
        diagnostics.writeln('解析后端: ${resolvedBackend.name}');
      } catch (e) {
        diagnostics.writeln('后端解析失败: $e');
      }

      try {
        final gpuSupported = await engine.isGpuSupported();
        diagnostics.writeln('GPU支持: $gpuSupported');
      } catch (e) {
        diagnostics.writeln('GPU支持: 检测失败 ($e)');
      }
      try {
        final vram = await engine.getVramInfo();
        diagnostics.writeln(
            'VRAM: total=${formatBytes(vram.total)}, free=${formatBytes(vram.free)}');
      } catch (e) {
        diagnostics.writeln('VRAM: 获取失败');
      }

      if (_isLoaded) {
        await _safeUnload(engine);
        _isLoaded = false;
        _hasVision = false;
      }

      // --- Stage 1: Resolved backend (e.g. Vulkan on Android), default context ---
      if (!forceCpuOnly) {
        debugPrint(
            '[LLM] Stage 1: ${resolvedBackend.name}, ctx=${AppConstants.defaultContextSize}');
        try {
          final gpuLayers = resolvedBackend == GpuBackend.cpu ? 0 : 32;
          await engine.loadModel(
            modelPath,
            modelParams: ModelParams(
              contextSize: AppConstants.defaultContextSize,
              preferredBackend: resolvedBackend,
              gpuLayers: gpuLayers,
            ),
          );
          _markModelLoaded(modelPath);
          debugPrint('[LLM] Stage 1 SUCCESS');
          return (true, null);
        } catch (e) {
          final msg = _extractError(e);
          debugPrint('[LLM] Stage 1 FAILED: $msg');
          diagnostics.writeln(
              '--- 阶段1失败 (${resolvedBackend.name}, ctx=${AppConstants.defaultContextSize}) ---');
          diagnostics.writeln(msg);
          await _safeUnload(engine);
        }
      } else {
        diagnostics.writeln('--- 阶段1跳过 (强制CPU模式) ---');
      }

      // --- Stage 2: CPU-only, default context ---
      debugPrint('[LLM] Stage 2: CPU, ctx=${AppConstants.defaultContextSize}');
      try {
        await engine.loadModel(
          modelPath,
          modelParams: const ModelParams(
            contextSize: AppConstants.defaultContextSize,
            gpuLayers: 0,
            preferredBackend: GpuBackend.cpu,
          ),
        );
        _markModelLoaded(modelPath);
        debugPrint('[LLM] Stage 2 SUCCESS');
        return (true, null);
      } catch (e) {
        final msg = _extractError(e);
        debugPrint('[LLM] Stage 2 FAILED: $msg');
        diagnostics.writeln(
            '--- 阶段2失败 (CPU, ctx=${AppConstants.defaultContextSize}) ---');
        diagnostics.writeln(msg);
        await _safeUnload(engine);
      }

      // --- Stage 3: CPU-only, minimal context ---
      debugPrint('[LLM] Stage 3: CPU, ctx=512');
      try {
        await engine.loadModel(
          modelPath,
          modelParams: const ModelParams(
            contextSize: 512,
            gpuLayers: 0,
            preferredBackend: GpuBackend.cpu,
          ),
        );
        _markModelLoaded(modelPath);
        debugPrint('[LLM] Stage 3 SUCCESS');
        return (true, null);
      } catch (e) {
        final msg = _extractError(e);
        debugPrint('[LLM] Stage 3 FAILED: $msg');
        diagnostics.writeln('--- 阶段3失败 (CPU, ctx=512) ---');
        diagnostics.writeln(msg);
        await _safeUnload(engine);
      }

      // --- Stage 4: Full engine reset + CPU-only, minimal context ---
      // This creates a fresh isolate to avoid any stale state from
      // duplicate backend registrations in previous stages.
      debugPrint('[LLM] Stage 4: engine reset + CPU, ctx=512');
      await _resetEngine();
      final freshEngine = await _ensureEngine();
      try {
        await freshEngine.loadModel(
          modelPath,
          modelParams: const ModelParams(
            contextSize: 512,
            gpuLayers: 0,
            preferredBackend: GpuBackend.cpu,
          ),
        );
        _markModelLoaded(modelPath);
        debugPrint('[LLM] Stage 4 SUCCESS');
        return (true, null);
      } catch (e) {
        final msg = _extractError(e);
        debugPrint('[LLM] Stage 4 FAILED: $msg');
        diagnostics.writeln('--- 阶段4失败 (CPU, ctx=512, 引擎重置) ---');
        diagnostics.writeln(msg);
        await _safeUnload(freshEngine);
      }

      // --- All stages failed ---
      _isLoaded = false;
      _loadedModelPath = null;
      diagnostics.writeln('');
      diagnostics.writeln('=== 建议 ===');
      diagnostics.writeln('所有加载方式均失败，可能原因：');
      diagnostics.writeln('1. 模型文件下载损坏 → 删除后重新下载');
      diagnostics.writeln('2. 模型格式不兼容 → 尝试下载以下已验证模型：');
      diagnostics.writeln('   • Qwen3-4B-Q4_K_M (3.0GB)');
      diagnostics.writeln('   • Llama-3.2-3B-Instruct-Q4_K_M (2.1GB)');
      diagnostics.writeln('   • DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M (1.1GB)');
      diagnostics.writeln('   搜索: unsloth 或 ggml-org');
      final fullDiag = diagnostics.toString();
      debugPrint('[LLM] ALL STAGES FAILED:\n$fullDiag');
      return (false, fullDiag);
    } catch (e) {
      _isLoaded = false;
      _loadedModelPath = null;
      final msg = _extractError(e);
      debugPrint('[LLM] Unexpected error: $msg');
      return (false, '加载异常: $msg');
    }
  }

  /// Extract the most useful error message from a (possibly nested) exception.
  static String _extractError(Object e) {
    if (e is LlamaException) {
      // LlamaException has message + optional details (the real cause)
      final details = e.details != null ? ' | details: ${e.details}' : '';
      return '${e.message}$details';
    }
    return e.toString();
  }

  /// Generate a streaming response from the model.
  Stream<String> generateStream(
    List<Message> messages, {
    double temperature = AppConstants.defaultTemperature,
    int maxTokens = AppConstants.defaultMaxTokens,
    double topP = AppConstants.defaultTopP,
    int topK = AppConstants.defaultTopK,
    String systemPrompt = '',
  }) {
    final controller = StreamController<String>();

    if (_engineCrashed) {
      controller.addError(Exception(
        '推理引擎已崩溃，请返回重新加载模型。\n'
        '如果反复崩溃，请尝试禁用图片功能或使用纯文本对话。',
      ));
      controller.close();
      return controller.stream;
    }

    if (!_isLoaded || _engine == null) {
      controller.addError(Exception(ErrorMessages.modelLoadFailed));
      controller.close();
      return controller.stream;
    }

    final hasImageInput =
        messages.any((m) => m.role == MessageRole.user && m.hasImage);
    if (hasImageInput && !_hasVision) {
      controller.addError(Exception('当前模型未启用图片理解能力，请确认已加载匹配的 mmproj 文件'));
      controller.close();
      return controller.stream;
    }
    if (hasImageInput && _vulkanVisionBlocked) {
      controller.addError(Exception(
        '该设备GPU不支持稳定的视觉推理，图片功能已禁用。\n'
        '请使用纯文本对话。',
      ));
      controller.close();
      return controller.stream;
    }

    final chatMessages =
        _buildChatMessages(messages, systemPrompt: systemPrompt);

    final params = GenerationParams(
      temp: temperature,
      topP: topP,
      topK: topK,
      maxTokens: maxTokens,
      penalty: 1.1,
      stopSequences: ['<|im_end|>', '<|end|>', '</s>', '<|eot_id|>'],
    );

    StreamSubscription<String>? sub;
    sub = _engine!
        .create(chatMessages, params: params)
        .map((chunk) => chunk.choices.isEmpty
            ? ''
            : (chunk.choices.first.delta.content ?? ''))
        .listen(
      (token) {
        if (!controller.isClosed && token.isNotEmpty) {
          controller.add(token);
        }
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
      },
      onError: (error) {
        if (!controller.isClosed) {
          final errorStr = error.toString().toLowerCase();
          if (_isVulkanCrashError(errorStr)) {
            // Vulkan DeviceLost — mark vision as blocked and engine as crashed
            _vulkanVisionBlocked = true;
            _engineCrashed = true;
            _isLoaded = false;
            _hasVision = false;
            debugPrint('[LLM] Vulkan DeviceLost detected during inference. '
                'Vision blocked, engine marked crashed. '
                'GPU: ${GpuStabilityChecker.gpuInfo ?? "unknown"}');
            controller.addError(Exception(
              '${ErrorMessages.vulkanVisionCrash}\n'
              'GPU: ${GpuStabilityChecker.gpuInfo ?? "unknown"}',
            ));
          } else if (_isNativeCrashError(errorStr)) {
            // Generic native crash (SIGILL, isolate killed, etc.)
            _engineCrashed = true;
            _isLoaded = false;
            _hasVision = false;
            controller.addError(Exception(
              '${ErrorMessages.inferenceCrashed}\n'
              '可能原因：设备CPU指令集不兼容（缺少I8MM）。\n'
              'SoC: ${CpuFeatureChecker.socInfo ?? "unknown"}',
            ));
          } else {
            controller.addError(error);
          }
          controller.close();
        }
      },
    );

    controller.onCancel = () {
      sub?.cancel();
      stopGeneration();
    };

    return controller.stream;
  }

  /// Check if the error indicates a Vulkan DeviceLost crash.
  static bool _isVulkanCrashError(String errorStr) {
    return errorStr.contains('devicelost') ||
        errorStr.contains('device_lost') ||
        errorStr.contains('device lost') ||
        errorStr.contains('vk::') ||
        errorStr.contains('vulkan');
  }

  /// Check if the error indicates a native isolate/process crash.
  static bool _isNativeCrashError(String errorStr) {
    return errorStr.contains('isolate') ||
        errorStr.contains('killed') ||
        errorStr.contains('signal');
  }

  /// Build llamaDart chat messages from local message history.
  List<LlamaChatMessage> _buildChatMessages(
    List<Message> messages, {
    String systemPrompt = '',
  }) {
    final result = <LlamaChatMessage>[];
    final sysMsg = systemPrompt.isNotEmpty
        ? systemPrompt
        : 'You are a helpful AI assistant.';
    result.add(
      LlamaChatMessage.fromText(
        role: LlamaChatRole.system,
        text: sysMsg,
      ),
    );

    for (final msg in messages) {
      final role = switch (msg.role) {
        MessageRole.user => LlamaChatRole.user,
        MessageRole.assistant => LlamaChatRole.assistant,
        MessageRole.system => LlamaChatRole.system,
      };

      if (msg.role == MessageRole.user && msg.hasImage && _hasVision) {
        final parts = <LlamaContentPart>[
          LlamaTextContent(
            msg.content.trim().isNotEmpty ? msg.content : '请描述这张图片。',
          ),
          LlamaImageContent(path: msg.imagePath!),
        ];
        result.add(LlamaChatMessage.withContent(role: role, content: parts));
        continue;
      }

      result.add(
        LlamaChatMessage.fromText(
          role: role,
          text: msg.content,
        ),
      );
    }

    return result;
  }

  /// Generate a complete (non-streaming) response for a raw prompt.
  /// Used for background tasks like title summarization.
  Future<String> generateOnce(
    String prompt, {
    int maxTokens = 32,
    double temperature = 0.3,
  }) async {
    if (!_isLoaded || _engine == null || _engineCrashed) return '';

    final params = GenerationParams(
      temp: temperature,
      topP: 0.9,
      topK: 40,
      maxTokens: maxTokens,
      penalty: 1.1,
      stopSequences: ['<|im_end|>', '<|end|>', '</s>', '<|eot_id|>', '\n'],
    );

    try {
      final buffer = StringBuffer();
      await for (final token in _engine!.generate(prompt, params: params)) {
        buffer.write(token);
      }
      return buffer.toString().trim();
    } catch (e) {
      debugPrint('[LLM] generateOnce error: $e');
      return '';
    }
  }

  /// Stop current generation.
  void stopGeneration() {
    _engine?.cancelGeneration();
  }

  /// Load a multimodal projector (mmproj) for vision support.
  /// Call after loadModel succeeds. The mmproj file is typically
  /// named like `mmproj-model-f16.gguf` in the same repo.
  Future<(bool, String?)> loadVisionProjector(String mmProjPath) async {
    if (!_isLoaded || _engine == null) {
      return (false, 'Model not loaded');
    }
    if (_vulkanVisionBlocked) {
      return (false, '该设备GPU不支持稳定的Vulkan视觉推理，图片功能已禁用');
    }
    try {
      final file = File(mmProjPath);
      if (!await file.exists()) {
        return (false, 'Vision projector file not found: $mmProjPath');
      }
      if (Platform.isAndroid) {
        // Check GPU stability for vision inference.
        // llamadart v0.6.1 does not expose the mtmd_context_params.use_gpu
        // flag, so the clip vision encoder always uses Vulkan when available.
        // On Adreno GPUs this causes vk::DeviceLostError → SIGABRT during
        // clip_image_batch_encode. Block vision entirely on affected devices.
        final vulkanStable =
            await GpuStabilityChecker.isVulkanStableForVision();
        if (!vulkanStable) {
          debugPrint(
              '[LLM] Adreno/Qualcomm GPU detected (${GpuStabilityChecker.gpuInfo}). '
              'Vulkan vision inference is known to cause DeviceLost crashes. '
              'Blocking vision to prevent fatal SIGABRT.');
          _vulkanVisionBlocked = true;
          return (
            false,
            '该设备GPU（${GpuStabilityChecker.gpuInfo ?? "Adreno"}）的Vulkan驱动'
                '在图像编码时存在已知崩溃问题（DeviceLost），图片功能已禁用。\n'
                '纯文本对话不受影响。'
          );
        }

        final currentModelPath = _loadedModelPath;
        if (currentModelPath == null) {
          return (false, '当前模型路径丢失，无法切换CPU后端后再加载视觉投影器');
        }
        debugPrint(
            '[LLM] Android vision safety mode: resetting engine and reloading model with CPU backend before loading mmproj');
        await _resetEngine();
        final (reloadOk, reloadError) =
            await loadModel(currentModelPath, forceCpuOnly: true);
        if (!reloadOk) {
          return (
            false,
            '为避免Android图像推理崩溃，已尝试切换CPU后端但失败: ${reloadError ?? "未知错误"}'
          );
        }
      }
      await _engine!.loadMultimodalProjector(mmProjPath);
      final supportsVision = await _engine!.supportsVision;
      _hasVision = supportsVision;
      if (!supportsVision) {
        debugPrint(
            '[LLM] Vision projector loaded but model does not report vision support: ${mmProjPath.split('/').last}');
        return (false, '视觉投影器已加载，但当前模型未启用图片理解能力（可能 mmproj 与主模型不匹配）');
      }
      debugPrint(
          '[LLM] Vision projector loaded: ${mmProjPath.split('/').last}');
      return (true, null);
    } catch (e) {
      debugPrint('[LLM] Failed to load vision projector: $e');
      _hasVision = false;
      return (false, 'Vision projector load failed: $e');
    }
  }

  /// Unload the current model but keep the engine/backend alive.
  Future<void> unloadModel() async {
    if (_engine != null && _isLoaded) {
      await _safeUnload(_engine!);
      _isLoaded = false;
      _hasVision = false;
      _loadedModelPath = null;
    }
  }

  /// Fully dispose engine and backend (call only on app shutdown).
  Future<void> dispose() async {
    _isLoaded = false;
    await _resetEngine();
  }
}
