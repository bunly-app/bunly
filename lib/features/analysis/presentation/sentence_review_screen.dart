import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../../auth/domain/auth_repository.dart';
import '../../learning/presentation/learning_widgets.dart';
import '../../ocr/domain/ocr_draft.dart';
import '../domain/grammar_analysis.dart';
import 'sentence_result_screen.dart';

class SentenceReviewScreen extends ConsumerStatefulWidget {
  const SentenceReviewScreen({super.key, this.initialText = ''});
  final String initialText;

  @override
  ConsumerState<SentenceReviewScreen> createState() =>
      _SentenceReviewScreenState();
}

class _SentenceReviewScreenState extends ConsumerState<SentenceReviewScreen> {
  static const _uuid = Uuid();
  late final TextEditingController text;
  final focus = FocusNode();
  late final AnalysisRequestSession _requestSession;

  String? _ownerId;
  bool scanning = false;
  bool submitting = false;
  bool pendingProcessing = false;
  bool ocrApplied = false;
  String? error;
  String? ocrWarning;

  @override
  void initState() {
    super.initState();
    text = TextEditingController(text: widget.initialText);
    _requestSession = AnalysisRequestSession();
    _ownerId = ref.read(userProvider).valueOrNull?.id;
  }

  @override
  void dispose() {
    text.dispose();
    focus.dispose();
    super.dispose();
  }

  void _resetForOwner(String? newOwnerId) {
    _ownerId = newOwnerId;
    text.text = widget.initialText;
    _requestSession.reset();
    scanning = false;
    submitting = false;
    pendingProcessing = false;
    ocrApplied = false;
    error = null;
    ocrWarning = null;
  }

  void insert(String value) {
    final selection = text.selection;
    final start = selection.isValid ? selection.start : text.text.length;
    final end = selection.isValid ? selection.end : text.text.length;
    text.value = TextEditingValue(
      text: text.text.replaceRange(start, end, value),
      selection: TextSelection.collapsed(offset: start + value.length),
    );
    focus.requestFocus();
    setState(() {
      error = null;
      ocrWarning = null;
      pendingProcessing = false;
    });
  }

