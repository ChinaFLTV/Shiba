import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/data/models/hf_model.dart';
import 'package:shiba/providers/model_providers.dart';
import 'package:shiba/ui/models/model_files_page.dart';

class ModelSearchPage extends ConsumerStatefulWidget {
  const ModelSearchPage({super.key});

  @override
  ConsumerState<ModelSearchPage> createState() => _ModelSearchPageState();
}

class _ModelSearchPageState extends ConsumerState<ModelSearchPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final q = _searchController.text.trim();
    if (q.isNotEmpty) {
      setState(() => _query = q);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索模型'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索 GGUF 模型 (如: llama, qwen, phi)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _performSearch(),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _performSearch,
                  child: const Text('搜索'),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _query.isEmpty
                ? _buildSuggestions(context)
                : _buildResults(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final suggestions = [
      'Qwen2.5-GGUF',
      'Llama-3-GGUF',
      'Phi-3-GGUF',
      'Gemma-GGUF',
      'TinyLlama-GGUF',
      'SmolLM-GGUF',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.travel_explore,
                size: 64, color: colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('从 HuggingFace 镜像搜索 GGUF 模型',
                style: TextStyle(color: colorScheme.outline)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map((s) => ActionChip(
                        label: Text(s),
                        onPressed: () {
                          _searchController.text = s;
                          _performSearch();
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final resultsAsync = ref.watch(hfSearchResultsProvider(_query));

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text('搜索失败: $e', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(hfSearchResultsProvider(_query)),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (models) {
        if (models.isEmpty) {
          return const Center(child: Text('没有找到相关模型'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: models.length,
          itemBuilder: (context, index) =>
              _HfModelTile(model: models[index]),
        );
      },
    );
  }
}

class _HfModelTile extends StatelessWidget {
  final HfModel model;
  const _HfModelTile({required this.model});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ModelFilesPage(model: model)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: icon + name + arrow
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(Icons.smart_toy_outlined,
                        color: colorScheme.onSecondaryContainer, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.displayName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(model.modelId,
                            style: TextStyle(
                                fontSize: 12, color: colorScheme.outline),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: 20, color: colorScheme.outline),
                ],
              ),

              const SizedBox(height: 8),

              // Row 2: metadata chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (model.author != null && model.author!.isNotEmpty)
                    _SearchChip(
                      icon: Icons.person_outline,
                      label: model.author!,
                      color: colorScheme.secondaryContainer,
                      textColor: colorScheme.onSecondaryContainer,
                    ),
                  _SearchChip(
                    icon: Icons.download,
                    label: '${model.downloadsFormatted} 下载',
                    color: colorScheme.surfaceContainerHighest,
                    textColor: colorScheme.onSurface,
                  ),
                  _SearchChip(
                    icon: Icons.favorite,
                    label: '${model.likes}',
                    color: colorScheme.surfaceContainerHighest,
                    textColor: colorScheme.onSurface,
                  ),
                  if (model.pipelineTag != null &&
                      model.pipelineTag!.isNotEmpty)
                    _SearchChip(
                      icon: Icons.category_outlined,
                      label: model.pipelineTag!,
                      color: colorScheme.tertiaryContainer,
                      textColor: colorScheme.onTertiaryContainer,
                    ),
                ],
              ),

              // Row 3: tags (show up to 5)
              if (model.tags.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: model.tags
                      .take(5)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorScheme.outlineVariant,
                                  width: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(tag,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.outline)),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  const _SearchChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: textColor)),
        ],
      ),
    );
  }
}
