import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/app.dart';
import 'package:shiba/core/constants.dart';
import 'package:shiba/core/utils.dart';
import 'package:shiba/l10n/app_localizations.dart';
import 'package:shiba/providers/chat_defaults_provider.dart';
import 'package:shiba/providers/image_settings_provider.dart';
import 'package:shiba/providers/service_providers.dart';
import 'package:shiba/providers/tts_providers.dart';
import 'package:shiba/ui/shared/tts_download_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _SectionTitle(title: l10n.appearance),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(l10n.themeMode),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(l10n.themeSystem),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(l10n.themeLight),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(l10n.themeDark),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(themeModeProvider.notifier).setThemeMode(v);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.languageSetting),
                  trailing: DropdownButton<Locale>(
                    value: currentLocale,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    items: supportedAppLocales
                        .map((al) => DropdownMenuItem(
                              value: al.locale,
                              child: Text(al.displayName),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(localeProvider.notifier).setLocale(v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _SectionTitle(title: l10n.ttsSection),
          const _TtsModelCard(),
          const SizedBox(height: 4),
          const _TtsParamsCard(),

          const SizedBox(height: 16),

          _SectionTitle(title: l10n.imageSection),
          const _ImageSettingsCard(),

          const SizedBox(height: 16),

          _SectionTitle(title: l10n.chatDefaultsSection),
          const _ChatDefaultsCard(),

          const SizedBox(height: 16),

          _SectionTitle(title: l10n.aboutSection),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _AboutTile(
                  icon: Icons.info_outline,
                  title: AppConstants.appName,
                  subtitle: l10n.version('1.0.0'),
                ),
                const Divider(height: 1),
                _AboutTile(
                  icon: Icons.memory,
                  title: l10n.inferenceEngine,
                  subtitle: 'llama.cpp (llamadart)',
                ),
                const Divider(height: 1),
                _AboutTile(
                  icon: Icons.cloud_outlined,
                  title: l10n.modelSource,
                  subtitle: l10n.modelSourceValue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              l10n.allInferenceOnDevice,
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.outline),
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

class _ChatDefaultsCard extends ConsumerStatefulWidget {
  const _ChatDefaultsCard();

  @override
  ConsumerState<_ChatDefaultsCard> createState() => _ChatDefaultsCardState();
}

class _ChatDefaultsCardState extends ConsumerState<_ChatDefaultsCard> {
  late final TextEditingController _systemPromptCtrl;
  late double _temperature;
  late int _topK;
  late double _topP;
  late int _maxTokens;
  late int _historyRounds;
  bool _initialized = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _systemPromptCtrl = TextEditingController();
    _apply(ref.read(chatDefaultsProvider));
  }

  void _apply(ChatDefaults settings) {
    _systemPromptCtrl.text = settings.systemPrompt;
    _temperature = settings.temperature;
    _topK = settings.topK;
    _topP = settings.topP;
    _maxTokens = settings.maxTokens;
    _historyRounds = settings.historyRounds;
    _initialized = true;
  }

  bool _matches(ChatDefaults settings) {
    return _systemPromptCtrl.text == settings.systemPrompt &&
        _temperature == settings.temperature &&
        _topK == settings.topK &&
        _topP == settings.topP &&
        _maxTokens == settings.maxTokens &&
        _historyRounds == settings.historyRounds;
  }

  Future<void> _save() async {
    final notifier = ref.read(chatDefaultsProvider.notifier);
    await notifier.save(ChatDefaults(
      systemPrompt: _systemPromptCtrl.text.trim(),
      temperature: _temperature,
      topK: _topK,
      topP: _topP,
      maxTokens: _maxTokens,
      historyRounds: _historyRounds,
    ));
    if (mounted) {
      setState(() => _dirty = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).defaultsSaved),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _restoreDefaults() {
    setState(() {
      _dirty = true;
      _systemPromptCtrl.clear();
      _temperature = AppConstants.defaultTemperature;
      _topK = AppConstants.defaultTopK;
      _topP = AppConstants.defaultTopP;
      _maxTokens = AppConstants.defaultMaxTokens;
      _historyRounds = AppConstants.defaultHistoryRounds;
    });
  }

  @override
  void dispose() {
    _systemPromptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remote = ref.watch(chatDefaultsProvider);
    ref.listen(chatDefaultsProvider, (prev, next) {
      if (!mounted || _dirty) return;
      setState(() {
        _apply(next);
      });
    });

    if (!_initialized || (!_dirty && !_matches(remote))) {
      _apply(remote);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = S.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _systemPromptCtrl,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: l10n.defaultSystemPrompt,
                hintText: l10n.defaultSystemPromptHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (!_dirty) setState(() => _dirty = true);
              },
            ),
            const SizedBox(height: 8),
            _ParamSliderRow(
              label: 'Temperature',
              value: _temperature,
              min: 0,
              max: 2,
              divisions: 20,
              display: _temperature.toStringAsFixed(1),
              onChanged: (v) => setState(() {
                _dirty = true;
                _temperature = v;
              }),
            ),
            _ParamSliderRow(
              label: 'Top K',
              value: _topK.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              display: '$_topK',
              onChanged: (v) => setState(() {
                _dirty = true;
                _topK = v.round();
              }),
            ),
            _ParamSliderRow(
              label: 'Top P',
              value: _topP,
              min: 0,
              max: 1,
              divisions: 20,
              display: _topP.toStringAsFixed(2),
              onChanged: (v) => setState(() {
                _dirty = true;
                _topP = v;
              }),
            ),
            _ParamSliderRow(
              label: l10n.maxGenerationLength,
              value: _maxTokens.toDouble(),
              min: 64,
              max: 4096,
              divisions: 63,
              display: '$_maxTokens',
              onChanged: (v) => setState(() {
                _dirty = true;
                _maxTokens = v.round();
              }),
            ),
            _ParamSliderRow(
              label: l10n.historyRounds,
              value: _historyRounds.toDouble(),
              min: 0,
              max: 20,
              divisions: 20,
              display: _historyRounds == 0 ? l10n.historyRoundsAll : '$_historyRounds',
              onChanged: (v) => setState(() {
                _dirty = true;
                _historyRounds = v.round();
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2, bottom: 8),
              child: Text(
                l10n.historyRoundsHint,
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _restoreDefaults,
                  icon:
                      Icon(Icons.restore, size: 18, color: colorScheme.outline),
                  label: Text(
                    l10n.restoreDefaults,
                    style: TextStyle(fontSize: 13, color: colorScheme.outline),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _dirty ? _save : null,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ParamSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  const _ParamSliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              display,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

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
        HapticFeedback.lightImpact();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        Clipboard.setData(ClipboardData(text: '$title: $subtitle'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).copied(subtitle)),
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
  const _TtsModelCard();

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = S.of(context);

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.record_voice_over_outlined),
            title: Text(l10n.ttsModelTitle),
            subtitle: _loading
                ? Text(l10n.ttsChecking)
                : _isReady
                    ? Text(l10n.ttsDownloaded(formatBytes(_modelSize)))
                    : Text(l10n.ttsNotDownloaded),
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
                        tooltip: l10n.ttsDeleteTitle,
                        onPressed: () => _confirmDelete(context),
                      )
                    : FilledButton.tonal(
                        onPressed: () => _startDownload(context),
                        child: Text(l10n.download),
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
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.ttsDeleteTitle),
        content: Text(l10n.ttsDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
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
  const _TtsParamsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(ttsSettingsProvider);
    final l10n = S.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.speed_outlined, size: 20),
            const SizedBox(width: 8),
            Text(l10n.ttsSpeed),
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

class _ImageSettingsCard extends ConsumerWidget {
  const _ImageSettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageSettingsProvider);
    final notifier = ref.read(imageSettingsProvider.notifier);
    final l10n = S.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.photo_size_select_large_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.compressImage)),
                Switch(
                  value: settings.compressEnabled,
                  onChanged: (v) => notifier.setCompressEnabled(v),
                ),
              ],
            ),
            if (settings.compressEnabled) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 28),
                  Text(l10n.maxResolution, style: const TextStyle(fontSize: 13)),
                  Expanded(
                    child: Slider(
                      value: settings.maxResolution.toDouble(),
                      min: 256,
                      max: 2048,
                      divisions: 7,
                      label: '${settings.maxResolution}px',
                      onChanged: (v) => notifier.setMaxResolution(v.round()),
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    child: Text('${settings.maxResolution}',
                        style: const TextStyle(fontSize: 13),
                        textAlign: TextAlign.end),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 28),
                  Text(l10n.imageQuality, style: const TextStyle(fontSize: 13)),
                  Expanded(
                    child: Slider(
                      value: settings.quality.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 9,
                      label: '${settings.quality}%',
                      onChanged: (v) => notifier.setQuality(v.round()),
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    child: Text('${settings.quality}%',
                        style: const TextStyle(fontSize: 13),
                        textAlign: TextAlign.end),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
