import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import 'app_shell.dart';
import 'bunly_brand.dart';
import 'bunly_theme.dart';
import 'providers.dart';

class BunlyApp extends ConsumerWidget {
  const BunlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(userProvider);
    final recovering = ref.watch(passwordRecoveryProvider).valueOrNull ?? false;
    final themeMode = ref.watch(themeModeProvider);
    final user = session.valueOrNull;
    return MaterialApp(
      // Replacing the navigator removes private detail routes on account changes.
      key: ValueKey(
        '${ref.watch(configProvider).namespace}:${user?.id ?? 'signed-out'}:$recovering',
      ),
      title: 'Bunly',
      debugShowCheckedModeBanner: false,
      theme: bunlyTheme(Brightness.light),
      darkTheme: bunlyTheme(Brightness.dark),
      themeMode: themeMode,
      home: session.when(
        data: (user) {
          if (user == null) return const AuthScreen();
          if (recovering) {
            return const ResetPasswordScreen(isRecoveryFlow: true);
          }
          return const AppShell();
        },
        loading: () =>
            _SessionLoadingScreen(onRetry: () => ref.invalidate(userProvider)),
        error: (_, _) =>
            _SessionErrorScreen(onRetry: () => ref.invalidate(userProvider)),
      ),
    );
  }
}

class _SessionLoadingScreen extends StatefulWidget {
  const _SessionLoadingScreen({required this.onRetry});
  final VoidCallback onRetry;

  @override
  State<_SessionLoadingScreen> createState() => _SessionLoadingScreenState();
}

class _SessionLoadingScreenState extends State<_SessionLoadingScreen> {
  Timer? _slowTimer;
  bool _slow = false;

  @override
  void initState() {
    super.initState();
    _slowTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _slow
                  ? _SlowRestoreCard(
                      colors: colors,
                      tones: tones,
                      onRetry: () {
                        setState(() => _slow = false);
                        _slowTimer?.cancel();
                        _slowTimer = Timer(const Duration(seconds: 5), () {
                          if (mounted) setState(() => _slow = true);
                        });
                        widget.onRetry();
                      },
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            _StatusPill(
                              icon: Icons.verified_user_outlined,
                              label: 'Bảo mật thiết bị',
                              background: colors.surfaceContainerHigh,
                              foreground: colors.onSurfaceVariant,
                            ),
                            _StatusPill(
                              icon: Icons.lock_outline,
                              label: 'Offline First',
                              background: colors.surfaceContainer,
                              foreground: colors.secondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const BunlyBrand(),
                        const SizedBox(height: 28),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Đang khôi phục phiên học…',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Xác thực khóa bảo mật lưu trữ cục bộ trên máy.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 20,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bảo toàn dữ liệu riêng tư',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: colors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Dữ liệu bài học và ghi chú chỉ hiển thị đúng theo tài khoản trên thiết bị.',
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Phiên bản 0.1.0 · Bunly · Học ngữ pháp từ ngữ cảnh thực tế',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlowRestoreCard extends StatelessWidget {
  const _SlowRestoreCard({
    required this.colors,
    required this.tones,
    required this.onRetry,
  });

  final ColorScheme colors;
  final BunlyTones tones;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _StatusPill(
        icon: Icons.circle,
        label: 'bunly · 文法',
        background: colors.surfaceContainerHigh,
        foreground: colors.primary,
      ),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tones.subtleBorder.withValues(alpha: 0.45)),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                color: colors.onSecondaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kiểm tra phiên làm việc mất nhiều thời gian hơn dự kiến',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Bunly chưa nhận được phản hồi xác thực. Dữ liệu học tập và ghi chú offline trên thiết bị vẫn được giữ an toàn.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sd_storage_outlined,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Bộ nhớ cục bộ an toàn',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
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
                      'Đang giữ trên máy',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử kết nối lại'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bạn có thể chờ kết nối lại mà không mất dữ liệu đang lưu trên máy.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tones.subtleBorder.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: colors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'NGUYÊN TẮC BẢO VỆ PHIÊN',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Lỗi kết nối không tự ý xóa phiên hoặc xóa ghi chú đang lưu trên máy.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              '• Giữ tách biệt dữ liệu giữa các tài khoản cục bộ.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Đang giữ phiên chờ phản hồi • Không mất dữ liệu',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    ],
  );
}

class _SessionErrorScreen extends StatelessWidget {
  const _SessionErrorScreen({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BunlyBrand(),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: tones.subtleBorder.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.errorContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: colors.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Chưa đọc được phiên đăng nhập. Bạn có thể thử lại.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử khôi phục phiên'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: foreground),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
