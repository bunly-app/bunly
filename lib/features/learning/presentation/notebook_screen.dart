import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../../grammar/domain/grammar_point.dart';
import '../../practice/presentation/practice_screen.dart';
import '../domain/note.dart';
import '../domain/personal_repository.dart';
import 'learning_widgets.dart';

class NotebookScreen extends ConsumerStatefulWidget {
  const NotebookScreen({
    super.key,
    required this.onBrowse,
    this.scrollController,
  });

  final VoidCallback onBrowse;
  final ScrollController? scrollController;

  @override
  ConsumerState<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends ConsumerState<NotebookScreen> {
  bool showNotes = false;
  String subFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(learningOverviewProvider);
    final notes = ref.watch(notebookNotesProvider);
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);

    return overview.when(
      loading: () => _NotebookSkeleton(
        controller: widget.scrollController,
        colors: colors,
        tones: tones,
      ),
      error: (_, _) => LearningError(
        message: 'Chưa đọc được sổ học.',
        onRetry: () {
          ref.invalidate(catalogProvider);
          ref.invalidate(learningSummaryProvider);
        },
      ),
      data: (data) {
        final loadedNotes =
            notes.hasValue && !notes.hasError && !notes.isLoading
            ? notes.requireValue
            : null;
        final notesByGrammar = <String, List<Note>>{};
        if (loadedNotes != null) {
          for (final note in loadedNotes) {
            notesByGrammar.putIfAbsent(note.grammarId, () => []).add(note);
          }
        }
        final pointById = <String, GrammarPoint>{
          for (final point in data.points) point.id: point,
        };

        final header = <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'TỦ SÁCH TÍCH LŨY · Sổ học cá nhân',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest.withValues(
                          alpha: 0.85,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_done_outlined,
                            size: 13,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Lưu trên máy',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _BannerStatPill(
                      icon: Icons.bookmark_outlined,
                      label: '${data.saved.length} mẫu đã lưu',
                      colors: colors,
                    ),
                    _BannerStatPill(
                      icon: Icons.edit_note_outlined,
                      label: loadedNotes != null
                          ? '${loadedNotes.length} ghi chú'
                          : 'Đang đọc ghi chú',
                      colors: colors,
                    ),
                    _BannerStatPill(
                      icon: Icons.schedule_outlined,
                      label:
                          '${data.saved.where((p) => data.summary.statusOf(p.id) == LearningStatus.review).length} cần ôn',
                      colors: colors,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: Text('Mẫu đã lưu (${data.saved.length})'),
                selected: !showNotes,
                onSelected: (_) => setState(() => showNotes = false),
              ),
              ChoiceChip(
                label: Text(
                  loadedNotes != null
                      ? 'Ghi chú (${loadedNotes.length})'
                      : 'Ghi chú',
                ),
                selected: showNotes,
                onSelected: (_) => setState(() {
                  showNotes = true;
                  if (subFilter == 'Có ghi chú') subFilter = 'Tất cả';
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in [
                  'Tất cả',
                  'N5',
                  'N4',
                  if (!showNotes) 'Có ghi chú',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(filter),
                      selected: subFilter == filter,
                      onSelected: (_) => setState(() => subFilter = filter),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ];

        if (!showNotes && data.saved.isNotEmpty) {
          final saved = data.saved.where((point) {
            if (subFilter == 'N5') return point.level == 'N5';
            if (subFilter == 'N4') return point.level == 'N4';
            if (subFilter == 'Có ghi chú') {
              return (notesByGrammar[point.id] ?? const []).isNotEmpty;
            }
            return true;
          }).toList();

          if (saved.isNotEmpty) {
            return LearningListPage(
              storageKey: 'notebook-saved',
              controller: widget.scrollController,
              header: header,
              itemCount: saved.length,
              footer: _OfflineFooter(colors: colors),
              itemBuilder: (context, index) {
                final point = saved[index];
                final pointNotes = notesByGrammar[point.id] ?? const [];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: tones.subtleBorder.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GrammarEntry(
                          point: point,
                          status: data.summary.statusOf(point.id),
                          saved: true,
                        ),
                        if (point.examples.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          GrammarExamplePanel(example: point.examples.first),
                        ],
                        for (final note in pointNotes.take(1))
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHigh.withValues(
                                alpha: 0.65,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 16,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Ghi nhớ: ${note.content}',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact =
                                constraints.maxWidth < 260 ||
                                MediaQuery.textScalerOf(context).scale(1) >
                                    1.35;
                            if (compact) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        openGrammar(context, point),
                                    icon: const Icon(Icons.edit_note),
                                    label: const Text('Chi tiết và ghi chú'),
                                  ),
                                  const SizedBox(height: 8),
                                  FilledButton.tonalIcon(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => PracticeSetupScreen(
                                          initialGrammarId: point.id,
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(Icons.play_arrow_outlined),
                                    label: const Text('Luyện thử'),
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        openGrammar(context, point),
                                    icon: const Icon(Icons.edit_note, size: 18),
                                    label: const Text(
                                      'Chi tiết và ghi chú',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonalIcon(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => PracticeSetupScreen(
                                        initialGrammarId: point.id,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.play_arrow_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Luyện thử'),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return LearningPage(
            storageKey: 'notebook-saved-filtered-empty',
            controller: widget.scrollController,
            children: [
              ...header,
              LearningSection(
                children: [
                  const Text('Chưa có mẫu đã lưu phù hợp bộ lọc này.'),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => setState(() => subFilter = 'Tất cả'),
                    child: const Text('Xem tất cả mẫu đã lưu'),
                  ),
                ],
              ),
            ],
          );
        }

        if (showNotes && loadedNotes != null && loadedNotes.isNotEmpty) {
          final items = loadedNotes.where((note) {
            final point = pointById[note.grammarId];
            if (subFilter == 'N5') return point?.level == 'N5';
            if (subFilter == 'N4') return point?.level == 'N4';
            return true;
          }).toList();

          if (items.isNotEmpty) {
            return LearningListPage(
              storageKey: 'notebook-notes',
              controller: widget.scrollController,
              header: header,
              itemCount: items.length,
              footer: _OfflineFooter(colors: colors),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NotebookNote(note: items[index], points: data.points),
              ),
            );
          }

          return LearningPage(
            storageKey: 'notebook-notes-filtered-empty',
            controller: widget.scrollController,
            children: [
              ...header,
              LearningSection(
                children: [
                  const Text('Chưa có ghi chú phù hợp bộ lọc này.'),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => setState(() => subFilter = 'Tất cả'),
                    child: const Text('Xem tất cả ghi chú'),
                  ),
                ],
              ),
            ],
          );
        }

        return LearningPage(
          storageKey: showNotes
              ? 'notebook-notes-empty'
              : 'notebook-saved-empty',
          controller: widget.scrollController,
          children: [
            ...header,
            if (!showNotes)
              LearningSection(
                children: [
                  Icon(
                    Icons.bookmark_add_outlined,
                    size: 36,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chưa có mẫu đã lưu. Mở một mẫu trong kho rồi chọn “Lưu mẫu”.',
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: widget.onBrowse,
                    icon: const Icon(Icons.search),
                    label: const Text('Đến kho ngữ pháp'),
                  ),
                ],
              )
            else
              notes.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => LearningSection(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: colors.error),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Chưa đọc được ghi chú.')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(notebookNotesProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại ghi chú'),
                    ),
                  ],
                ),
                data: (_) => LearningSection(
                  children: [
                    Icon(
                      Icons.edit_note_outlined,
                      size: 36,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chưa có ghi chú. Bạn có thể viết ghi chú trong trang chi tiết mẫu.',
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class NotebookNote extends StatelessWidget {
  const NotebookNote({super.key, required this.note, required this.points});
  final Note note;
  final List<GrammarPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    GrammarPoint? point;
    for (final item in points) {
      if (item.id == note.grammarId) {
        point = item;
        break;
      }
    }
    final grammar = point;
    return LearningSection(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (grammar != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  grammar.level,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            Text(
              grammar?.pattern ?? 'Mẫu chưa có trong kho đã tải',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(note.content),
        ),
        const SizedBox(height: 10),
        if (grammar != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => openGrammar(context, grammar),
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Mở mẫu và chỉnh ghi chú'),
            ),
          )
        else
          Text(
            'Ghi chú vẫn được giữ trên máy. Tải lại kho để mở mẫu liên quan.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
      ],
    );
  }
}

class _BannerStatPill extends StatelessWidget {
  const _BannerStatPill({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: colors.surfaceContainerLowest.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

class _OfflineFooter extends StatelessWidget {
  const _OfflineFooter({required this.colors});
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.offline_pin_outlined, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'An tâm học mọi nơi: mẫu đã lưu và ghi chú luôn sẵn sàng trên thiết bị.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    ),
  );
}

class _NotebookSkeleton extends StatelessWidget {
  const _NotebookSkeleton({
    this.controller,
    required this.colors,
    required this.tones,
  });

  final ScrollController? controller;
  final ColorScheme colors;
  final BunlyTones tones;

  @override
  Widget build(BuildContext context) => LearningPage(
    storageKey: 'notebook-loading',
    controller: controller,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sổ học cá nhân',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const SkeletonBox(width: 150, height: 14, borderRadius: 12),
              ],
            ),
          ),
          const SkeletonBox(width: 40, height: 40, borderRadius: 12),
        ],
      ),
      const SizedBox(height: 16),
      for (var i = 0; i < 3; i++) ...[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tones.subtleBorder.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SkeletonBox(width: 38, height: 22, borderRadius: 8),
                  SizedBox(width: 10),
                  SkeletonBox(width: 150, height: 22, highlighted: true),
                ],
              ),
              const SizedBox(height: 10),
              const FractionallySizedBox(
                widthFactor: 0.72,
                child: SkeletonBox(height: 15),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.85,
                      child: SkeletonBox(height: 15, highlighted: true),
                    ),
                    SizedBox(height: 8),
                    FractionallySizedBox(
                      widthFactor: 0.62,
                      child: SkeletonBox(height: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    ],
  );
}
