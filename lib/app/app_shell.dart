import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/grammar/presentation/grammar_screen.dart';
import '../features/learning/presentation/notebook_screen.dart';
import '../features/learning/presentation/profile_screen.dart';
import '../features/learning/presentation/progress_screen.dart';
import '../features/learning/presentation/sync_banner.dart';
import '../features/learning/presentation/today_screen.dart';
import 'bunly_brand.dart';
import 'providers.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int selected = 0;
  final List<ScrollController> _tabControllers = List.generate(
    4,
    (_) => ScrollController(),
  );

  @override
  void dispose() {
    for (final controller in _tabControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void select(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (index == selected) {
      final controller = _tabControllers[index];
      if (controller.hasClients && controller.offset > 0) {
        if (MediaQuery.disableAnimationsOf(context)) {
          controller.jumpTo(0);
        } else {
          controller.animateTo(
            0,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
          );
        }
      }
      return;
    }
    setState(() => selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(configProvider).connected;
    final signOut = ref.watch(signOutControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: selected == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selected != 0) select(0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const BunlyLogoMark(size: 34, borderRadius: 10),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        'Bunly',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: colors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ぶんぽう',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Hồ sơ học tập',
              icon: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 20,
                  color: colors.primary,
                ),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              ),
            ),
            if (connected)
              IconButton(
                tooltip: 'Đăng xuất',
                icon: const Icon(Icons.logout),
                onPressed: signOut.isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(signOutControllerProvider.notifier)
                            .submit();
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chưa thể đăng xuất. Hãy thử lại.'),
                            ),
                          );
                        }
                      },
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    child: connected
                        ? const SyncBanner()
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.offline_pin_outlined,
                                  size: 16,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Chế độ ngoại tuyến · Dữ liệu và ghi chú lưu trên thiết bị.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: selected,
                      children: [
                        TodayScreen(
                          scrollController: _tabControllers[0],
                          onBrowse: () => select(1),
                          onNotebook: () => select(2),
                        ),
                        GrammarScreen(scrollController: _tabControllers[1]),
                        NotebookScreen(
                          scrollController: _tabControllers[2],
                          onBrowse: () => select(1),
                        ),
                        ProgressScreen(scrollController: _tabControllers[3]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          key: const ValueKey('app-navigation'),
          selectedIndex: selected,
          onDestinationSelected: select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: 'Hôm nay',
            ),
            NavigationDestination(icon: Icon(Icons.search), label: 'Tra cứu'),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories),
              label: 'Sổ học',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Tiến độ',
            ),
          ],
        ),
      ),
    );
  }
}
