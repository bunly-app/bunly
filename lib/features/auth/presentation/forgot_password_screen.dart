import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_brand.dart';
import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_validation.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = '',
    this.previewMode = false,
  });

  final String initialEmail;
  final bool previewMode;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController email;
  String? validation;
  bool previewSubmitted = false;

  @override
  void initState() {
    super.initState();
    email = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  void _submit() {
    try {
      normalizeAndValidateEmail(email.text);
    } on FormatException catch (e) {
      setState(() => validation = e.message);
      return;
    }
    setState(() => validation = null);
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.previewMode) {
      setState(() => previewSubmitted = true);
      return;
    }
    ref.read(passwordResetControllerProvider.notifier).submit(email.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final sent = state.valueOrNull == true;
    final errorMessage =
        validation ??
        (state.hasError
            ? switch (state.error) {
                FormatException e => e.message,
                AuthFailure e => e.message,
                _ => 'Chưa gửi được yêu cầu đặt lại mật khẩu. Hãy thử lại.',
              }
            : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
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
                    const Center(
                      child: BunlyLogoMark(size: 52, borderRadius: 14),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Đặt lại mật khẩu',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhập địa chỉ email đã đăng ký. Bunly sẽ gửi liên kết đặt lại mật khẩu về hộp thư của bạn.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Email',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: email,
                      enabled: !state.isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        hintText: 'hocvien@bunly.edu.vn',
                        prefixIcon: Icon(Icons.mail_outline),
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
                    if (sent) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Nếu email này đã đăng ký trong hệ thống, liên kết đặt lại mật khẩu đã được gửi. Mở liên kết trên thiết bị này để tạo mật khẩu mới.',
                          style: TextStyle(color: colors.onSecondaryContainer),
                        ),
                      ),
                    ],
                    if (previewSubmitted) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Đã kiểm tra email hợp lệ. Chế độ hiện tại chưa kết nối máy chủ Supabase nên chưa gửi email đặt lại thật.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ResetPasswordScreen(
                                    isRecoveryFlow: false,
                                    previewMode: true,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Xem màn hình đặt lại mật khẩu (S04b)',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: state.isLoading ? null : _submit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isLoading) ...[
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Flexible(
                            child: Text(
                              state.isLoading
                                  ? 'Đang gửi…'
                                  : 'Gửi liên kết đặt lại mật khẩu',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: state.isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Quay lại đăng nhập'),
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
