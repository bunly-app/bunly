import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import 'grammar_detail_screen.dart';
import '../../learning/presentation/profile_screen.dart';
import '../../learning/presentation/sync_banner.dart';
import '../../learning/domain/personal_repository.dart';
import '../data/cached_grammar_repository.dart';

class GrammarScreen extends ConsumerStatefulWidget {
  const GrammarScreen({super.key});
  @override
  ConsumerState<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends ConsumerState<GrammarScreen> {
  bool savedOnly = false;
  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(configProvider).connected;
    final filter = ref.watch(grammarFilterProvider);
    final results = ref.watch(filteredGrammarProvider);
    final summary = ref.watch(learningSummaryProvider);
    final catalog = ref.watch(catalogProvider);
    final repository = ref.watch(grammarRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(connected ? 'Bunly' : 'Bunly · Demo'),
        actions: [
          IconButton(
            tooltip: 'Hồ sơ học tập',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          if (connected)
            IconButton(
              tooltip: 'Đăng xuất',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  await ref.read(authRepositoryProvider).signOut();
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chưa thể đăng xuất. Hãy thử lại.'),
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Kho ngữ pháp',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (!connected)
              const Text('Dữ liệu minh họa · Ghi chú lưu trên thiết bị.'),
            if (connected) const SyncBanner(),
            if (repository is CachedGrammarRepository &&
                repository.lastLoadFromCache)
              const Text(
                'Đang đọc nội dung đã tải trên thiết bị; chưa cập nhật từ máy chủ.',
              ),
            summary.when(
              data: (s) => Wrap(
                spacing: 8,
                children: [
                  for (final status in LearningStatus.values)
                    Text(
                      '${status.label}: ${(catalog.valueOrNull ?? []).where((g) => s.statusOf(g.id) == status).length}',
                    ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Chưa đọc được thống kê.'),
            ),
            FilterChip(
              label: const Text('Chỉ mẫu đã lưu'),
              selected: savedOnly,
              onSelected: (v) => setState(() => savedOnly = v),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm mẫu hoặc ý nghĩa',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) =>
                  ref.read(grammarFilterProvider.notifier).state = (
                    query: query,
                    level: filter.level,
                    category: filter.category,
                  ),
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: filter.level ?? '',
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Mọi cấp độ')),
                      DropdownMenuItem(value: 'N5', child: Text('N5')),
                      DropdownMenuItem(value: 'N4', child: Text('N4')),
                    ],
                    onChanged: (value) =>
                        ref.read(grammarFilterProvider.notifier).state = (
                          query: filter.query,
                          level: value == '' ? null : value,
                          category: filter.category,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: filter.category ?? '',
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Mọi nhóm')),
                      DropdownMenuItem(
                        value: 'experience',
                        child: Text('Trải nghiệm'),
                      ),
                      DropdownMenuItem(
                        value: 'desire',
                        child: Text('Mong muốn'),
                      ),
                      DropdownMenuItem(
                        value: 'aspect',
                        child: Text('Trạng thái'),
                      ),
                    ],
                    onChanged: (value) =>
                        ref.read(grammarFilterProvider.notifier).state = (
                          query: filter.query,
                          level: filter.level,
                          category: value == '' ? null : value,
                        ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: results.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Chưa tải được kho ngữ pháp.'),
                      TextButton(
                        onPressed: () => ref.invalidate(catalogProvider),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
                data: (allPoints) {
                  if (savedOnly && !summary.hasValue) {
                    return const Center(
                      child: Text('Chưa đọc được danh sách đã lưu.'),
                    );
                  }
                  final points = savedOnly
                      ? allPoints
                            .where(
                              (p) => summary.valueOrNull!.saved.contains(p.id),
                            )
                            .toList()
                      : allPoints;
                  return points.isEmpty
                      ? const Center(child: Text('Không tìm thấy mẫu phù hợp.'))
                      : ListView.builder(
                          itemCount: points.length,
                          itemBuilder: (context, index) {
                            final point = points[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  '${point.level} · ${point.pattern}',
                                ),
                                subtitle: Text(point.meaning),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        GrammarDetailScreen(point: point),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
