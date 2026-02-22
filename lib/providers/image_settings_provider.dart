import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/data/database/database_helper.dart';

const _kImageCompressEnabled = 'image_compress_enabled';
const _kImageMaxResolution = 'image_max_resolution';
const _kImageQuality = 'image_quality';

class ImageSettings {
  final bool compressEnabled;
  final int maxResolution; // max width/height in pixels
  final int quality; // 1-100

  const ImageSettings({
    this.compressEnabled = true,
    this.maxResolution = 1024,
    this.quality = 85,
  });
}

final imageSettingsProvider =
    StateNotifierProvider<ImageSettingsNotifier, ImageSettings>(
        (ref) => ImageSettingsNotifier());

class ImageSettingsNotifier extends StateNotifier<ImageSettings> {
  ImageSettingsNotifier() : super(const ImageSettings()) {
    _load();
  }

  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    final enabled = await db.getSetting(_kImageCompressEnabled);
    final res = await db.getSetting(_kImageMaxResolution);
    final q = await db.getSetting(_kImageQuality);
    state = ImageSettings(
      compressEnabled: enabled != 'false',
      maxResolution: res != null ? int.tryParse(res) ?? 1024 : 1024,
      quality: q != null ? int.tryParse(q) ?? 85 : 85,
    );
  }

  Future<void> setCompressEnabled(bool v) async {
    state = ImageSettings(compressEnabled: v, maxResolution: state.maxResolution, quality: state.quality);
    await DatabaseHelper.instance.setSetting(_kImageCompressEnabled, v.toString());
  }

  Future<void> setMaxResolution(int v) async {
    state = ImageSettings(compressEnabled: state.compressEnabled, maxResolution: v, quality: state.quality);
    await DatabaseHelper.instance.setSetting(_kImageMaxResolution, v.toString());
  }

  Future<void> setQuality(int v) async {
    state = ImageSettings(compressEnabled: state.compressEnabled, maxResolution: state.maxResolution, quality: v);
    await DatabaseHelper.instance.setSetting(_kImageQuality, v.toString());
  }
}
