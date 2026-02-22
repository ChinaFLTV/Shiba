import 'dart:io';
import 'package:flutter/foundation.dart';

/// Checks ARM CPU feature flags to detect compatibility with the bundled
/// llama.cpp native library (which requires I8MM / ARMv8.6-A on arm64).
///
/// The prebuilt libggml-cpu.so in llamadart uses SMMLA/UMMLA instructions
/// (Int8 Matrix Multiply, part of ARMv8.6-A). Devices with older SoCs
/// (e.g. Snapdragon 860 / Kryo 585) lack I8MM and will crash with SIGILL
/// during ggml_graph_compute.
class CpuFeatureChecker {
  static bool? _cachedResult;
  static String? _cachedSocInfo;

  /// Whether the CPU supports the I8MM feature required by the native library.
  /// Returns true if compatible, false if known-incompatible, true if unknown
  /// (non-Android or read failure — fail open to avoid blocking capable devices).
  static Future<bool> isCompatible() async {
    if (_cachedResult != null) return _cachedResult!;

    if (!Platform.isAndroid) {
      _cachedResult = true;
      return true;
    }

    try {
      final cpuinfo = await File('/proc/cpuinfo').readAsString();
      // ARM64 Linux exposes "Features :" line with hwcap names.
      // We need "i8mm" for the SMMLA/UMMLA instructions used by ggml-cpu.
      final featuresLine = cpuinfo
          .split('\n')
          .where((line) => line.startsWith('Features'))
          .firstOrNull;

      if (featuresLine == null) {
        // Can't determine — fail open
        debugPrint('[CPU] No Features line in /proc/cpuinfo, assuming compatible');
        _cachedResult = true;
        return true;
      }

      final features = featuresLine.toLowerCase();
      final hasI8mm = features.contains('i8mm');

      // Extract SoC info for diagnostics
      final hardwareLine = cpuinfo
          .split('\n')
          .where((line) => line.startsWith('Hardware'))
          .firstOrNull;
      _cachedSocInfo = hardwareLine?.split(':').last.trim();

      debugPrint('[CPU] Features: $featuresLine');
      debugPrint('[CPU] Hardware: ${_cachedSocInfo ?? "unknown"}');
      debugPrint('[CPU] I8MM support: $hasI8mm');

      _cachedResult = hasI8mm;
      return hasI8mm;
    } catch (e) {
      debugPrint('[CPU] Failed to read /proc/cpuinfo: $e');
      _cachedResult = true; // fail open
      return true;
    }
  }

  /// Human-readable SoC name (if available after [isCompatible] call).
  static String? get socInfo => _cachedSocInfo;
}
