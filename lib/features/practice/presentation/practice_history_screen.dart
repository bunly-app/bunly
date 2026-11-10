import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../../grammar/domain/grammar_point.dart';
import '../../learning/presentation/learning_widgets.dart';
import '../domain/practice_engine.dart';
import '../domain/practice_storage.dart';
import 'practice_screen.dart';

class PracticeHistoryScreen extends ConsumerStatefulWidget {
  const PracticeHistoryScreen({super.key, this.errorsOnly = false});
  final bool errorsOnly;
  @override
  ConsumerState<PracticeHistoryScreen> createState() =>
      _PracticeHistoryScreenState();
}

class _PracticeHistoryScreenState extends ConsumerState<PracticeHistoryScreen> {
  String kind = 'Tất cả';
  String range = '7 ngày qua';
  String errorCategory = 'Tất cả';
  bool showSample = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final errorsOnly = widget.errorsOnly;

    final config = ref.watch(configProvider);
    final attemptsAsync = ref.watch(practiceAttemptsProvider);
    final questionsAsync = ref.watch(cachedQuestionsProvider);
    final catalogAsync = ref.watch(catalogProvider);
    final reviewAsync = ref.watch(reviewStatesProvider);

    final allAttempts =
        attemptsAsync.valueOrNull ?? const <PracticeAttemptEntry>[];
    final bank =
        questionsAsync.valueOrNull ?? const <CuratedPracticeQuestion>[];
    final questionsById = {for (final q in bank) q.id: q};
    final catalogById = <String, GrammarPoint>{
      for (final p
          in catalogAsync.valueOrNull?.points ?? const <GrammarPoint>[])
        p.id: p,
    };
    final reviewStates = reviewAsync.valueOrNull ?? const <ReviewStateEntry>[];
    final nowUtc = DateTime.now().toUtc();

    final analytics = computePracticeAnalytics(
      attempts: allAttempts,
      reviewStates: reviewStates,
      nowUtc: nowUtc,
    );
    final outcomes = computeQuestionOutcomes(allAttempts);
    final visibleAttempts = filterPracticeHistory(
      attempts: allAttempts,
      questionsById: questionsById,
      nowUtc: nowUtc,
      errorsOnly: errorsOnly,
      kindFilter: kind,
      rangeFilter: range,
      errorFilter: errorCategory,
      unresolvedQuestionIds: analytics.unresolvedQuestionIds,
    );

