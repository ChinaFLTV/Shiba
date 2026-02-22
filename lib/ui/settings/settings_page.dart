import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/app.dart';
import 'package:shiba/core/constants.dart';
import 'package:shiba/providers/service_providers.dart';
import 'package:shiba/providers/tts_providers.dart';
import 'package:shiba/ui/shared/tts_download_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // Appearance section — single dropdown item
          const _SectionTitle(title: '外观'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('主题模式'),
              trailing: DropdownButton<ThemeMode>(
                value: themeMode,
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(12),
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('跟随系统'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('浅色模式'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('深色模式'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(themeModeProvider.notifier).setThemeMode(v);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // TTS section
          const _SectionTitle(title: '语音合成 (TTS)'),
          _TtsModelCard(),
          const SizedBox(height: 4),
          _TtsParamsCard(),

          const SizedBox(height: 16),

          // About section — with ink splash on tap/long-press
          const _SectionTitle(title: '关于'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _AboutTile(
                  icon: Icons.info_outline,
                  title: AppConstants.appName,
                  subtitle: '版本 1.0.0',
                ),
                const Divider(height: 1),
                _AboutTile(
                  icon: Icons.memory,
                  title: '推理引擎',
                  subtitle: 'llama.cpp (llamadart)',
                ),
                const Divider(height: 1),
                _AboutTile(
                  icon: Icons.cloud_outlined,
                  title: '模型来源',
                  subtitle: 'hf-mirror.com (HuggingFace 镜像)',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              'Shiba · 所有推理均在设备上完成',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }
}

/// About section tile with ink splash feedback on tap/long-press
class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Light haptic feedback for a polished feel
        HapticFeedback.lightImpact();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        Clipboard.setData(ClipboardData(text: '$title: $subtitle'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已复制: $subtitle'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _TtsModelCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_TtsModelCard> createState() => _TtsModelCardState();
}

class _TtsModelCardState extends ConsumerState<_TtsModelCard> {
  bool _isReady = false;
  int _modelSize = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final tts = ref.read(ttsServiceProvider);
    final ready = await tts.isModelDownloaded();
    final size = ready ? await tts.getModelSize() : 0;
    if (mounted) {
      setState(() {
        _isReady = ready;
        _modelSize = size;
        _loading = false;
      });
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.record_voice_over_outlined),
            title: const Text('MeloTTS 中英文语音模型'),
            subtitle: _loading
                ? const Text('检查中...')
                : _isReady
                    ? Text('已下载 · ${_formatSize(_modelSize)}')
                    : const Text('未下载 · 约182MB'),
            trailing: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _isReady
                    ? IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: colorScheme.error),
                        tooltip: '删除语音模型',
                        onPressed: () => _confirmDelete(context),
                      )
                    : FilledButton.tonal(
                        onPressed: () => _startDownload(context),
                        child: const Text('下载'),
                      ),
          ),
        ],
      ),
    );
  }

  void _startDownload(BuildContext context) {
    final tts = ref.read(ttsServiceProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TtsDownloadDialog(
        ttsService: tts,
        onComplete: () {
          ref.invalidate(ttsModelReadyProvider);
          _checkStatus();
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除语音模型'),
        content: const Text('确定要删除已下载的TTS语音模型吗？\n删除后朗读功能将不可用，需要重新下载。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final tts = ref.read(ttsServiceProvider);
      await tts.deleteModel();
      ref.invalidate(ttsModelReadyProvider);
      _checkStatus();
    }
  }
}

class _TtsParamsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(ttsSettingsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.speed_outlined, size: 20),
            const SizedBox(width: 8),
            const Text('语速'),
            Expanded(
              child: Slider(
                value: settings.speed,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                label: '${settings.speed.toStringAsFixed(1)}x',
                onChanged: (v) {
                  ref.read(ttsSettingsProvider.notifier).setSpeed(
                        double.parse(v.toStringAsFixed(1)),
                      );
                },
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${settings.speed.toStringAsFixed(1)}x',
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
