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
    final sync = ref.read(learningSyncProvider);
    if (sync == null) return;
    setState(() {
      loading = true;
      failed = false;
    });
    try {
      await sync.run();
      if (mounted) setState(() => synced = true);
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
    // Watch keeps worker alive while this screen is mounted.
    ref.watch(learningSyncProvider);
    final pending = ref.watch(pendingSyncProvider);
    final count = pending.valueOrNull;
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
    return Row(
      children: [
        Expanded(child: Text(text)),
        TextButton(
          onPressed: loading ? null : run,
          child: const Text('Đồng bộ'),
        ),
      ],
    );
  }
}
