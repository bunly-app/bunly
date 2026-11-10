import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../../analysis/presentation/sentence_review_screen.dart';
import '../../learning/presentation/learning_widgets.dart';
import '../../ocr/domain/speech_draft.dart';
import '../domain/grammar_catalog.dart';

class GrammarScreen extends ConsumerStatefulWidget {
  const GrammarScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  ConsumerState<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends ConsumerState<GrammarScreen> {
  late final TextEditingController query;
  bool savedOnly = false;
  bool manualRefreshing = false;

  @override
  void initState() {
    super.initState();
    query = TextEditingController(text: ref.read(grammarFilterProvider).query);
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<void> _refreshCatalog() async {
    if (manualRefreshing) return;
    setState(() => manualRefreshing = true);
    try {
      final _ = await ref.refresh(catalogProvider.future);
    } catch (_) {
      // Riverpod exposes AsyncError state cleanly via catalogProvider.
    } finally {
      if (mounted) setState(() => manualRefreshing = false);
    }
  }

  Future<void> _voiceSearch() async {
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      final draft = await ref.read(listenJapaneseSpeechProvider)(
        prompt: 'Hãy đọc mẫu ngữ pháp hoặc từ tiếng Nhật cần tìm...',
      );
      if (!mounted || draft == null) return;
      final spoken = draft.rawText.trim().replaceAll(RegExp(r'[。？！？!]+$'), '');
      if (spoken.isEmpty) return;
      final filter = ref.read(grammarFilterProvider);
      query.text = spoken;
      query.selection = TextSelection.collapsed(offset: spoken.length);
      ref.read(grammarFilterProvider.notifier).state = (
        query: spoken,
        level: filter.level,
        category: filter.category,
      );
      setState(() {});
    } on SpeechException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Chưa nhận diện được giọng nói.')),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(grammarFilterProvider);
    final results = ref.watch(filteredGrammarProvider);
    final summary = ref.watch(learningSummaryProvider);
    final catalog = ref.watch(catalogProvider);
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    const categoryNames = {
      'experience': 'Trải nghiệm',
      'desire': 'Mong muốn',
      'aspect': 'Trạng thái',
      'particles': 'Trợ từ',
      'existence': 'Tồn tại & Sở hữu',
      'tense_negation': 'Thì & Phủ định',
      'adjectives': 'Tính từ',
      'permission': 'Cho phép',
      'prohibition': 'Cấm đoán',
      'obligation': 'Bắt buộc',
      'request_suggestion': 'Đề nghị & Yêu cầu',
      'intention': 'Dự định & Mục đích',
      'simultaneous': 'Song song & Thời điểm',
      'sequence': 'Trình tự',
      'comparison': 'So sánh',
      'ability': 'Khả năng',
      'reason_contrast': 'Nguyên nhân & Tương phản',
      'condition': 'Điều kiện',
      'quoting_noun': 'Trích dẫn & Danh từ hóa',
      'giving_receiving': 'Cho & Nhận',
      'voice_politeness': 'Bị động, Sai khiến & Kính ngữ',
    };
    final categories = <String>{
      ...categoryNames.keys,
      if (filter.category != null) filter.category!,
      ...?catalog.valueOrNull?.points.map((point) => point.category),
    };
    final points = catalog.hasValue && !catalog.hasError
        ? catalog.requireValue.points
        : null;
    final refreshing =
        manualRefreshing || (catalog.isLoading && catalog.hasValue);

    Widget levelFilter() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final level in <String?>[null, 'N5', 'N4'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  level == null
                      ? 'Tất cả'
                      : points == null
                      ? level
                      : '$level (${points.where((p) => p.level == level).length})',
                ),
                selected: filter.level == level,
                onSelected: (_) =>
                    ref.read(grammarFilterProvider.notifier).state = (
                      query: filter.query,
                      level: level,
                      category: filter.category,
                    ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: 'Cấp độ N3 sắp ra mắt',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'N3',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Sắp ra mắt',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget categoryFilter() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Icon(Icons.sell_outlined, size: 16, color: colors.secondary),
          const SizedBox(width: 6),
          for (final category in <String?>[null, ...categories])
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(
                  category == null
                      ? 'Mọi nhóm'
                      : categoryNames[category] ?? category,
                ),
                selected: filter.category == category,
                onSelected: (_) =>
                    ref.read(grammarFilterProvider.notifier).state = (
                      query: filter.query,
                      level: filter.level,
                      category: category,
                    ),
              ),
            ),
        ],
      ),
    );

    return RefreshIndicator(
      onRefresh: _refreshCatalog,
      child: CustomScrollView(
        controller: widget.scrollController,
        key: const PageStorageKey('grammar-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('grammar-search'),
                          controller: query,
                          decoration: InputDecoration(
                            labelText: 'Tìm mẫu hoặc ý nghĩa',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (query.text.isNotEmpty)
                                  IconButton(
                                    tooltip: 'Xóa tìm kiếm',
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      query.clear();
                                      ref
                                          .read(grammarFilterProvider.notifier)
                                          .state = (
                                        query: '',
                                        level: filter.level,
                                        category: filter.category,
                                      );
                                      setState(() {});
                                    },
                                  ),
                                IconButton(
                                  key: const ValueKey('grammar-voice-search'),
                                  tooltip: 'Tìm bằng giọng nói tiếng Nhật',
                                  icon: const Icon(Icons.mic_none_outlined),
                                  color: colors.primary,
                                  onPressed: _voiceSearch,
                                ),
                              ],
                            ),
                          ),
                          onChanged: (value) {
                            ref.read(grammarFilterProvider.notifier).state = (
                              query: value,
                              level: filter.level,
                              category: filter.category,
                            );
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: tones.subtleBorder.withValues(alpha: 0.45),
                          ),
                        ),
                        child: IconButton(
                          tooltip: 'Quét / nhập câu tiếng Nhật',
                          icon: const Icon(Icons.document_scanner_outlined),
                          color: colors.primary,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SentenceReviewScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  levelFilter(),
                  const SizedBox(height: 8),
                  categoryFilter(),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilterChip(
                      avatar: Icon(
                        savedOnly ? Icons.bookmark : Icons.bookmark_border,
                        size: 16,
                        color: savedOnly ? colors.primary : colors.secondary,
                      ),
                      label: const Text('Chỉ mẫu đã lưu'),
                      selected: savedOnly,
                      onSelected: (value) => setState(() => savedOnly = value),
                    ),
                  ),
                  if (catalog.hasValue &&
                      !catalog.hasError &&
                      (refreshing ||
                          catalog.requireValue.origin ==
                              GrammarOrigin.cache)) ...[
                    const SizedBox(height: 12),
                    Material(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: refreshing ? null : _refreshCatalog,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              if (refreshing)
                                SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primary,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.cloud_off_outlined,
                                  size: 16,
                                  color: colors.primary,
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  refreshing
                                      ? 'Đang kiểm tra cập nhật…'
                                      : 'Đang đọc nội dung đã tải trên thiết bị; chưa cập nhật từ máy chủ.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ),
                              if (!refreshing)
                                Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: colors.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (results.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                child: LearningSection(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: colors.error),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Chưa tải được kho ngữ pháp.'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(catalogProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (results.isLoading && !results.hasValue)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
              sliver: SliverToBoxAdapter(
                child: _GrammarListSkeleton(colors: colors, tones: tones),
              ),
            )
          else
            Builder(
              builder: (context) {
                final allPoints = results.requireValue;
                if (savedOnly && (!summary.hasValue || summary.hasError)) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                      child: LearningSection(
                        children: [
                          const Text('Chưa đọc được danh sách đã lưu.'),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                ref.invalidate(learningSummaryProvider),
                            child: const Text('Thử lại danh sách đã lưu'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final visiblePoints = savedOnly
                    ? allPoints
                          .where(
                            (point) =>
                                summary.requireValue.saved.contains(point.id),
                          )
                          .toList()
                    : allPoints;
                if (visiblePoints.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 32),
                      child: LearningSection(
                        children: [Text('Không tìm thấy mẫu phù hợp.')],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                  sliver: SliverList.builder(
                    itemCount: visiblePoints.length + 1,
                    itemBuilder: (context, index) {
                      if (index == visiblePoints.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.tips_and_updates_outlined,
                                  size: 18,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Mẹo nhỏ: Chạm vào một cấu trúc để xem công thức, ví dụ đối chiếu và lưu ghi chú cá nhân.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final point = visiblePoints[index];
                      final data = summary.valueOrNull;
                      final isFirst = index == 0;
                      final isLast = index == visiblePoints.length - 1;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(isFirst ? 16 : 0),
                            bottom: Radius.circular(isLast ? 16 : 0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child:
                              data == null ||
                                  summary.hasError ||
                                  summary.isLoading
                              ? ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 6,
                                  ),
                                  title: Text(
                                    '${point.level} · ${point.pattern}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      point.meaning,
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => openGrammar(context, point),
                                )
                              : GrammarEntry(
                                  point: point,
                                  status: data.statusOf(point.id),
                                  saved: data.saved.contains(point.id),
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _GrammarListSkeleton extends StatelessWidget {
  const _GrammarListSkeleton({required this.colors, required this.tones});

  final ColorScheme colors;
  final BunlyTones tones;

  @override
  Widget build(BuildContext context) {
    final widths = [0.55, 0.45, 0.62, 0.50, 0.58];
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tones.subtleBorder.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < widths.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FractionallySizedBox(
                              widthFactor: widths[i],
                              child: const SkeletonBox(height: 18),
                            ),
                            const SizedBox(height: 8),
                            const FractionallySizedBox(
                              widthFactor: 0.78,
                              child: SkeletonBox(height: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      const SkeletonBox(
                        width: 44,
                        height: 24,
                        borderRadius: 12,
                      ),
                    ],
                  ),
                ),
                if (i < widths.length - 1)
                  Divider(height: 1, color: colors.surfaceContainer),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_sync_outlined, size: 16, color: colors.secondary),
            const SizedBox(width: 8),
            Text(
              'Đang tải cấu trúc từ kho dữ liệu…',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.secondary),
            ),
          ],
        ),
      ],
    );
  }
}
