import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_brand.dart';
import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_validation.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.isRecoveryFlow,
    this.previewMode = false,
  });

  final bool isRecoveryFlow;
  final bool previewMode;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool hidden = true;
  String? validation;
  bool previewCompleted = false;

  @override
  void dispose() {
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      validatePassword(password.text);
    } on FormatException catch (e) {
      setState(() => validation = e.message);
      return;
    }
    if (password.text != confirmation.text) {
      setState(() => validation = 'Mật khẩu xác nhận chưa khớp.');
      return;
    }
    setState(() => validation = null);
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.previewMode) {
      setState(() => previewCompleted = true);
      return;
    }
    await ref
        .read(updatePasswordControllerProvider.notifier)
        .submit(password.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updatePasswordControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final updated = state.valueOrNull == true || previewCompleted;
    final errorMessage =
        validation ??
        (state.hasError
            ? switch (state.error) {
                FormatException e => e.message,
                AuthFailure e => e.message,
                _ => 'Chưa thể cập nhật mật khẩu. Hãy thử lại.',
              }
            : null);

    return Scaffold(
      appBar: widget.isRecoveryFlow
          ? null
          : AppBar(title: const Text('Cập nhật mật khẩu')),
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
                child: updated
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: tones.statusMasteredBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle_outline,
                                size: 32,
                                color: tones.statusMasteredFg,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Mật khẩu đã được cập nhật',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.previewMode
                                ? 'Xem trước màn hình hoàn tất (S04c). Khi kết nối Supabase, mật khẩu mới sẽ có hiệu lực ngay trên tài khoản của bạn.'
                                : 'Bạn có thể tiếp tục học ngay với mật khẩu mới.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () {
                              if (widget.isRecoveryFlow &&
                                  !widget.previewMode) {
                                ref
                                    .read(
                                      updatePasswordControllerProvider.notifier,
                                    )
                                    .finishRecovery();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(
                              widget.isRecoveryFlow
                                  ? 'Tiếp tục vào Bunly'
                                  : 'Hoàn tất',
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Center(
                            child: BunlyLogoMark(size: 52, borderRadius: 14),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.isRecoveryFlow
                                ? 'Tạo mật khẩu mới'
                                : 'Đổi mật khẩu',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.isRecoveryFlow
                                ? 'Liên kết khôi phục đã hợp lệ. Nhập mật khẩu mới tối thiểu 8 ký tự trước khi vào ứng dụng.'
                                : 'Nhập mật khẩu mới tối thiểu 8 ký tự cho tài khoản đang đăng nhập.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          if (widget.previewMode) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Xem trước giao diện S04b · Chưa kết nối máy chủ Supabase.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Text(
                            'Mật khẩu mới',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: password,
                            enabled: !state.isLoading,
                            obscureText: hidden,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: InputDecoration(
                              hintText: 'Ít nhất 8 ký tự',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: TextButton.icon(
                                onPressed: () =>
                                    setState(() => hidden = !hidden),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 36),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                ),
                                icon: Icon(
                                  hidden
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                ),
                                label: Text(hidden ? 'Hiện' : 'Ẩn'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Xác nhận mật khẩu mới',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: confirmation,
                            enabled: !state.isLoading,
                            obscureText: hidden,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            onSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              hintText: 'Nhập lại mật khẩu mới',
                              prefixIcon: Icon(Icons.verified_user_outlined),
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
                                style: TextStyle(
                                  color: colors.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: state.isLoading ? null : _submit,
                            child: Text(
                              state.isLoading
                                  ? 'Đang cập nhật…'
                                  : 'Lưu mật khẩu mới',
                            ),
                          ),
                          if (widget.isRecoveryFlow && !widget.previewMode) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () => ref
                                        .read(
                                          updatePasswordControllerProvider
                                              .notifier,
                                        )
                                        .cancelRecovery(),
                              child: const Text('Hủy và quay lại đăng nhập'),
                            ),
                          ],
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
