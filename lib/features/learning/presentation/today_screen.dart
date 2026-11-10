import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../analysis/presentation/sentence_review_screen.dart';
import '../../grammar/domain/grammar_point.dart';
import '../../practice/domain/practice_engine.dart';
import '../../practice/domain/practice_storage.dart';
import '../../practice/presentation/practice_screen.dart';
import '../domain/personal_repository.dart';
import 'learning_widgets.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key, required this.onBrowse, this.scrollController});

  final VoidCallback onBrowse;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(learningOverviewProvider);
    final profile = ref.watch(profileProvider);
    final config = ref.watch(configProvider);
    final dueAsync = ref.watch(dueReviewStatesProvider);
    final questionsAsync = ref.watch(cachedQuestionsProvider);
    final attemptsAsync = ref.watch(practiceAttemptsProvider);

    final dueStates = dueAsync.valueOrNull ?? const <ReviewStateEntry>[];
    final cachedQuestions =
        questionsAsync.valueOrNull ?? const <CuratedPracticeQuestion>[];
    final attempts =
        attemptsAsync.valueOrNull ?? const <PracticeAttemptEntry>[];

    final colors = Theme.of(context).colorScheme;

    return overview.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => LearningError(
        message: 'Chưa đọc được nội dung học hôm nay.',
        onRetry: () {
          ref.invalidate(catalogProvider);
          ref.invalidate(learningSummaryProvider);
        },
      ),
      data: (data) {
        final review = data.withStatus(LearningStatus.review);
        final learning = data.withStatus(LearningStatus.learning);
        final pointById = <String, GrammarPoint>{
          for (final p in data.points) p.id: p,
        };
        final duePoints = [
          for (final state in dueStates)
            if (pointById[state.grammarId] != null)
              (pointById[state.grammarId]!, state),
        ];
        final dueQuestions = selectCuratedPracticeQuestions(
          bank: cachedQuestions,
          source: PracticeSessionSource.dueSrs,
          catalogById: pointById,
          dueReviewStates: dueStates,
          attempts: attempts,
          maxQuestions: 10,
        );
        final anyDueTentative = dueStates.any((s) => s.isTentative);

        return LearningPage(
          storageKey: 'today',
          controller: scrollController,
          children: [
            const PageHeading(
              'Hôm nay',
              'Một mẫu ngữ pháp, một bước học tiếp.',
            ),
            profile.when(
              data: (p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LearningNotice(
                  title: 'Lộ trình ${p.level}',
                  message:
                      'Mục tiêu ${p.level} · ${p.dailyMinutes} phút mỗi ngày',
                  icon: Icons.timer_outlined,
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
              error: (_, _) => Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => ref.invalidate(profileProvider),
                  child: const Text('Chưa đọc được mục tiêu. Thử lại'),
                ),
              ),
            ),
            LearningSection(
              borderColor: colors.primary.withValues(alpha: 0.25),
              borderWidth: 1.5,
              children: [
                if (dueStates.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        '${dueStates.length} mẫu đến hạn ôn (SRS)',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Đến hạn SRS',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colors.onErrorContainer,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    anyDueTentative
                        ? 'Lịch ôn tạm tính trên máy (chờ máy chủ xác nhận khi đồng bộ).'
                        : 'Lịch ôn ngắt quãng xác nhận từ máy chủ.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  for (final (point, _) in duePoints.take(3))
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GrammarEntry(
                        point: point,
                        status: data.summary.statusOf(point.id),
                        saved: data.summary.saved.contains(point.id),
                      ),
                    ),
                  if (duePoints.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      duePoints
                          .take(3)
                          .map(
                            (pair) =>
                                '${pair.$1.pattern}: ${formatSrsStageLabel(pair.$2.stage)}',
                          )
                          .join(' · '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (dueQuestions.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CuratedPracticeSessionScreen(
                            questions: dueQuestions,
                            pool: cachedQuestions,
                            catalogById: pointById,
                            source: PracticeSessionSource.dueSrs,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: Text('Ôn ngay (${dueQuestions.length} câu)'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PracticeSetupScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.fitness_center),
                      label: const Text('Mở bài luyện tập'),
                    ),
                  if (review.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Ngoài ra, bạn tự đánh dấu ${review.length} mẫu ở trạng thái Cần ôn.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ] else ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: review.isEmpty ? colors.primary : colors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        review.isEmpty
                            ? 'Bắt đầu từ một câu quen thuộc'
                            : '${review.length} mẫu bạn đánh dấu cần ôn',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: review.isEmpty
                              ? colors.secondaryContainer
                              : colors.errorContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          review.isEmpty ? 'Gợi ý hôm nay' : 'Ưu tiên 1',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: review.isEmpty
                                    ? colors.onSecondaryContainer
                                    : colors.onErrorContainer,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    review.isEmpty
                        ? 'Mở kho, chọn một mẫu và lưu lại điều bạn muốn ghi nhớ.'
                        : 'Đọc lại cách dùng và ghi chú của bạn. Đây là trạng thái tự đánh giá tách với lịch ôn SRS.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  if (review.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    for (final point in review.take(3))
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GrammarEntry(
                          point: point,
                          status: LearningStatus.review,
                          saved: data.summary.saved.contains(point.id),
                        ),
                      ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onBrowse,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Mở kho ngữ pháp'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if (learning.isNotEmpty) ...[
              LearningSection(
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, size: 18, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mẫu đang học',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final point in learning.take(2))
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GrammarEntry(
                        point: point,
                        status: LearningStatus.learning,
                        saved: data.summary.saved.contains(point.id),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (review.isEmpty &&
                learning.isEmpty &&
                dueStates.isEmpty &&
                data.points.isNotEmpty) ...[
              LearningSection(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Khám phá một mẫu ngữ pháp',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GrammarEntry(
                      point: data.points.first,
                      status: data.summary.statusOf(data.points.first.id),
                      saved: data.summary.saved.contains(data.points.first.id),
                    ),
                  ),
                  if (data.points.first.examples.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    GrammarExamplePanel(
                      example: data.points.first.examples.first,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
            LearningSection(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.document_scanner_outlined,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Học từ câu tiếng Nhật',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Chụp ảnh hoặc nhập câu tiếng Nhật, chỉnh sửa bản nháp rồi phân tích ngữ pháp.',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SentenceReviewScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('Quét ảnh / nhập câu tiếng Nhật'),
                ),
                const SizedBox(height: 8),
                Text(
                  config.connected
                      ? 'OCR chạy ngoại tuyến trên máy. Chỉ văn bản bạn xác nhận mới gửi tới AI để nhận diện ngữ pháp.'
                      : 'OCR chạy ngoại tuyến trên máy và đối chiếu ví dụ cục bộ. Phân tích AI bật ở chế độ kết nối.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LearningSection(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: 20,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Luyện tập nhanh',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  cachedQuestions.isNotEmpty
                      ? 'Ôn tập từ ${cachedQuestions.length} câu biên tập trên máy (hỗ trợ lịch ôn SRS và Sổ lỗi).'
                      : 'Thử trắc nghiệm, điền khuyết, dịch và nói sẵn có trên thiết bị.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PracticeSetupScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Mở bài luyện tập'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 18,
                    color: colors.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mỗi cấu trúc chỉ thực sự ghi nhớ khi bạn lưu ít nhất 1 câu thật từ đời sống.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: colors.secondary),
                    ),
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
