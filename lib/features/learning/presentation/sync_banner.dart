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
  bool loading = false;
  bool failed = false;
  bool synced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => run());
    timer = Timer.periodic(const Duration(seconds: 30), (_) => run());
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) run();
  }

  Future<void> run() async {
    if (!mounted || loading) return;
    final learningSync = ref.read(learningSyncProvider);
    final practiceSync = ref.read(practiceSyncProvider);
    if (learningSync == null && practiceSync == null) return;
    setState(() {
      loading = true;
      failed = false;
    });
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
        setState(() => synced = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          failed = true;
          synced = false;
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch keeps workers alive while this screen is mounted.
    ref.watch(learningSyncProvider);
    ref.watch(practiceSyncProvider);
    final pending = ref.watch(pendingSyncProvider);
    final count = pending.valueOrNull;
    final colors = Theme.of(context).colorScheme;
    final hasError = pending.hasError || failed;
    final text = pending.hasError
        ? 'Chưa đọc được hàng đợi đồng bộ.'
        : loading
        ? 'Đang đồng bộ…'
        : failed
        ? 'Chưa đồng bộ được. Dữ liệu chờ vẫn ở trên máy.'
        : (count ?? 0) > 0
        ? '$count thao tác đang chờ gửi.'
        : synced
        ? 'Đã đồng bộ lần gần nhất.'
        : 'Dữ liệu lưu trên máy; đang chờ kiểm tra đồng bộ.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasError ? colors.errorContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
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
                  : synced
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_queue_outlined,
              size: 16,
              color: hasError ? colors.onErrorContainer : colors.primary,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: hasError
                    ? colors.onErrorContainer
                    : colors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: loading ? null : run,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            child: const Text('Đồng bộ'),
          ),
        ],
      ),
    );
  }
}
