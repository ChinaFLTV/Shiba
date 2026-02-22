import 'dart:io';
import 'package:flutter/foundation.dart';

/// Detects Vulkan GPU stability issues on Android devices.
///
/// llamadart v0.6.1 does not expose `mtmd_context_params.use_gpu`, so the
/// clip vision encoder always uses Vulkan when the backend module is loaded.
/// On Android, llamadart unconditionally loads the Vulkan backend module
/// in `_prepareBackendsForModelLoad`.
///
/// This causes `vk::DeviceLostError` → `SIGABRT` during
/// `clip_image_batch_encode` on some Adreno GPU devices. Since SIGABRT
/// kills the entire process (not just the worker isolate), we must
/// prevent vision inference from reaching the Vulkan path on affected GPUs.
///
/// TODO: Remove this workaround when llamadart exposes use_gpu parameter
/// for multimodal context creation.
class GpuStabilityChecker {
  static bool? _cachedVulkanStable;
  static String? _cachedGpuInfo;

  /// Whether Vulkan is considered stable for vision inference on this device.
  /// Returns true on non-Android or when GPU cannot be identified (fail open).
  /// Returns false for Adreno/Qualcomm GPUs with known Vulkan compute issues.
  static Future<bool> isVulkanStableForVision() async {
    if (_cachedVulkanStable != null) return _cachedVulkanStable!;

    if (!Platform.isAndroid) {
      _cachedVulkanStable = true;
      return true;
    }

    try {
      // Collect device GPU info for diagnostics
      final chipResult =
          await Process.run('getprop', ['ro.hardware.chipname']);
      final chipname = chipResult.stdout.toString().trim();

      final platformResult =
          await Process.run('getprop', ['ro.board.platform']);
      final platform = platformResult.stdout.toString().trim();

      final gpuRendererResult =
          await Process.run('getprop', ['ro.hardware.egl']);
      final egl = gpuRendererResult.stdout.toString().trim();

      _cachedGpuInfo = [chipname, platform, egl]
          .where((s) => s.isNotEmpty)
          .join(', ');

      debugPrint('[GPU] chipname=$chipname, platform=$platform, egl=$egl');

      // Adreno GPUs have known Vulkan DeviceLost issues during ggml
      // compute shader dispatch (vk::Queue::submit in clip encoder).
      // Since llamadart always sets use_gpu=true for mtmd and we cannot
      // override it, block vision on Adreno to prevent fatal SIGABRT.
      final combined = '$chipname $platform $egl'.toLowerCase();
      final isAdreno = combined.contains('adreno') ||
          combined.contains('qcom') ||
          combined.contains('qualcomm');

      if (isAdreno) {
        debugPrint('[GPU] Adreno/Qualcomm GPU detected — blocking Vulkan '
            'vision inference to prevent DeviceLost crash');
        _cachedVulkanStable = false;
        return false;
      }

      _cachedVulkanStable = true;
      return true;
    } catch (e) {
      debugPrint('[GPU] Failed to detect GPU info: $e');
      _cachedVulkanStable = true; // fail open
      return true;
    }
  }

  /// Human-readable GPU info string (available after [isVulkanStableForVision]).
  static String? get gpuInfo => _cachedGpuInfo;
}
