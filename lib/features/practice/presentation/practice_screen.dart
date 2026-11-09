import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../../auth/domain/auth_repository.dart';
import '../../grammar/domain/grammar_point.dart';
import '../../grammar/presentation/grammar_detail_screen.dart';
import '../../learning/presentation/learning_widgets.dart';
import '../domain/demo_practice.dart';
import '../domain/practice_engine.dart';
import '../domain/practice_storage.dart';
import 'practice_history_screen.dart';
import 'writing_practice_screen.dart';

class PracticeSetupScreen extends ConsumerStatefulWidget {
  const PracticeSetupScreen({super.key, this.initialGrammarId});

  final String? initialGrammarId;

  @override
  ConsumerState<PracticeSetupScreen> createState() =>
      _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends ConsumerState<PracticeSetupScreen> {
  final Set<PracticeKind> demoKinds = {...PracticeKind.values};
  final Set<PracticeBankType> curatedTypes = {...PracticeBankType.values};

  PracticeSessionSource? _selectedSource;
  String? _selectedGrammarId;
  String? _levelFilter;
  int _maxQuestions = 10;
  bool _syncingBank = false;
  String? _syncError;

  @override
  void initState() {
    super.initState();
    _selectedGrammarId = widget.initialGrammarId;
  }

  Future<void> _syncQuestionBank() async {
    final sync = ref.read(practiceSyncProvider);
    if (sync == null || _syncingBank) return;
    setState(() {
      _syncingBank = true;
      _syncError = null;
    });
    try {
      await sync.run();
      if (mounted) {
        ref.invalidate(cachedQuestionsProvider);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _syncError =
              'Chưa đồng bộ được ngân hàng câu hỏi. Hãy thử lại khi có mạng.',
        );
      }
    } finally {
      if (mounted) setState(() => _syncingBank = false);
    }
  }

  PracticeSessionSource _resolveSource({
    required List<CuratedPracticeQuestion> bank,
    required Map<String, GrammarPoint> catalogById,
    required List<ReviewStateEntry> dueStates,
    required List<PracticeAttemptEntry> attempts,
  }) {
    if (_selectedSource != null) return _selectedSource!;
    if (widget.initialGrammarId != null &&
        bank.any((q) => q.grammarId == widget.initialGrammarId)) {
      return PracticeSessionSource.byGrammar;
    }
    if (dueStates.isNotEmpty) {
      final dueQuestions = selectCuratedPracticeQuestions(
        bank: bank,
        source: PracticeSessionSource.dueSrs,
        catalogById: catalogById,
        dueReviewStates: dueStates,
        attempts: attempts,
        maxQuestions: bank.length,
      );
      if (dueQuestions.isNotEmpty) return PracticeSessionSource.dueSrs;
    }
    final weakQuestions = selectCuratedPracticeQuestions(
      bank: bank,
      source: PracticeSessionSource.weakMistakes,
      catalogById: catalogById,
      dueReviewStates: dueStates,
      attempts: attempts,
      maxQuestions: bank.length,
    );
    if (weakQuestions.isNotEmpty) return PracticeSessionSource.weakMistakes;
    return PracticeSessionSource.custom;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final config = ref.watch(configProvider);
    final catalogAsync = ref.watch(catalogProvider);
    final bankAsync = ref.watch(cachedQuestionsProvider);
    final dueAsync = ref.watch(dueReviewStatesProvider);
    final attemptsAsync = ref.watch(practiceAttemptsProvider);

    final catalogById = <String, GrammarPoint>{
      for (final p
          in catalogAsync.valueOrNull?.points ?? const <GrammarPoint>[])
        p.id: p,
    };
    final bank = bankAsync.valueOrNull ?? const <CuratedPracticeQuestion>[];
    final dueStates = dueAsync.valueOrNull ?? const <ReviewStateEntry>[];
    final attempts =
        attemptsAsync.valueOrNull ?? const <PracticeAttemptEntry>[];

    if (bank.isNotEmpty) {
      return _buildCuratedSetup(
        context: context,
        colors: colors,
        tones: tones,
        configConnected: config.connected,
        bank: bank,
        catalogById: catalogById,
        dueStates: dueStates,
        attempts: attempts,
      );
    }

    return _buildFallbackDemoSetup(
      context: context,
      colors: colors,
      tones: tones,
      configConnected: config.connected,
      isBankLoading: bankAsync.isLoading,
      dueCount: dueStates.length,
      targetPoint: _selectedGrammarId != null
          ? catalogById[_selectedGrammarId]
          : null,
    );
  }

