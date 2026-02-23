import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/data/models/conversation.dart';
import 'package:shiba/data/models/local_model.dart';
import 'package:shiba/l10n/app_localizations.dart';
import 'package:shiba/providers/chat_providers.dart';
import 'package:shiba/providers/model_providers.dart';
import 'package:shiba/ui/chat/chat_page.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final localModelsAsync = ref.watch(localModelsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).conversations),
      ),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(S.of(context).loadFailed('$e'))),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 80, color: colorScheme.outline.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(S.of(context).noConversations,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.outline)),
                  const SizedBox(height: 8),
                  Text(S.of(context).tapToStartChat,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline.withValues(alpha: 0.7))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return _ConversationTile(conversation: conv);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewChat(context, ref, localModelsAsync),
        icon: const Icon(Icons.add),
        label: Text(S.of(context).newChat),
      ),
    );
  }

  void _startNewChat(
      BuildContext context, WidgetRef ref, AsyncValue<List<LocalModel>> modelsAsync) {
    final models = modelsAsync.valueOrNull
            ?.where((m) =>
                m.status == ModelStatus.completed &&
                !m.filename.toLowerCase().contains('mmproj'))
            .toList() ??
        [];

    if (models.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).pleaseDownloadModel), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => _ModelSelectionSheet(
        models: models,
        parentContext: context,
      ),
    );
  }
}

class _ModelSelectionSheet extends ConsumerWidget {
  final List<LocalModel> models;
  final BuildContext parentContext;
  const _ModelSelectionSheet({required this.models, required this.parentContext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).selectModel,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: models.map((model) => ListTile(
                leading: const Icon(Icons.smart_toy_outlined),
                title: Text(model.displayName),
                subtitle: Text('${model.fileSizeFormatted} · ${model.repoId}'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onTap: () async {
                  final nav = Navigator.of(parentContext);
                  Navigator.pop(context);
                  ref.read(selectedModelProvider.notifier).state = model;
                  final conv = await ref
                      .read(conversationsProvider.notifier)
                      .createConversation(model.id, model.displayName);
                  ref.read(currentConversationIdProvider.notifier).state =
                      conv.id;
                  if (parentContext.mounted) {
                    nav.push(
                      MaterialPageRoute(
                          builder: (_) => ChatPage(conversation: conv)),
                    );
                  }
                },
              )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  final Conversation conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeAgo = _formatTimeAgo(S.of(context), conversation.updatedAt);

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(S.of(context).deleteConversation),
            content: Text(S.of(context).deleteConversationConfirm),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(S.of(context).cancel)),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(S.of(context).delete)),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref
            .read(conversationsProvider.notifier)
            .deleteConversation(conversation.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.chat, color: colorScheme.onPrimaryContainer, size: 20),
          ),
          title: Text(conversation.title,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${conversation.modelName} · $timeAgo',
              style: TextStyle(color: colorScheme.outline, fontSize: 12)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: () {
            ref.read(currentConversationIdProvider.notifier).state =
                conversation.id;
            // Find and set the model
            final models = ref.read(localModelsProvider).valueOrNull ?? [];
            final model = models
                .where((m) =>
                    m.id == conversation.modelId &&
                    m.status == ModelStatus.completed)
                .firstOrNull;
            if (model == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).modelDeleted(conversation.modelName)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            ref.read(selectedModelProvider.notifier).state = model;
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ChatPage(conversation: conversation)),
            );
          },
          onLongPress: () => _showRenameDialog(context, ref),
        ),
      ),
    );
  }

  static String _formatTimeAgo(S l10n, DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 30) return l10n.daysAgo(diff.inDays);
    return '${dateTime.month}/${dateTime.day}';
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: conversation.title);
    final l10n = S.of(context);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameConversation),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          decoration: InputDecoration(
            hintText: l10n.enterNewTitle,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(ctx, value.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.confirm)),
        ],
      ),
    );
    if (newTitle != null && newTitle.isNotEmpty && newTitle != conversation.title) {
      await ref
          .read(conversationsProvider.notifier)
          .updateTitle(conversation.id, newTitle, updateTime: false);
    }
  }
}
