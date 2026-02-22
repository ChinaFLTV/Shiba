import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/data/models/local_model.dart';
import 'package:shiba/providers/model_providers.dart';
import 'package:shiba/ui/models/model_search_page.dart';
import 'package:shiba/ui/models/widgets/local_model_tile.dart';

class ModelsPage extends ConsumerWidget {
  const ModelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(localModelsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('模型'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索模型',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModelSearchPage()),
              );
            },
          ),
        ],
      ),
      body: modelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (models) {
          if (models.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_outlined,
                      size: 80,
                      color: colorScheme.outline.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('还没有模型',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: colorScheme.outline)),
                  const SizedBox(height: 8),
                  Text('点击右上角搜索按钮从 HuggingFace 下载模型',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.7))),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ModelSearchPage()),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('搜索模型'),
                  ),
                ],
              ),
            );
          }

          final completed =
              models.where((m) => m.status == ModelStatus.completed).toList();
          final downloading = models
              .where((m) =>
                  m.status == ModelStatus.downloading ||
                  m.status == ModelStatus.paused ||
                  m.status == ModelStatus.pending)
              .toList();
          final failed =
              models.where((m) => m.status == ModelStatus.failed).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              if (downloading.isNotEmpty) ...[
                _SectionHeader(title: '下载中', count: downloading.length),
                ...downloading.map((m) => LocalModelTile(model: m)),
                const SizedBox(height: 16),
              ],
              if (completed.isNotEmpty) ...[
                _SectionHeader(title: '已完成', count: completed.length),
                ...completed.map((m) => LocalModelTile(model: m)),
                const SizedBox(height: 16),
              ],
              if (failed.isNotEmpty) ...[
                _SectionHeader(title: '失败', count: failed.length),
                ...failed.map((m) => LocalModelTile(model: m)),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ModelSearchPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 12,
                    color:
                        Theme.of(context).colorScheme.onPrimaryContainer)),
          ),
        ],
      ),
    );
  }
}