  Future<void> _scanOcr(OcrSource source) async {
    if (scanning || submitting) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      scanning = true;
      error = null;
      ocrWarning = null;
      pendingProcessing = false;
    });
    try {
      final draft = await ref.read(scanJapaneseTextProvider)(source);
      if (!mounted) return;
      if (draft == null) {
        return;
      }
      if (draft.text.trim().isEmpty) {
        setState(() {
          ocrWarning =
              'Không nhận diện được chữ tiếng Nhật rõ ràng từ ảnh. Bạn có thể chụp lại nơi đủ sáng hoặc nhập tay.';
        });
        return;
      }
      setState(() {
        text.text = draft.text;
        text.selection = TextSelection.collapsed(offset: text.text.length);
        ocrApplied = true;
        _requestSession.reset();
      });
    } on OcrException catch (e) {
      if (mounted) {
        setState(() => ocrWarning = e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => ocrWarning =
              'Chưa thể đọc ảnh trên thiết bị lúc này. Bạn vẫn có thể nhập câu thủ công.',
        );
      }
    } finally {
      if (mounted) setState(() => scanning = false);
    }
  }

  Future<void> _analyzeAi() async {
    final useCase = ref.read(analyzeGrammarSentenceProvider);
    if (useCase == null || submitting || scanning) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      submitting = true;
      error = null;
      pendingProcessing = false;
    });
    try {
      final requestId = _requestSession.resolveIdForText(text.text, _uuid.v4);
      GrammarAnalysisResult result;
      try {
        result = await useCase(draftText: text.text, requestId: requestId);
      } on AnalysisException catch (e) {
        if (e.kind == AnalysisFailureKind.processing) {
          // Single bounded retry with the exact same idempotency request_id.
          await Future<void>.delayed(const Duration(milliseconds: 1400));
          if (!mounted) return;
          result = await useCase(draftText: text.text, requestId: requestId);
        } else {
          rethrow;
        }
      }
      if (!mounted) return;
      _requestSession.reset();
      ref.invalidate(analysisQuotaProvider);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              SentenceResultScreen(analysis: result, sourceIsOcr: ocrApplied),
        ),
      );
    } on FormatException catch (e) {
      if (mounted) setState(() => error = e.message);
    } on AnalysisException catch (e) {
      if (!mounted) return;
      if (e.kind == AnalysisFailureKind.quotaExceeded ||
          e.kind == AnalysisFailureKind.requestConflict) {
        ref.invalidate(analysisQuotaProvider);
      }
      if (e.kind == AnalysisFailureKind.requestConflict ||
          e.kind == AnalysisFailureKind.invalidInput) {
        _requestSession.reset();
      }
      setState(() {
        error = e.message;
        pendingProcessing = e.kind == AnalysisFailureKind.processing;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Chưa hoàn tất phân tích câu. Bản nháp vẫn được giữ nguyên để bạn thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  Future<void> previewLocal() async {
    if (submitting || scanning) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      submitting = true;
      error = null;
    });
    try {
      final result = await ref.read(previewSentenceProvider)(text.text);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              SentenceResultScreen(result: result, sourceIsOcr: ocrApplied),
        ),
      );
    } on FormatException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Chưa đọc được kho ví dụ. Bạn có thể thử lại.');
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  String _formatResetUtc(DateTime utc) {
    final hh = utc.hour.toString().padLeft(2, '0');
    final mm = utc.minute.toString().padLeft(2, '0');
    return '${utc.day}/${utc.month} $hh:$mm UTC';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AppUser?>>(userProvider, (_, next) {
      final nextId = next.valueOrNull?.id;
      if (nextId != _ownerId && mounted) {
        setState(() => _resetForOwner(nextId));
      }
    });

    final catalog = ref.watch(catalogProvider);
    final config = ref.watch(configProvider);
    final analyzeUseCase = ref.watch(analyzeGrammarSentenceProvider);
    final isAiConnected = config.connected && analyzeUseCase != null;
    final quota = isAiConnected
        ? ref.watch(analysisQuotaProvider)
        : const AsyncData<AnalysisQuotaStatus?>(null);

    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final samples = catalog.hasValue && !catalog.hasError && !catalog.isLoading
        ? catalog.requireValue.points
              .expand((point) => point.examples)
              .map((example) => example.japanese)
              .toList()
        : const <String>[];
    final charCount = text.text.trim().runes.length;
    final busy = submitting || scanning;

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận câu tiếng Nhật')),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: tones.subtleBorder.withValues(alpha: 0.35)),
          ),
        ),
        child: SafeArea(
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          error!,
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    FilledButton.icon(
                      key: const ValueKey('sentence-primary-cta'),
                      onPressed: busy
                          ? null
                          : isAiConnected
                          ? _analyzeAi
                          : previewLocal,
                      icon: submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isAiConnected
                                  ? Icons.auto_awesome
                                  : Icons.arrow_forward,
                            ),
                      label: Text(
                        submitting
                            ? (isAiConnected ? 'Đang phân tích…' : 'Đang mở…')
                            : isAiConnected
                            ? (pendingProcessing
                                  ? 'Kiểm tra lại kết quả AI'
                                  : 'Phân tích ngữ pháp AI')
                            : 'Xác nhận và đối chiếu mẫu',
                      ),
                    ),
                    if (isAiConnected) ...[
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: busy ? null : previewLocal,
                        icon: const Icon(Icons.find_in_page_outlined, size: 18),
                        label: const Text('Đối chiếu nhanh ví dụ trên máy'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: LearningPage(
            storageKey: 'sentence-review',
            children: [
              LearningNotice(
                title: isAiConnected
                    ? 'Quét OCR trên máy & Phân tích AI'
                    : 'Quét OCR trên máy · Chế độ ngoại tuyến',
                icon: Icons.document_scanner_outlined,
                message: isAiConnected
                    ? 'Ảnh được đọc trực tiếp trên máy (hoạt động cả khi mất mạng). Chỉ văn bản tiếng Nhật bạn xác nhận mới được gửi tới máy chủ AI.'
                    : 'Ảnh được nhận diện ngoại tuyến trên thiết bị. Chế độ hiện tại chỉ đối chiếu ví dụ cục bộ trong kho.',
              ),
              if (isAiConnected) ...[
                const SizedBox(height: 10),
                _QuotaBanner(
                  quota: quota,
                  formatResetUtc: _formatResetUtc,
                  onRetry: () => ref.invalidate(analysisQuotaProvider),
                ),
              ],
              const SizedBox(height: 14),
              LearningSection(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Quét chữ Nhật từ ảnh',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chụp trang sách, bảng hoặc chọn ảnh có sẵn. Kết quả điền vào khung bên dưới để bạn sửa trước khi kiểm tra.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        key: const ValueKey('ocr-camera-button'),
                        onPressed: busy
                            ? null
                            : () => _scanOcr(OcrSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: const Text('Chụp ảnh'),
                      ),
                      OutlinedButton.icon(
                        key: const ValueKey('ocr-gallery-button'),
                        onPressed: busy
                            ? null
                            : () => _scanOcr(OcrSource.gallery),
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: const Text('Chọn ảnh'),
                      ),
                    ],
                  ),
                  if (scanning) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 6),
                    Text(
                      'Đang nhận diện chữ Nhật trên thiết bị…',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (ocrWarning != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        ocrWarning!,
                        style: TextStyle(color: colors.onErrorContainer),
                      ),
                    ),
                  ],
                  if (ocrApplied && ocrWarning == null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: tones.primaryFixed.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 16,
                            color: tones.onPrimaryFixed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Đã điền chữ từ OCR trên thiết bị (chưa gửi ra ngoài). Hãy rà lại Kanji, furigana và trợ từ.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: tones.onPrimaryFixed,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              LearningSection(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_note_outlined,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Văn bản cần kiểm tra',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
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
                          '$charCount / $analysisMaxCodepoints ký tự',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: charCount > analysisMaxCodepoints
                                    ? colors.error
                                    : colors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('sentence-input'),
                    controller: text,
                    focusNode: focus,
                    enabled: !busy,
                    minLines: 3,
                    maxLines: 7,
                    maxLength: 2000,
                    style: const TextStyle(fontSize: 22, height: 1.7),
                    decoration: const InputDecoration(
                      hintText: 'Nhập hoặc dán câu tiếng Nhật…',
                    ),
                    onChanged: (_) => setState(() {
                      error = null;
                      pendingProcessing = false;
                    }),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Chèn nhanh:',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                      for (final char in ['。', '、', 'は', 'が', 'へ'])
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(44, 38),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: busy ? null : () => insert(char),
                          child: Text(
                            char,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 18,
                          color: colors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kiểm tra Kanji, trợ từ và dấu câu trước khi xác nhận.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (widget.initialText.isNotEmpty)
                        TextButton.icon(
                          onPressed: busy
                              ? null
                              : () => setState(() {
                                  text.text = widget.initialText;
                                  error = null;
                                  pendingProcessing = false;
                                }),
                          icon: const Icon(Icons.undo, size: 16),
                          label: const Text('Khôi phục câu ban đầu'),
                        ),
                      TextButton.icon(
                        onPressed: busy
                            ? null
                            : () {
                                setState(() {
                                  text.clear();
                                  ocrApplied = false;
                                  error = null;
                                  ocrWarning = null;
                                  pendingProcessing = false;
                                  _requestSession.reset();
                                });
                                focus.requestFocus();
                              },
                        icon: const Icon(Icons.keyboard_outlined, size: 16),
                        label: const Text('Xóa để nhập tay'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LearningSection(
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_stories, size: 18, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thử với câu trong kho',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (catalog.isLoading)
                    const LinearProgressIndicator()
                  else if (catalog.hasError)
                    TextButton.icon(
                      onPressed: () => ref.invalidate(catalogProvider),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Thử tải lại ví dụ'),
                    )
                  else if (samples.isEmpty)
                    const Text('Kho hiện tại chưa có câu ví dụ.')
                  else
                    for (final sample in samples.take(3))
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            sample,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Icon(
                            Icons.north_west,
                            size: 18,
                            color: colors.primary,
                          ),
                          onTap: busy
                              ? null
                              : () => setState(() {
                                  text.text = sample;
                                  text.selection = TextSelection.collapsed(
                                    offset: text.text.length,
                                  );
                                  ocrApplied = false;
                                  error = null;
                                  ocrWarning = null;
                                  pendingProcessing = false;
                                }),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 16),
              LearningNotice(
                title: 'Bạn quyết định dữ liệu được gửi',
                icon: Icons.verified_user_outlined,
                message: isAiConnected
                    ? 'Ảnh OCR luôn ở trên máy. AI chỉ nhận chuỗi văn bản đã sửa khi bạn bấm “Phân tích ngữ pháp AI”, và câu chỉ lưu vào Sổ học khi bạn chọn lưu.'
                    : 'Bản xem trước chỉ đối chiếu câu ví dụ trùng khớp trong kho. Không gửi văn bản hay ảnh ra ngoài; chưa lưu câu nếu bạn chưa chọn lưu.',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuotaBanner extends StatelessWidget {
  const _QuotaBanner({
    required this.quota,
    required this.formatResetUtc,
    required this.onRetry,
  });

  final AsyncValue<AnalysisQuotaStatus?> quota;
  final String Function(DateTime) formatResetUtc;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: quota.when(
        loading: () => Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Đang kiểm tra hạn mức phân tích AI hôm nay…',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        error: (_, _) => Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: colors.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Chưa đọc được hạn mức AI lúc này.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
        data: (status) {
          if (status == null) return const SizedBox.shrink();
          final canAnalyze = status.hasEntitlement && status.remainingQuota > 0;
          final resetText = ' · Đặt lại: ${formatResetUtc(status.resetAtUtc)}';
          final text = !status.hasEntitlement
              ? 'Tài khoản chưa được cấp hạn mức AI hàng ngày.$resetText'
              : 'Hạn mức AI hôm nay: còn ${status.remainingQuota}/${status.dailyLimit} lượt (đang xử lý: ${status.reservedToday})$resetText';
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                canAnalyze ? Icons.bolt_outlined : Icons.block_outlined,
                size: 16,
                color: canAnalyze ? colors.primary : colors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
