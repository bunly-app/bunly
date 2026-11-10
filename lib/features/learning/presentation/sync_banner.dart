import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class SyncBanner extends ConsumerStatefulWidget {
  const SyncBanner({super.key});
  @override
  ConsumerState<SyncBanner> createState() => _SyncBannerState();
}

class _SyncBannerState extends ConsumerState<SyncBanner>
    with WidgetsBindingObserver {
  Timer? timer;
  Timer? _debounceTimer;
  bool loading = false;
  bool failed = false;
  bool _rerunRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => run());
    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      final pending = ref.read(pendingSyncProvider).valueOrNull ?? 0;
      if (failed || pending > 0) run();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _debounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) run();
  }

  void _schedulePendingSync() {
    if (!mounted) return;
    if (loading) {
      _rerunRequested = true;
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) unawaited(run());
    });
  }

  Future<void> run() async {
    if (!mounted) return;
    if (loading) {
      _rerunRequested = true;
      return;
    }
    _debounceTimer?.cancel();
    final learningSync = ref.read(learningSyncProvider);
    final practiceSync = ref.read(practiceSyncProvider);
    if (learningSync == null && practiceSync == null) return;
    setState(() {
      loading = true;
      failed = false;
    });
    var hadError = false;
    try {
      if (learningSync != null) {
        await learningSync.run();
      }
      if (practiceSync != null) {
        await practiceSync.run();
        if (mounted) {
          ref.invalidate(cachedQuestionsProvider);
        }
      }
      if (mounted) {
        ref.invalidate(analysisQuotaProvider);
      }
    } catch (_) {
      hadError = true;
      if (mounted) {
        setState(() => failed = true);
      }
    } finally {
      final shouldRerun = _rerunRequested && !hadError;
      _rerunRequested = false;
      if (mounted) setState(() => loading = false);
      if (shouldRerun && mounted) {
        unawaited(run());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch keeps workers alive while this screen is mounted.
    ref.watch(learningSyncProvider);
    ref.watch(practiceSyncProvider);
    ref.listen<AsyncValue<int>>(pendingSyncProvider, (previous, next) {
      final nextCount = next.valueOrNull ?? 0;
      final prevCount = previous?.valueOrNull;
      if (nextCount > 0 && (prevCount == null || nextCount > prevCount)) {
        _schedulePendingSync();
      }
    });
    final pending = ref.watch(pendingSyncProvider);
    final conflicts = ref.watch(noteConflictsProvider).valueOrNull ?? const [];
    final hasConflict = conflicts.isNotEmpty;
    final count = pending.valueOrNull ?? 0;
    final hasError = pending.hasError || failed;
    if (!loading && !hasError && !hasConflict && count == 0) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    final text = pending.hasError
        ? 'Chưa đọc được hàng đợi đồng bộ. Chạm để thử lại.'
        : failed
        ? 'Chưa đồng bộ được. Chạm để thử lại.'
        : hasConflict
        ? 'Có ${conflicts.length} xung đột ghi chú cần xử lý trong Sổ tay'
        : loading
        ? 'Đang tự đồng bộ…'
        : 'Đang tự đồng bộ $count mục…';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      child: Material(
        color: hasError
            ? colors.errorContainer
            : hasConflict
            ? colors.tertiaryContainer
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: loading ? null : run,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (loading)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  )
                else
                  Icon(
                    hasError
                        ? Icons.cloud_off_outlined
                        : hasConflict
                        ? Icons.merge_type_rounded
                        : Icons.cloud_upload_outlined,
                    size: 16,
                    color: hasError
                        ? colors.onErrorContainer
                        : hasConflict
                        ? colors.onTertiaryContainer
                        : colors.primary,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: hasError
                          ? colors.onErrorContainer
                          : hasConflict
                          ? colors.onTertiaryContainer
                          : colors.onSurfaceVariant,
                      fontWeight: hasConflict ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                if (hasError)
                  Icon(Icons.refresh, size: 16, color: colors.onErrorContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