    final retryBankQuestions = bank
        .where((q) => analytics.unresolvedQuestionIds.contains(q.id))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(errorsOnly ? 'Sổ lỗi cần ôn' : 'Lịch sử bài làm'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: LearningPage(
            storageKey: errorsOnly ? 'practice-errors' : 'practice-history',
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      config.connected
                          ? Icons.sync_outlined
                          : Icons.storage_outlined,
                      size: 16,
                      color: colors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorsOnly
                            ? (config.connected
                                  ? 'Sổ lỗi cá nhân · Lưu trên máy & đồng bộ'
                                  : 'Sổ lỗi cá nhân · Dữ liệu lưu trên thiết bị')
                            : (config.connected
                                  ? 'Nhật ký bài làm · Lưu trên máy & đồng bộ'
                                  : 'Nhật ký bài làm · Dữ liệu lưu trên thiết bị'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (errorsOnly) ...[
                _ErrorOverviewBanner(
                  colors: colors,
                  tones: tones,
                  unresolvedCount: analytics.unresolvedErrorCount,
                  weakGroupCount: analytics.weakGrammars.length,
                  resolvedCount: analytics.resolvedErrorCount,
                  hasData: allAttempts.isNotEmpty,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final cat in [
                        'Tất cả',
                        'Chưa khắc phục',
                        'Trắc nghiệm',
                        'Điền khuyết',
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: errorCategory == cat,
                            onSelected: (_) =>
                                setState(() => errorCategory = cat),
                          ),
                        ),
                    ],
                  ),
                ),
                if (retryBankQuestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CuratedPracticeSessionScreen(
                          questions: retryBankQuestions,
                          pool: bank,
                          catalogById: catalogById,
                          source: PracticeSessionSource.weakMistakes,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.replay),
                    label: Text(
                      'Ôn lại ngay (${retryBankQuestions.length} câu chưa khắc phục)',
                    ),
                  ),
                ],
              ] else ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final value in [
                        'Tất cả',
                        'MCQ & Điền từ',
                        'Dịch',
                        'Nói',
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(value),
                            selected: kind == value,
                            onSelected: (_) => setState(() => kind = value),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final period in [
                        'Hôm nay',
                        '7 ngày qua',
                        'Tháng này',
                        'Tất cả',
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(period),
                            selected: range == period,
                            onSelected: (_) => setState(() => range = period),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (visibleAttempts.isNotEmpty) ...[
                for (final attempt in visibleAttempts) ...[
                  _AttemptRecordCard(
                    attempt: attempt,
                    question: questionsById[attempt.questionId],
                    grammar: catalogById[attempt.grammarId],
                    outcome: outcomes[attempt.questionId],
                    colors: colors,
                    tones: tones,
                  ),
                  const SizedBox(height: 10),
                ],
              ] else ...[
                LearningSection(
                  children: [
                    const SizedBox(height: 6),
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: tones.primaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          errorsOnly ? Icons.rule_outlined : Icons.history,
                          size: 32,
                          color: tones.onPrimaryFixed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      allAttempts.isEmpty
                          ? (errorsOnly
                                ? 'Chưa có dữ liệu sổ lỗi'
                                : 'Chưa có bài làm đã lưu')
                          : (kind == 'Dịch' || kind == 'Nói') && !errorsOnly
                          ? 'Chưa có nhật ký cho mục "$kind"'
                          : 'Không có bản ghi phù hợp bộ lọc',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      allAttempts.isEmpty
                          ? (errorsOnly
                                ? 'Bộ lọc: $errorCategory. Khi bạn làm bài luyện tập chuẩn trên máy, các câu làm sai sẽ tự động tổng hợp tại đây.'
                                : 'Bộ lọc: $kind · $range. Hãy mở bài luyện tập chuẩn để lưu nhật ký bài làm đầu tiên.')
                          : (kind == 'Dịch' || kind == 'Nói') && !errorsOnly
                          ? 'Luyện Dịch AI và Nói ASR chưa kết nối lưu nhật ký; hãy chọn "Tất cả" hoặc "MCQ & Điền từ" để xem ${allAttempts.length} lượt đã làm.'
                          : 'Thử mở rộng khoảng thời gian hoặc đổi bộ lọc để xem ${allAttempts.length} lượt đã lưu.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PracticeSetupScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Mở bài luyện tập'),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ],
              if (allAttempts.isEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: tones.subtleBorder.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () => setState(() => showSample = !showSample),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      errorsOnly
                                          ? 'Xem bố cục thẻ Sổ lỗi (Minh họa)'
                                          : 'Xem bố cục thẻ nhật ký (Minh họa)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Dữ liệu mẫu thiết kế, không phải hồ sơ của bạn',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                showSample
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showSample)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _DiffSampleCard(
                            errorsOnly: errorsOnly,
                            colors: colors,
                            tones: tones,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.offline_pin_outlined, color: colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorsOnly
                            ? 'Khi phát hiện câu trả lời sai trong lần làm đầu, Sổ lỗi tổng hợp lại theo mẫu để bạn ôn nhanh.'
                            : 'Lịch sử bài làm lưu cục bộ trên máy theo tài khoản và đồng bộ khi kết nối mạng.',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttemptRecordCard extends StatelessWidget {
  const _AttemptRecordCard({
    required this.attempt,
    required this.question,
    required this.grammar,
    required this.outcome,
    required this.colors,
    required this.tones,
  });

  final PracticeAttemptEntry attempt;
  final CuratedPracticeQuestion? question;
  final GrammarPoint? grammar;
  final QuestionHistoryOutcome? outcome;
  final ColorScheme colors;
  final BunlyTones tones;

  @override
  Widget build(BuildContext context) {
    final ts = attempt.canonicalOrderTimestamp.toLocal();
    final hh = ts.hour.toString().padLeft(2, '0');
    final mm = ts.minute.toString().padLeft(2, '0');
    final timeStr = '${ts.day}/${ts.month} $hh:$mm';

    final String statusLabel;
    final Color statusBg;
    final Color statusFg;
    if (attempt.isSkipped) {
      statusLabel = 'Bỏ qua';
      statusBg = colors.surfaceContainerHigh;
      statusFg = colors.onSurfaceVariant;
    } else if (attempt.isCorrect) {
      statusLabel = attempt.isFirstIndependent
          ? 'Đúng lần đầu'
          : 'Thử lại đúng';
      statusBg = tones.statusMasteredBg;
      statusFg = tones.statusMasteredFg;
    } else {
      statusLabel = attempt.isFirstIndependent ? 'Sai lần đầu' : 'Thử lại sai';
      statusBg = colors.errorContainer;
      statusFg = colors.onErrorContainer;
    }

    final acceptedDisplay = question == null
        ? null
        : (question!.type == PracticeBankType.mcq &&
                  question!.correctOptionIndex != null
              ? question!.options[question!.correctOptionIndex!]
              : question!.acceptedAnswers.join(' / '));

    return LearningSection(
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              grammar != null
                  ? '${grammar!.level} · ${grammar!.pattern}'
                  : attempt.grammarId,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: statusFg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              question?.type == PracticeBankType.mcq
                  ? 'Trắc nghiệm · $timeStr'
                  : question?.type == PracticeBankType.cloze
                  ? 'Điền khuyết · $timeStr'
                  : 'Câu hỏi · $timeStr',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (outcome?.isCurrentlyResolved == true && !attempt.isCorrect)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tones.statusLearningBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Đã khắc phục',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tones.statusLearningFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        if (question != null) ...[
          const SizedBox(height: 8),
          Text(
            question!.prompt,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
        if (!attempt.isSkipped && attempt.answerText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: attempt.isCorrect
                  ? tones.statusMasteredBg.withValues(alpha: 0.45)
                  : colors.errorContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu trả lời của bạn: ${attempt.answerText}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: attempt.isCorrect
                        ? tones.statusMasteredFg
                        : colors.onErrorContainer,
                  ),
                ),
                if (!attempt.isCorrect && acceptedDisplay != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Đáp án chuẩn: $acceptedDisplay',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: tones.statusLearningFg,
                    ),
                  ),
                ],
                if (question != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    question!.explanationVi,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorOverviewBanner extends StatelessWidget {
  const _ErrorOverviewBanner({
    required this.colors,
    required this.tones,
    required this.unresolvedCount,
    required this.weakGroupCount,
    required this.resolvedCount,
    required this.hasData,
  });

  final ColorScheme colors;
  final BunlyTones tones;
  final int unresolvedCount;
  final int weakGroupCount;
  final int resolvedCount;
  final bool hasData;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: tones.subtleBorder.withValues(alpha: 0.35)),
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
              '$unresolvedCount lỗi cần ôn',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hasData ? 'Tổng hợp tự động' : 'Chưa có bài làm',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _MiniCountBadge(
              icon: Icons.priority_high_rounded,
              label: '$weakGroupCount nhóm ưu tiên',
              bg: colors.errorContainer,
              fg: colors.onErrorContainer,
            ),
            _MiniCountBadge(
              icon: Icons.check_circle_outline,
              label: '$resolvedCount đã khắc phục',
              bg: tones.statusLearningBg,
              fg: tones.statusLearningFg,
            ),
          ],
        ),
      ],
    ),
  );
}

class _MiniCountBadge extends StatelessWidget {
  const _MiniCountBadge({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DiffSampleCard extends StatelessWidget {
  const _DiffSampleCard({
    required this.errorsOnly,
    required this.colors,
    required this.tones,
  });

  final bool errorsOnly;
  final ColorScheme colors;
  final BunlyTones tones;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: tones.subtleBorder.withValues(alpha: 0.35)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Minh họa UI',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              errorsOnly ? '〜たことがある · N5' : 'Dịch Việt → Nhật · 〜たことがある',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.errorContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Câu bạn đã nộp (ví dụ):',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '日本に行くことがあります。',
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tones.statusLearningBg.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bản sửa chuẩn xác (ví dụ):',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tones.statusLearningFg,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '日本に行ったことがあります。',
                style: TextStyle(
                  color: tones.statusLearningFg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