  Widget _buildCuratedSetup({
    required BuildContext context,
    required ColorScheme colors,
    required BunlyTones tones,
    required bool configConnected,
    required List<CuratedPracticeQuestion> bank,
    required Map<String, GrammarPoint> catalogById,
    required List<ReviewStateEntry> dueStates,
    required List<PracticeAttemptEntry> attempts,
  }) {
    final activeSource = _resolveSource(
      bank: bank,
      catalogById: catalogById,
      dueStates: dueStates,
      attempts: attempts,
    );

    final grammarIdsInBank = bank.map((q) => q.grammarId).toSet().toList()
      ..sort();
    final activeGrammarId =
        (_selectedGrammarId != null &&
            grammarIdsInBank.contains(_selectedGrammarId))
        ? _selectedGrammarId
        : grammarIdsInBank.first;

    final dueQuestionsAll = selectCuratedPracticeQuestions(
      bank: bank,
      source: PracticeSessionSource.dueSrs,
      catalogById: catalogById,
      dueReviewStates: dueStates,
      attempts: attempts,
      maxQuestions: bank.length,
    );
    final weakQuestionsAll = selectCuratedPracticeQuestions(
      bank: bank,
      source: PracticeSessionSource.weakMistakes,
      catalogById: catalogById,
      dueReviewStates: dueStates,
      attempts: attempts,
      maxQuestions: bank.length,
    );
    final byGrammarAll = selectCuratedPracticeQuestions(
      bank: bank,
      source: PracticeSessionSource.byGrammar,
      grammarId: activeGrammarId,
      catalogById: catalogById,
      dueReviewStates: dueStates,
      attempts: attempts,
      maxQuestions: bank.length,
    );

    final poolForSelectedSource = selectCuratedPracticeQuestions(
      bank: bank,
      source: activeSource,
      grammarId: activeGrammarId,
      level: activeSource == PracticeSessionSource.custom ? _levelFilter : null,
      catalogById: catalogById,
      dueReviewStates: dueStates,
      attempts: attempts,
      maxQuestions: bank.length,
    );

    final mcqCount = poolForSelectedSource
        .where((q) => q.type == PracticeBankType.mcq)
        .length;
    final clozeCount = poolForSelectedSource
        .where((q) => q.type == PracticeBankType.cloze)
        .length;

    final sessionQuestions = selectCuratedPracticeQuestions(
      bank: bank,
      source: activeSource,
      grammarId: activeGrammarId,
      level: activeSource == PracticeSessionSource.custom ? _levelFilter : null,
      catalogById: catalogById,
      dueReviewStates: dueStates,
      attempts: attempts,
      allowedTypes: curatedTypes,
      maxQuestions: _maxQuestions,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn phiên luyện tập')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: LearningPage(
            storageKey: 'practice-setup-curated',
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: tones.subtleBorder.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tones.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        color: tones.onPrimaryFixed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kho bài tập biên tập chuẩn (${bank.length} câu)',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            configConnected
                                ? 'Kết quả lần làm đầu được lưu trên máy, cập nhật lịch ôn SRS tạm tính và đồng bộ khi có mạng.'
                                : 'Bài làm lưu trên thiết bị và cập nhật lịch ôn SRS cục bộ cho tài khoản hiện tại.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const PageHeading(
                'Nguồn bài luyện',
                'Chạm để chọn nguồn câu hỏi phù hợp mục tiêu ôn tập.',
              ),
              LearningSection(
                children: [
                  _SelectableSourceTile(
                    icon: Icons.schedule_outlined,
                    title: 'Đến hạn ôn (SRS)',
                    subtitle: dueStates.isEmpty
                        ? 'Hiện chưa có mẫu nào đến hạn ôn theo lịch SRS.'
                        : '${dueStates.length} mẫu đến hạn · ${dueQuestionsAll.length} câu sẵn sàng',
                    selected: activeSource == PracticeSessionSource.dueSrs,
                    enabled: dueQuestionsAll.isNotEmpty,
                    badge: dueStates.isNotEmpty ? 'Ưu tiên' : null,
                    colors: colors,
                    onTap: () => setState(
                      () => _selectedSource = PracticeSessionSource.dueSrs,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SelectableSourceTile(
                    icon: Icons.rule_folder_outlined,
                    title: 'Điểm yếu từ Sổ lỗi',
                    subtitle: weakQuestionsAll.isEmpty
                        ? 'Chưa có câu sai chưa khắc phục trong lịch sử.'
                        : '${weakQuestionsAll.length} câu thuộc mẫu từng làm sai',
                    selected:
                        activeSource == PracticeSessionSource.weakMistakes,
                    enabled: weakQuestionsAll.isNotEmpty,
                    colors: colors,
                    onTap: () => setState(
                      () =>
                          _selectedSource = PracticeSessionSource.weakMistakes,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SelectableSourceTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Theo mẫu đang chọn',
                    subtitle: catalogById[activeGrammarId] != null
                        ? '${catalogById[activeGrammarId]!.level} · ${catalogById[activeGrammarId]!.pattern} (${byGrammarAll.length} câu)'
                        : '$activeGrammarId (${byGrammarAll.length} câu)',
                    selected: activeSource == PracticeSessionSource.byGrammar,
                    enabled: byGrammarAll.isNotEmpty,
                    colors: colors,
                    onTap: () => setState(
                      () => _selectedSource = PracticeSessionSource.byGrammar,
                    ),
                  ),
                  if (activeSource == PracticeSessionSource.byGrammar &&
                      grammarIdsInBank.length > 1) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final gId in grammarIdsInBank)
                          ChoiceChip(
                            label: Text(catalogById[gId]?.pattern ?? gId),
                            selected: activeGrammarId == gId,
                            onSelected: (_) =>
                                setState(() => _selectedGrammarId = gId),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  _SelectableSourceTile(
                    icon: Icons.tune_outlined,
                    title: 'Tự chọn theo cấp độ',
                    subtitle: 'Lọc N5 / N4 trên toàn kho bài tập đã tải về máy',
                    selected: activeSource == PracticeSessionSource.custom,
                    enabled: true,
                    colors: colors,
                    onTap: () => setState(
                      () => _selectedSource = PracticeSessionSource.custom,
                    ),
                  ),
                  if (activeSource == PracticeSessionSource.custom) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final lvl in <String?>[null, 'N5', 'N4'])
                          ChoiceChip(
                            label: Text(lvl ?? 'Tất cả cấp độ'),
                            selected: _levelFilter == lvl,
                            onSelected: (_) =>
                                setState(() => _levelFilter = lvl),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Dạng bài & Quy mô phiên',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              LearningSection(
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: curatedTypes.contains(PracticeBankType.mcq),
                    title: Text(
                      'Trắc nghiệm ngữ cảnh ($mcqCount câu)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Chọn đáp án đúng theo ngữ cảnh'),
                    onChanged: (value) => setState(() {
                      if (value == true) {
                        curatedTypes.add(PracticeBankType.mcq);
                      } else {
                        curatedTypes.remove(PracticeBankType.mcq);
                      }
                    }),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: curatedTypes.contains(PracticeBankType.cloze),
                    title: Text(
                      'Điền khuyết ($clozeCount câu)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Điền bằng ngân hàng từ hoặc gõ IME'),
                    onChanged: (value) => setState(() {
                      if (value == true) {
                        curatedTypes.add(PracticeBankType.cloze);
                      } else {
                        curatedTypes.remove(PracticeBankType.cloze);
                      }
                    }),
                  ),
                  const Divider(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Số câu tối đa:',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      for (final size in [5, 10, 20])
                        ChoiceChip(
                          label: Text('$size câu'),
                          selected: _maxQuestions == size,
                          onSelected: (_) =>
                              setState(() => _maxQuestions = size),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('start-curated-practice'),
                onPressed: sessionQuestions.isEmpty
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CuratedPracticeSessionScreen(
                            questions: sessionQuestions,
                            pool: bank,
                            catalogById: catalogById,
                            source: activeSource,
                          ),
                        ),
                      ),
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  sessionQuestions.isEmpty
                      ? 'Không có câu phù hợp bộ lọc'
                      : 'Bắt đầu phiên luyện tập (${sessionQuestions.length} câu)',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Viết & Nói (Thao tác thử)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              LearningSection(
                children: [
                  _PracticeModeTile(
                    icon: Icons.translate,
                    title: 'Dịch Việt → Nhật',
                    subtitle: 'Viết và đối chiếu câu tham khảo',
                    badgeText: 'Chưa kết nối AI',
                    colors: colors,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const WritingPracticeScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PracticeModeTile(
                    icon: Icons.mic_none,
                    title: 'Nói một câu',
                    subtitle: 'Nhập văn bản thay cho micro / ASR',
                    badgeText: 'Chưa thu âm',
                    colors: colors,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const WritingPracticeScreen(voice: true),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackDemoSetup({
    required BuildContext context,
    required ColorScheme colors,
    required BunlyTones tones,
    required bool configConnected,
    required bool isBankLoading,
    required int dueCount,
    required GrammarPoint? targetPoint,
  }) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn phiên luyện tập')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: LearningPage(
            storageKey: 'practice-setup',
            children: [
              if (configConnected) ...[
                LearningSection(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.cloud_download_outlined,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBankLoading
                                    ? 'Đang tải ngân hàng câu hỏi…'
                                    : 'Chưa có câu luyện tập đã xuất bản trên máy',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bảng câu hỏi biên tập chuẩn hiện đang trống trên máy (chưa đồng bộ hoặc máy chủ chưa xuất bản câu hỏi đã duyệt). Bạn có thể thử đồng bộ lại hoặc dùng 2 câu mẫu ngoại tuyến bên dưới.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                              if (_syncError != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _syncError!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: colors.error),
                                ),
                              ],
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _syncingBank
                                    ? null
                                    : _syncQuestionBank,
                                icon: _syncingBank
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.sync, size: 18),
                                label: Text(
                                  _syncingBank
                                      ? 'Đang đồng bộ…'
                                      : 'Kiểm tra kho câu hỏi từ máy chủ',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: tones.subtleBorder.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tones.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.psychology_outlined,
                        color: tones.onPrimaryFixed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Phiên luyện tập cục bộ',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Mục tiêu ngày',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: colors.onSecondaryContainer,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bộ câu luyện tập sẵn có trên máy để thử thao tác. Không cộng vào tiến độ hoặc lịch ôn.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Viết & Nói',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              LearningSection(
                children: [
                  _PracticeModeTile(
                    icon: Icons.translate,
                    title: 'Dịch Việt → Nhật',
                    subtitle: 'Viết và đối chiếu câu tham khảo',
                    badgeText: 'Chưa kết nối AI',
                    colors: colors,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const WritingPracticeScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PracticeModeTile(
                    icon: Icons.mic_none,
                    title: 'Nói một câu',
                    subtitle: 'Nhập văn bản thay cho micro / ASR',
                    badgeText: 'Chưa thu âm',
                    colors: colors,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const WritingPracticeScreen(voice: true),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PageHeading(
                'Nguồn bài luyện',
                targetPoint != null
                    ? 'Mẫu đang chọn: ${targetPoint.pattern} (kho câu biên tập hiện chưa có câu cho mẫu này)'
                    : 'Mẫu đang mở: 〜たことがある',
              ),
              LearningSection(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 18,
                            color: colors.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Hai câu mẫu trên thiết bị',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Offline',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: colors.onSecondaryContainer,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Trắc nghiệm và điền khuyết. Không cần AI.',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LockedSourceRow(
                    icon: Icons.schedule_outlined,
                    title: 'Đến hạn ôn (SRS)',
                    subtitle: dueCount > 0
                        ? '$dueCount mẫu đến hạn nhưng kho hiện chưa có câu hỏi.'
                        : 'Cần kho câu hỏi biên tập đã đồng bộ để mở lịch ôn.',
                    colors: colors,
                  ),
                  const SizedBox(height: 8),
                  _LockedSourceRow(
                    icon: Icons.rule_folder_outlined,
                    title: 'Điểm yếu từ Sổ lỗi',
                    subtitle: 'Tổng hợp lỗi sai từ các câu đã lưu kết quả.',
                    colors: colors,
                  ),
                  const SizedBox(height: 8),
                  _LockedSourceRow(
                    icon: Icons.tune_outlined,
                    title: 'Tự chọn theo cấp độ',
                    subtitle: 'Đang giới hạn ở bộ 2 câu luyện ngoại tuyến.',
                    colors: colors,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Dạng bài trong phiên',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              LearningSection(
                children: [
                  for (final kind in PracticeKind.values)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          kind == PracticeKind.choice
                              ? Icons.fact_check_outlined
                              : Icons.edit_note_outlined,
                          size: 18,
                          color: colors.primary,
                        ),
                      ),
                      value: demoKinds.contains(kind),
                      title: Text(
                        kind == PracticeKind.choice
                            ? 'Trắc nghiệm ngữ cảnh · 1 câu'
                            : 'Điền khuyết · 1 câu',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('Sẵn sàng ngoại tuyến'),
                      onChanged: (value) => setState(() {
                        if (value == true) {
                          demoKinds.add(kind);
                        } else {
                          demoKinds.remove(kind);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              LearningSection(
                padding: const EdgeInsets.all(14),
                children: [
                  Text(
                    'THIẾT LẬP PHIÊN',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quy mô phiên học',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Mở tối đa ${demoKinds.length} câu luyện sẵn có trên máy',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      _PracticeTag(
                        label: '${demoKinds.length} câu',
                        bg: colors.secondaryContainer,
                        fg: colors.onSecondaryContainer,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: demoKinds.isEmpty
                    ? null
                    : () {
                        final session = ref.read(startDemoPracticeProvider)(
                          demoKinds,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PracticeSessionScreen(session: session),
                          ),
                        );
                      },
                icon: const Icon(Icons.play_arrow),
                label: Text('Bắt đầu luyện tập (${demoKinds.length} câu)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectableSourceTile extends StatelessWidget {
  const _SelectableSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.colors,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final String? badge;
  final ColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? colors.primaryContainer.withValues(alpha: 0.3)
          : colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outlineVariant.withValues(alpha: 0.35),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: !enabled
                    ? colors.outline
                    : selected
                    ? colors.primary
                    : colors.secondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: enabled
                                    ? colors.onSurface
                                    : colors.onSurfaceVariant,
                              ),
                        ),
                        if (badge != null)
                          _PracticeTag(
                            label: badge!,
                            bg: colors.errorContainer,
                            fg: colors.onErrorContainer,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : enabled
                    ? Icons.radio_button_off
                    : Icons.lock_outline,
                size: 18,
                color: selected ? colors.primary : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionSessionState {
  _QuestionSessionState();

  String? initialAttemptId;
  bool initialWasSkipped = false;
  bool initialWasCorrect = false;
  String? lastAnswerText;
  int? lastSelectedOptionIndex;
  bool lastWasCorrect = false;
  int retryCount = 0;

  bool get hasFeedback => initialAttemptId != null;
}

class CuratedPracticeSessionScreen extends ConsumerStatefulWidget {
  const CuratedPracticeSessionScreen({
    super.key,
    required this.questions,
    required this.pool,
    required this.catalogById,
    required this.source,
  });

  final List<CuratedPracticeQuestion> questions;
  final List<CuratedPracticeQuestion> pool;
  final Map<String, GrammarPoint> catalogById;
  final PracticeSessionSource source;

  @override
  ConsumerState<CuratedPracticeSessionScreen> createState() =>
      _CuratedPracticeSessionScreenState();
}

class _CuratedPracticeSessionScreenState
    extends ConsumerState<CuratedPracticeSessionScreen> {
  static const _uuid = Uuid();

  late final String _sessionId;
  late String? _ownerId;
  final Map<int, _QuestionSessionState> _states = {};
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  int _index = 0;
  int? _selectedMcqIndex;
  String? _selectedWordBankOption;
  bool _keyboardMode = false;
  bool _retryingCurrent = false;
  bool _submitting = false;
  String? _pendingAttemptId;
  bool? _pendingAttemptSkip;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sessionId = _uuid.v4();
    _ownerId = ref.read(userProvider).valueOrNull?.id;
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _resetForNextQuestion() {
    _selectedMcqIndex = null;
    _selectedWordBankOption = null;
    _keyboardMode = false;
    _retryingCurrent = false;
    _pendingAttemptId = null;
    _pendingAttemptSkip = null;
    _error = null;
    _input.clear();
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _advance() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _index++;
      _resetForNextQuestion();
    });
  }

  Future<void> _submitAnswer({required bool skip}) async {
    if (_submitting || _index >= widget.questions.length) return;
    final currentUser = ref.read(userProvider).valueOrNull;
    if (currentUser == null || currentUser.id != _ownerId) {
      if (mounted) {
        setState(
          () => _error =
              'Phiên đăng nhập đã thay đổi. Vui lòng thoát phiên luyện tập này.',
        );
      }
      return;
    }

    final question = widget.questions[_index];
    final qState = _states.putIfAbsent(_index, _QuestionSessionState.new);
    final isRetrySubmission = qState.hasFeedback && _retryingCurrent;
    if (qState.hasFeedback && !isRetrySubmission) return;

    if (!skip &&
        _keyboardMode &&
        _input.value.composing.isValid &&
        !_input.value.composing.isCollapsed) {
      return;
    }

    int? selectedIdx;
    String answerText = '';
    bool isCorrect = false;

    if (!skip) {
      if (question.type == PracticeBankType.mcq) {
        selectedIdx = _selectedMcqIndex;
        if (selectedIdx == null ||
            selectedIdx < 0 ||
            selectedIdx >= question.options.length) {
          return;
        }
        answerText = question.options[selectedIdx];
        isCorrect = question.accepts(selectedIndex: selectedIdx);
      } else {
        final wordBank = buildClozeWordBank(question, widget.pool);
        final useIme = _keyboardMode || wordBank.isEmpty;
        final raw = useIme ? _input.text : (_selectedWordBankOption ?? '');
        if (raw.trim().isEmpty) return;
        answerText = raw.trim();
        isCorrect = question.accepts(rawText: answerText);
      }
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    if (_pendingAttemptSkip != skip) {
      _pendingAttemptId = null;
    }
    final attemptId = _pendingAttemptId ??= _uuid.v4();
    _pendingAttemptSkip = skip;
    final isFirstIndependent = !isRetrySubmission && !skip;
    final entry = PracticeAttemptEntry(
      attemptId: attemptId,
      questionId: question.id,
      grammarId: question.grammarId,
      contentVersion: question.contentVersion,
      sessionId: _sessionId,
      retryOf: isRetrySubmission ? qState.initialAttemptId : null,
      answerText: skip ? '' : answerText,
      selectedOptionIndex: skip ? null : selectedIdx,
      isCorrect: isCorrect,
      isSkipped: skip,
      isFirstIndependent: isFirstIndependent,
      attemptedAt: DateTime.now().toUtc(),
    );

    try {
      final storage = ref.read(practiceStorageRepositoryProvider);
      await RecordPracticeAttempt(storage)(entry);
      if (!mounted) return;
      setState(() {
        if (!isRetrySubmission) {
          qState.initialAttemptId = attemptId;
          qState.initialWasSkipped = skip;
          qState.initialWasCorrect = isCorrect;
        } else {
          qState.retryCount++;
        }
        qState.lastAnswerText = skip ? null : answerText;
        qState.lastSelectedOptionIndex = skip ? null : selectedIdx;
        qState.lastWasCorrect = isCorrect;
        _pendingAttemptId = null;
        _pendingAttemptSkip = null;
        _retryingCurrent = false;
      });
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Chưa lưu được bài làm trên máy. Hãy bấm thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _startRetry() {
    if (_submitting) return;
    setState(() {
      _retryingCurrent = true;
      _selectedMcqIndex = null;
      _selectedWordBankOption = null;
      _pendingAttemptId = null;
      _error = null;
      _input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AppUser?>>(userProvider, (_, next) {
      final nextId = next.valueOrNull?.id;
      if (nextId != _ownerId && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final config = ref.watch(configProvider);
    final reviewStates =
        ref.watch(reviewStatesProvider).valueOrNull ??
        const <ReviewStateEntry>[];
    final reviewByGrammar = {for (final r in reviewStates) r.grammarId: r};

    if (_index >= widget.questions.length) {
      return _buildSummary(
        context: context,
        colors: colors,
        tones: tones,
        configConnected: config.connected,
        reviewByGrammar: reviewByGrammar,
      );
    }

    final question = widget.questions[_index];
    final grammar = widget.catalogById[question.grammarId];
    final qState = _states[_index];
    final showingFeedback =
        qState != null && qState.hasFeedback && !_retryingCurrent;
    final wordBank = question.type == PracticeBankType.cloze
        ? buildClozeWordBank(question, widget.pool)
        : const <String>[];
    final useIme =
        question.type == PracticeBankType.cloze &&
        (_keyboardMode || wordBank.isEmpty);

    final canSubmit =
        !_submitting &&
        !showingFeedback &&
        (question.type == PracticeBankType.mcq
            ? _selectedMcqIndex != null
            : useIme
            ? (_input.text.trim().isNotEmpty &&
                  !(_input.value.composing.isValid &&
                      !_input.value.composing.isCollapsed))
            : (_selectedWordBankOption ?? '').trim().isNotEmpty);

    final activeBlank = question.type == PracticeBankType.cloze
        ? (showingFeedback
              ? (qState.lastAnswerText ?? '______')
              : (useIme
                    ? (_input.text.trim().isNotEmpty
                          ? _input.text.trim()
                          : '______')
                    : (_selectedWordBankOption ?? '______')))
        : '？';

    const optionLetters = ['A', 'B', 'C', 'D'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${question.type == PracticeBankType.mcq ? 'Trắc nghiệm' : 'Điền khuyết'} · ${_index + 1}/${widget.questions.length}',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            controller: _scroll,
            key: ValueKey('curated-practice-$_index'),
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value:
                      (_index + (showingFeedback ? 1 : 0)) /
                      widget.questions.length,
                  backgroundColor: colors.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _PracticeTag(
                    label: grammar != null
                        ? '${grammar.pattern} · ${grammar.level}'
                        : question.grammarId,
                    bg: colors.primaryContainer,
                    fg: colors.onPrimaryContainer,
                  ),
                  _PracticeTag(
                    label: question.type == PracticeBankType.mcq
                        ? 'Trắc nghiệm chuẩn'
                        : 'Điền khuyết (v${question.contentVersion})',
                    bg: colors.surfaceContainerHigh,
                    fg: colors.onSecondaryContainer,
                  ),
                  if (_retryingCurrent)
                    _PracticeTag(
                      label: 'Thử lại (không đổi SRS)',
                      bg: colors.secondaryContainer,
                      fg: colors.onSecondaryContainer,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              LearningSection(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: tones.subtleBorder.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormattedPromptText(
                          prompt: question.prompt,
                          activeBlank: activeBlank,
                          colors: colors,
                          tones: tones,
                        ),
                        if (grammar != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Cấu trúc: ${grammar.formula}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (question.type == PracticeBankType.cloze &&
                  wordBank.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        avatar: const Icon(Icons.view_module, size: 16),
                        label: const Text('Ngân hàng từ'),
                        selected: !_keyboardMode,
                        onSelected: showingFeedback || _submitting
                            ? null
                            : (_) => setState(() => _keyboardMode = false),
                      ),
                      ChoiceChip(
                        avatar: const Icon(Icons.keyboard, size: 16),
                        label: const Text('Bàn phím Nhật'),
                        selected: _keyboardMode,
                        onSelected: showingFeedback || _submitting
                            ? null
                            : (_) => setState(() => _keyboardMode = true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (useIme)
                LearningSection(
                  children: [
                    TextField(
                      key: const ValueKey('curated-cloze-input'),
                      controller: _input,
                      enabled: !showingFeedback && !_submitting,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        labelText: 'Nhập đáp án tiếng Nhật',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chấm chính xác sau khi bỏ khoảng trắng ở hai đầu (trim).',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              else if (question.type == PracticeBankType.cloze)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns =
                        constraints.maxWidth >= 260 &&
                            MediaQuery.textScalerOf(context).scale(1) <= 1.5
                        ? 2
                        : 1;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final option in wordBank)
                          SizedBox(
                            width:
                                (constraints.maxWidth - 10 * (columns - 1)) /
                                columns,
                            child: _WordBankTile(
                              option: option,
                              selected: _selectedWordBankOption == option,
                              isCorrect:
                                  showingFeedback &&
                                  question.acceptedAnswers.contains(option),
                              isUserWrong:
                                  showingFeedback &&
                                  qState.lastAnswerText == option &&
                                  !qState.lastWasCorrect,
                              locked: showingFeedback || _submitting,
                              colors: colors,
                              tones: tones,
                              onTap: () => setState(
                                () => _selectedWordBankOption = option,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                )
              else
                for (var i = 0; i < question.options.length; i++)
                  Builder(
                    builder: (context) {
                      final option = question.options[i];
                      final isSelected = _selectedMcqIndex == i;
                      final showCorrect =
                          showingFeedback && i == question.correctOptionIndex;
                      final isUserWrong =
                          showingFeedback &&
                          qState.lastSelectedOptionIndex == i &&
                          !qState.lastWasCorrect;

                      final Color cardBg;
                      final Color borderCol;
                      final Widget badge;

                      if (showCorrect) {
                        cardBg = tones.statusMasteredBg.withValues(alpha: 0.45);
                        borderCol = tones.statusMasteredFg;
                        badge = CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          child: const Icon(Icons.check, size: 16),
                        );
                      } else if (isUserWrong) {
                        cardBg = colors.errorContainer.withValues(alpha: 0.45);
                        borderCol = colors.error;
                        badge = CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.error,
                          foregroundColor: colors.onError,
                          child: const Icon(Icons.close, size: 16),
                        );
                      } else if (isSelected) {
                        cardBg = colors.secondaryContainer.withValues(
                          alpha: 0.6,
                        );
                        borderCol = colors.primary;
                        badge = CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          child: Text(
                            i < optionLetters.length
                                ? optionLetters[i]
                                : '${i + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      } else {
                        cardBg = colors.surfaceContainerLowest;
                        borderCol = tones.subtleBorder.withValues(alpha: 0.5);
                        badge = CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.surfaceContainerHigh,
                          foregroundColor: colors.onSurfaceVariant,
                          child: Text(
                            i < optionLetters.length
                                ? optionLetters[i]
                                : '${i + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: borderCol,
                            width: showCorrect || isUserWrong || isSelected
                                ? 1.5
                                : 1,
                          ),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: badge,
                          title: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (showCorrect)
                                _PracticeTag(
                                  label: 'Đáp án chuẩn',
                                  bg: colors.primary,
                                  fg: colors.onPrimary,
                                )
                              else if (isUserWrong)
                                _PracticeTag(
                                  label: 'Lựa chọn của bạn',
                                  bg: colors.error,
                                  fg: colors.onError,
                                ),
                            ],
                          ),
                          onTap: showingFeedback || _submitting
                              ? null
                              : () => setState(() => _selectedMcqIndex = i),
                        ),
                      );
                    },
                  ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colors.onErrorContainer),
                  ),
                ),
              ],
              if (showingFeedback) ...[
                const SizedBox(height: 12),
                LearningNotice(
                  title: qState.initialWasSkipped && qState.retryCount == 0
                      ? 'Đã bỏ qua (không tính SRS)'
                      : qState.lastWasCorrect
                      ? 'Chính xác'
                      : 'Chưa chính xác',
                  color: qState.lastWasCorrect
                      ? tones.statusMasteredBg
                      : colors.errorContainer,
                  accentColor: qState.lastWasCorrect
                      ? tones.statusMasteredFg
                      : colors.onErrorContainer,
                  icon: qState.lastWasCorrect
                      ? Icons.check_circle_outline
                      : Icons.lightbulb_outline,
                  message:
                      'Đáp án chuẩn: ${question.type == PracticeBankType.mcq ? (question.correctOptionIndex != null && question.correctOptionIndex! >= 0 && question.correctOptionIndex! < question.options.length ? question.options[question.correctOptionIndex!] : '') : question.acceptedAnswers.join(' / ')}\n${question.explanationVi}',
                ),
                if (qState.retryCount > 0 || !qState.lastWasCorrect) ...[
                  const SizedBox(height: 8),
                  Text(
                    qState.retryCount > 0
                        ? 'Đã ghi nhận ${qState.retryCount} lần thử lại để luyện thêm (không làm thay đổi kết quả lần đầu và lịch SRS).'
                        : 'Bạn có thể thử lại câu này sau khi xem giải thích; lịch ôn SRS chỉ tính dựa trên lần trả lời độc lập đầu tiên.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (grammar != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GrammarDetailScreen(point: grammar),
                        ),
                      ),
                      icon: const Icon(Icons.menu_book_outlined, size: 18),
                      label: Text('Xem giải thích ${grammar.pattern}'),
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    if (!qState.lastWasCorrect || qState.initialWasSkipped)
                      OutlinedButton.icon(
                        key: const ValueKey('curated-retry-btn'),
                        onPressed: _submitting ? null : _startRetry,
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Thử lại câu này'),
                      ),
                    FilledButton(
                      key: const ValueKey('curated-next-btn'),
                      onPressed: _submitting ? null : _advance,
                      child: Text(
                        _index + 1 == widget.questions.length
                            ? 'Xem tổng kết'
                            : 'Câu tiếp theo',
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 16),
                FilledButton(
                  key: const ValueKey('curated-submit-btn'),
                  onPressed: canSubmit
                      ? () => _submitAnswer(skip: false)
                      : null,
                  child: Text(
                    _submitting ? 'Đang lưu kết quả…' : 'Kiểm tra đáp án',
                  ),
                ),
                if (!_retryingCurrent) ...[
                  const SizedBox(height: 4),
                  TextButton.icon(
                    key: const ValueKey('curated-skip-btn'),
                    onPressed: _submitting
                        ? null
                        : () => _submitAnswer(skip: true),
                    icon: const Icon(Icons.skip_next_outlined, size: 18),
                    label: const Text('Bỏ qua'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary({
    required BuildContext context,
    required ColorScheme colors,
    required BunlyTones tones,
    required bool configConnected,
    required Map<String, ReviewStateEntry> reviewByGrammar,
  }) {
    var independentAnswered = 0;
    var independentCorrect = 0;
    var skipped = 0;
    var totalRetries = 0;

    final grammarIds = <String>{};
    final perGrammarWrong = <String, int>{};
    final perGrammarAnswered = <String, int>{};

    for (var i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      grammarIds.add(q.grammarId);
      final s = _states[i];
      if (s == null) continue;
      totalRetries += s.retryCount;
      if (s.initialWasSkipped) {
        skipped++;
      } else {
        independentAnswered++;
        perGrammarAnswered[q.grammarId] =
            (perGrammarAnswered[q.grammarId] ?? 0) + 1;
        if (s.initialWasCorrect) {
          independentCorrect++;
        } else {
          perGrammarWrong[q.grammarId] =
              (perGrammarWrong[q.grammarId] ?? 0) + 1;
        }
      }
    }

    final wrong = (independentAnswered - independentCorrect).clamp(0, 999);
    final anyTentative = grammarIds.any(
      (id) => reviewByGrammar[id]?.isTentative ?? configConnected,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả phiên luyện tập')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: LearningPage(
            storageKey: 'curated-practice-summary',
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: tones.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.task_alt,
                      color: tones.onPrimaryFixed,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đã ghi nhận vào hồ sơ trên máy',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Phiên học hoàn tất',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tính tỷ lệ đúng và lịch SRS dựa trên lần trả lời độc lập đầu tiên.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              LearningSection(
                children: [
                  Text(
                    'Đúng $independentCorrect/$independentAnswered câu lần đầu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StackedProgressBar(
                    mastered: independentCorrect,
                    learning: 0,
                    review: wrong,
                    fresh: skipped,
                    semanticsLabel:
                        'Đúng $independentCorrect, sai $wrong, bỏ qua $skipped',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bỏ qua $skipped câu · Thử lại thêm $totalRetries lần',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LearningSection(
                children: [
                  Text(
                    'Mẫu ngữ pháp & Lịch ôn (SRS)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final gId in grammarIds) ...[
                    Builder(
                      builder: (context) {
                        final point = widget.catalogById[gId];
                        final rState = reviewByGrammar[gId];
                        final gWrong = perGrammarWrong[gId] ?? 0;
                        final gAnswered = perGrammarAnswered[gId] ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    point != null
                                        ? '${point.pattern} · ${point.level}'
                                        : gId,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  _PracticeTag(
                                    label: gWrong == 0 && gAnswered > 0
                                        ? 'Đạt yêu cầu'
                                        : 'Cần ôn thêm',
                                    bg: gWrong == 0 && gAnswered > 0
                                        ? tones.statusMasteredBg
                                        : colors.errorContainer,
                                    fg: gWrong == 0 && gAnswered > 0
                                        ? tones.statusMasteredFg
                                        : colors.onErrorContainer,
                                  ),
                                ],
                              ),
                              if (rState != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${formatSrsStageLabel(rState.stage)}${rState.dueAt != null ? ' · Hẹn ôn ${rState.dueAt!.day}/${rState.dueAt!.month} UTC' : ''}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (configConnected)
                    Text(
                      anyTentative
                          ? 'Trạng thái SRS đang hiển thị theo tính toán tạm trên máy; sẽ được máy chủ xác nhận khi đồng bộ.'
                          : 'Lịch ôn SRS đã đồng bộ với máy chủ.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (wrong > 0) ...[
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const PracticeHistoryScreen(errorsOnly: true),
                    ),
                  ),
                  icon: const Icon(Icons.rule_outlined),
                  label: const Text('Mở Sổ lỗi cần ôn'),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Về chọn phiên'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedSourceRow extends StatelessWidget {
  const _LockedSourceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.lock_outline, size: 16, color: colors.outline),
      ],
    ),
  );
}

class _PracticeModeTile extends StatelessWidget {
  const _PracticeModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;
  final ColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.onSecondaryContainer, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$subtitle · $badgeText'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({super.key, required this.session});
  final DemoPracticeSession session;
  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  int index = 0;
  String? selected;
  bool keyboard = false;
  final input = TextEditingController();
  final scroll = ScrollController();

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void advance() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      index++;
      selected = null;
      input.clear();
      keyboard = false;
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  void submit(String? answer) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.session.submit(index, answer)) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);

    if (index >= session.questions.length) {
      final wrong = (session.answered - session.correct).clamp(0, 999);
      return Scaffold(
        appBar: AppBar(title: const Text('Kết quả phiên luyện tập')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: LearningPage(
              storageKey: 'practice-summary',
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: tones.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.task_alt,
                        color: tones.onPrimaryFixed,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoàn tất bài làm',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Phiên học hoàn tất',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Kết quả tính từ câu trả lời lần đầu trong phiên này.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                LearningSection(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Kết quả ghi nhận',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Minh bạch theo dạng bài',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colors.secondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đúng ${session.correct}/${session.answered} câu đã trả lời',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                          ),
                          const SizedBox(height: 10),
                          StackedProgressBar(
                            mastered: session.correct,
                            learning: 0,
                            review: wrong,
                            fresh: session.skipped,
                            semanticsLabel:
                                'Đúng ${session.correct}, chưa đúng $wrong, bỏ qua ${session.skipped}',
                          ),
                          const SizedBox(height: 10),
                          Text('Bỏ qua ${session.skipped} câu'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                LearningSection(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Mẫu ngữ pháp trong phiên',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        _PracticeTag(
                          label: '1 mẫu',
                          bg: colors.surfaceContainer,
                          fg: colors.secondary,
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
                                '〜たことがある · N4',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              _PracticeTag(
                                label:
                                    session.answered > 0 &&
                                        session.correct == session.answered
                                    ? 'Đạt yêu cầu'
                                    : 'Cần ôn thêm',
                                bg:
                                    session.answered > 0 &&
                                        session.correct == session.answered
                                    ? tones.statusMasteredBg
                                    : colors.errorContainer,
                                fg:
                                    session.answered > 0 &&
                                        session.correct == session.answered
                                    ? tones.statusMasteredFg
                                    : colors.onErrorContainer,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Diễn tả trải nghiệm đã từng xảy ra trong quá khứ.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Phiên luyện trên máy chưa lưu vào lịch sử, không đổi trạng thái học hoặc lịch ôn.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Về chọn phiên'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = session.questions[index];
    final response = session.responseAt(index);
    final answer = keyboard ? input.text : selected;
    const optionLetters = ['A', 'B', 'C', 'D', 'E'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${question.kind == PracticeKind.choice ? 'Trắc nghiệm' : 'Điền khuyết'} · ${index + 1}/${session.questions.length}',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            controller: scroll,
            key: ValueKey('practice-$index'),
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value:
                      (index + (response != null ? 1 : 0)) /
                      session.questions.length,
                  backgroundColor: colors.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _PracticeTag(
                    label: '〜たことがある · N5',
                    bg: colors.primaryContainer,
                    fg: colors.onPrimaryContainer,
                  ),
                  _PracticeTag(
                    label: question.kind == PracticeKind.choice
                        ? 'Nhận biết ngữ cảnh'
                        : 'Điền khuyết động từ',
                    bg: colors.surfaceContainerHigh,
                    fg: colors.onSecondaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LearningSection(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: colors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Ngữ cảnh câu',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    question.context,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: tones.subtleBorder.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormattedPromptText(
                          prompt: question.prompt,
                          activeBlank: question.kind == PracticeKind.cloze
                              ? (answer != null && answer.trim().isNotEmpty
                                    ? answer.trim()
                                    : '______')
                              : '？',
                          colors: colors,
                          tones: tones,
                        ),
                        if (question.kind == PracticeKind.cloze) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Cấu trúc: V-た + ことがある / ない (Kinh nghiệm)',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (question.kind == PracticeKind.cloze) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        avatar: const Icon(Icons.view_module, size: 16),
                        label: const Text('Ngân hàng từ'),
                        selected: !keyboard,
                        onSelected: response != null
                            ? null
                            : (_) => setState(() => keyboard = false),
                      ),
                      ChoiceChip(
                        avatar: const Icon(Icons.keyboard, size: 16),
                        label: const Text('Bàn phím Nhật'),
                        selected: keyboard,
                        onSelected: response != null
                            ? null
                            : (_) => setState(() => keyboard = true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (keyboard)
                LearningSection(
                  children: [
                    TextField(
                      controller: input,
                      enabled: response == null,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        labelText: 'Nhập Hiragana hoặc Kanji',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates_outlined,
                          size: 16,
                          color: colors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Chấp nhận viết Kanji hoặc Hiragana tương ứng trong đáp án mẫu.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else if (question.kind == PracticeKind.cloze)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns =
                            constraints.maxWidth >= 260 &&
                                MediaQuery.textScalerOf(context).scale(1) <= 1.5
                            ? 2
                            : 1;
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final option in question.options)
                              SizedBox(
                                width:
                                    (constraints.maxWidth -
                                        10 * (columns - 1)) /
                                    columns,
                                child: _WordBankTile(
                                  option: option,
                                  selected: selected == option,
                                  isCorrect:
                                      response != null &&
                                      question.accepted.contains(option),
                                  isUserWrong:
                                      response != null &&
                                      response.answer == option &&
                                      !response.correct,
                                  locked: response != null,
                                  colors: colors,
                                  tones: tones,
                                  onTap: () =>
                                      setState(() => selected = option),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.tips_and_updates_outlined,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Quy tắc chấm tự động linh hoạt: Chấp nhận Kanji「食べた」hoặc Hiragana「たべた」; bỏ khoảng trắng hai đầu.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                for (var i = 0; i < question.options.length; i++)
                  Builder(
                    builder: (context) {
                      final option = question.options[i];
                      final isSelected = selected == option;
                      final isAccepted = question.accepted.contains(option);
                      final isUserWrong =
                          response != null &&
                          response.answer == option &&
                          !response.correct;
                      final showCorrect = response != null && isAccepted;

                      final Color cardBg;
                      final Color borderCol;
                      final Widget badge;

                      if (showCorrect) {
                        cardBg = tones.statusMasteredBg.withValues(alpha: 0.45);
                        borderCol = tones.statusMasteredFg;
                        badge = CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          child: const Icon(Icons.check, size: 16),
                        );
                      } else if (isUserWrong) {
                        cardBg = colors.errorContainer.withValues(alpha: 0.45);
                        borderCol = colors.error;
                        badge = CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.error,
                          foregroundColor: colors.onError,
                          child: const Icon(Icons.close, size: 16),
                        );
                      } else if (isSelected) {
                        cardBg = colors.secondaryContainer.withValues(
                          alpha: 0.6,
                        );
                        borderCol = colors.primary;
                        badge = CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          child: Text(
                            i < optionLetters.length
                                ? optionLetters[i]
                                : '${i + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      } else {
                        cardBg = colors.surfaceContainerLowest;
                        borderCol = tones.subtleBorder.withValues(alpha: 0.5);
                        badge = CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.surfaceContainerHigh,
                          foregroundColor: colors.onSurfaceVariant,
                          child: Text(
                            i < optionLetters.length
                                ? optionLetters[i]
                                : '${i + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: borderCol,
                            width: showCorrect || isUserWrong || isSelected
                                ? 1.5
                                : 1,
                          ),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: badge,
                          title: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (showCorrect)
                                _PracticeTag(
                                  label: 'Đáp án chuẩn',
                                  bg: colors.primary,
                                  fg: colors.onPrimary,
                                )
                              else if (isUserWrong)
                                _PracticeTag(
                                  label: 'Lựa chọn của bạn',
                                  bg: colors.error,
                                  fg: colors.onError,
                                ),
                            ],
                          ),
                          trailing: isSelected && response == null
                              ? Icon(
                                  Icons.radio_button_checked,
                                  color: colors.primary,
                                )
                              : response == null
                              ? Icon(
                                  Icons.radio_button_off,
                                  color: colors.outline,
                                )
                              : null,
                          onTap: response != null
                              ? null
                              : () => setState(() => selected = option),
                        ),
                      );
                    },
                  ),
              if (response != null) ...[
                const SizedBox(height: 12),
                LearningNotice(
                  title: response.answer == null
                      ? 'Đã bỏ qua'
                      : response.correct
                      ? 'Chính xác'
                      : 'Chưa chính xác',
                  color: response.correct
                      ? tones.statusMasteredBg
                      : colors.errorContainer,
                  accentColor: response.correct
                      ? tones.statusMasteredFg
                      : colors.onErrorContainer,
                  icon: response.correct
                      ? Icons.check_circle_outline
                      : Icons.lightbulb_outline,
                  message:
                      'Đáp án: ${question.accepted.join(' / ')}\n${question.explanation}',
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quy tắc nói:',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'V(た) + ことがある (Đã từng làm V)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: advance,
                  child: Text(
                    index + 1 == session.questions.length
                        ? 'Xem tổng kết'
                        : 'Câu tiếp theo',
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed:
                      answer == null ||
                          answer.trim().isEmpty ||
                          input.value.composing.isValid &&
                              !input.value.composing.isCollapsed
                      ? null
                      : () => submit(answer),
                  child: const Text('Kiểm tra đáp án'),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () => submit(null),
                  icon: const Icon(Icons.skip_next_outlined, size: 18),
                  label: const Text('Bỏ qua'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeTag extends StatelessWidget {
  const _PracticeTag({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FormattedPromptText extends StatelessWidget {
  const _FormattedPromptText({
    required this.prompt,
    required this.activeBlank,
    required this.colors,
    required this.tones,
  });

  final String prompt;
  final String activeBlank;
  final ColorScheme colors;
  final BunlyTones tones;

  @override
  Widget build(BuildContext context) {
    const markers = ['［　　　］', '（　？　）', '(___)'];
    for (final marker in markers) {
      final idx = prompt.indexOf(marker);
      if (idx != -1) {
        final before = prompt.substring(0, idx);
        final after = prompt.substring(idx + marker.length);
        return Semantics(
          label: prompt,
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 22,
                height: 1.75,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
              children: [
                TextSpan(text: before),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tones.primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      activeBlank,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: tones.onPrimaryFixed,
                      ),
                    ),
                  ),
                ),
                TextSpan(text: after),
              ],
            ),
          ),
        );
      }
    }
    return Text(
      prompt,
      style: const TextStyle(
        fontSize: 22,
        height: 1.75,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _WordBankTile extends StatelessWidget {
  const _WordBankTile({
    required this.option,
    required this.selected,
    required this.isCorrect,
    required this.isUserWrong,
    required this.locked,
    required this.colors,
    required this.tones,
    required this.onTap,
  });

  final String option;
  final bool selected;
  final bool isCorrect;
  final bool isUserWrong;
  final bool locked;
  final ColorScheme colors;
  final BunlyTones tones;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;

    if (isCorrect) {
      bg = tones.statusMasteredBg;
      fg = tones.statusMasteredFg;
      border = tones.statusMasteredFg;
    } else if (isUserWrong) {
      bg = colors.errorContainer;
      fg = colors.onErrorContainer;
      border = colors.error;
    } else if (selected) {
      bg = colors.primary;
      fg = colors.onPrimary;
      border = colors.primary;
    } else {
      bg = colors.surfaceContainerLowest;
      fg = colors.onSurface;
      border = tones.subtleBorder.withValues(alpha: 0.45);
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: selected || isCorrect || isUserWrong ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
              if (selected || isCorrect || isUserWrong) ...[
                const SizedBox(width: 6),
                Icon(
                  isUserWrong ? Icons.close : Icons.check_circle_outline,
                  size: 18,
                  color: fg,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
