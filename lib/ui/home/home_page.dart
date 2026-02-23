import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/l10n/app_localizations.dart';
import 'package:shiba/ui/chat/chat_list_page.dart';
import 'package:shiba/ui/models/models_page.dart';
import 'package:shiba/ui/settings/settings_page.dart';

final homeTabProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(homeTabProvider);

    const pages = [
      ChatListPage(),
      ModelsPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: pages[currentTab],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          ref.read(homeTabProvider.notifier).state = index;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined),
            selectedIcon: const Icon(Icons.chat),
            label: S.of(context).tabChat,
          ),
          NavigationDestination(
            icon: const Icon(Icons.model_training_outlined),
            selectedIcon: const Icon(Icons.model_training),
            label: S.of(context).tabModels,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: S.of(context).tabSettings,
          ),
        ],
      ),
    );
  }
}
