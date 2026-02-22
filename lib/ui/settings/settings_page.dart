import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_model/app.dart';
import 'package:local_model/core/constants.dart';

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
          // Appearance section
          const _SectionTitle(title: '外观'),
          Card(
            child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('跟随系统'),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(themeModeProvider.notifier).setThemeMode(v);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('浅色模式'),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(themeModeProvider.notifier).setThemeMode(v);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('深色模式'),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(themeModeProvider.notifier).setThemeMode(v);
                      }
                    },
                  ),
                ],
              ),
          ),

          const SizedBox(height: 16),

          // About section
          const _SectionTitle(title: '关于'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(AppConstants.appName),
                  subtitle: Text('版本 1.0.0'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.memory),
                  title: Text('推理引擎'),
                  subtitle: Text('llama.cpp (llamadart)'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.cloud_outlined),
                  title: Text('模型来源'),
                  subtitle: Text('hf-mirror.com (HuggingFace 镜像)'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              '本地大模型 · 所有推理均在设备上完成',
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
