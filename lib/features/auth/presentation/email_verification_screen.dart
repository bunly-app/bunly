import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_brand.dart';
import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../domain/auth_failure.dart';

enum EmailVerificationNextAction { signIn, editEmail }

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.previewMode = false,
  });

  final String email;
  final bool previewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emailVerificationControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final displayEmail = email.trim().isEmpty
        ? 'hocvien@bunly.edu.vn'
        : email.trim();

    final errorMessage = state.hasError
        ? switch (state.error) {
            FormatException e => e.message,
            AuthFailure e => e.message,
            _ => 'Chưa thể gửi lại email xác nhận lúc này. Vui lòng thử lại.',
          }
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận email')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: tones.subtleBorder.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mark_email_unread_outlined,
                              size: 32,
                              color: colors.onSecondaryContainer,
                            ),
                          ),
                          const Positioned(
                            right: -4,
                            bottom: -4,
                            child: BunlyLogoMark(size: 26, borderRadius: 8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kiểm tra hộp thư của bạn',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tài khoản cần xác nhận email trước khi mở phiên đăng nhập đồng bộ.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.alternate_email,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SelectableText(
                              displayEmail,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (previewMode) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: colors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Đang xem trước luồng S03 khi chưa kết nối máy chủ Supabase; chưa có email thật nào được gửi đi.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HƯỚNG DẪN XÁC NHẬN',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1. Mở Hộp thư đến (hoặc Thư rác / Spam) tìm email từ Bunly.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '2. Nhấn vào liên kết xác nhận để kích hoạt tài khoản.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '3. Quay lại Bunly và chọn "Đã xác nhận — Đến đăng nhập".',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ],
                    if (state.valueOrNull != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          state.valueOrNull!,
                          style: TextStyle(color: colors.onSecondaryContainer),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (previewMode) {
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Gửi lại email cần chế độ kết nối Supabase.',
                                      ),
                                    ),
                                  );
                                return;
                              }
                              ref
                                  .read(
                                    emailVerificationControllerProvider
                                        .notifier,
                                  )
                                  .resend(displayEmail);
                            },
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_outlined),
                      label: Text(
                        state.isLoading
                            ? 'Đang gửi lại…'
                            : 'Gửi lại email xác nhận',
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pop(EmailVerificationNextAction.signIn),
                      child: const Text('Đã xác nhận — Đến đăng nhập'),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: state.isLoading
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pop(EmailVerificationNextAction.editEmail),
                      child: const Text('Sửa địa chỉ email'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
