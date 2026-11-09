import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_brand.dart';
import '../../../app/bunly_theme.dart';
import '../../../app/providers.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_validation.dart';
import 'auth_controller.dart';
import 'email_verification_screen.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({
    super.key,
    this.initialRegister = false,
    this.previewMode = false,
  });

  final bool initialRegister;
  final bool previewMode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  late bool register;
  bool hidden = true;
  String? validation;
  String? previewNotice;

  @override
  void initState() {
    super.initState();
    register = widget.initialRegister;
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> _openVerification(String rawEmail) async {
    final normalized = rawEmail.trim();
    final action = await Navigator.of(context)
        .push<EmailVerificationNextAction>(
          MaterialPageRoute<EmailVerificationNextAction>(
            builder: (_) => EmailVerificationScreen(
              email: normalized,
              previewMode: widget.previewMode,
            ),
          ),
        );
    if (!mounted) return;
    if (action == EmailVerificationNextAction.signIn) {
      setState(() {
        register = false;
        validation = null;
        previewNotice = null;
      });
    } else if (action == EmailVerificationNextAction.editEmail) {
      setState(() {
        register = true;
        validation = null;
        previewNotice = null;
      });
    }
  }

  Future<void> _submit() async {
    if (register && password.text != confirmation.text) {
      setState(() {
        validation = 'Mật khẩu xác nhận chưa khớp.';
        previewNotice = null;
      });
      return;
    }
    if (widget.previewMode) {
      try {
        final normalized = normalizeAndValidateEmail(email.text);
        validatePassword(password.text);
        setState(() {
          validation = null;
          previewNotice = null;
        });
        FocusManager.instance.primaryFocus?.unfocus();
        if (register) {
          await _openVerification(normalized);
        } else {
          setState(
            () => previewNotice =
                'Dữ liệu hợp lệ. Bản hiện tại đang chạy ngoại tuyến nên chưa kết nối máy chủ đăng nhập Supabase.',
          );
        }
      } on FormatException catch (e) {
        setState(() {
          validation = e.message;
          previewNotice = null;
        });
      }
      return;
    }

    setState(() {
      validation = null;
      previewNotice = null;
    });
    FocusManager.instance.primaryFocus?.unfocus();
    final outcome = await ref
        .read(authControllerProvider.notifier)
        .submit(email.text, password.text, register: register);
    if (!mounted) return;
    if (outcome == AuthSubmitOutcome.needsConfirmation) {
      await _openVerification(email.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final tones = BunlyTones.of(context);
    final authError = state.error;
    final needsConfirmationPrompt =
        authError is AuthFailure &&
        authError.kind == AuthFailureKind.emailNotConfirmed;
    final errorMessage =
        validation ??
        (state.hasError
            ? switch (authError) {
                FormatException e => e.message,
                AuthFailure e => e.message,
                _ =>
                  'Không thể xác thực. Kiểm tra tài khoản, xác nhận email và kết nối mạng.',
              }
            : null);

    return Scaffold(
      appBar: widget.previewMode
          ? AppBar(title: const Text('Giao diện xác thực'))
          : null,
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
                    if (widget.previewMode) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              size: 16,
                              color: colors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Xem trước luồng S01–S04 · Chưa kết nối máy chủ Supabase',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    BunlyBrand(
                      subtitle: register
                          ? 'Lưu sổ học cá nhân và theo dõi tiến độ chính xác.'
                          : 'Hiểu câu Nhật, luyện để dùng được.',
                    ),
                    const SizedBox(height: 18),
                    Text(
                      register ? 'Tạo tài khoản' : 'Đăng nhập',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
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
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        hintText: 'hocvien@bunly.edu.vn',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Giữ nguyên email đã nhập khi có lỗi để bạn chỉnh sửa nhanh.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Mật khẩu',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (register)
                          Text(
                            'Tối thiểu 8 ký tự',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          )
                        else
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: state.isLoading
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ForgotPasswordScreen(
                                        initialEmail: email.text.trim(),
                                        previewMode: widget.previewMode,
                                      ),
                                    ),
                                  ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              child: Text(
                                'Quên mật khẩu?',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: password,
                      enabled: !state.isLoading,
                      obscureText: hidden,
                      textInputAction: register
                          ? TextInputAction.next
                          : TextInputAction.done,
                      autofillHints: [
                        register
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      onSubmitted: register ? null : (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Ít nhất 8 ký tự',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: TextButton.icon(
                          onPressed: () => setState(() => hidden = !hidden),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                    if (register) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Cho phép dán mật khẩu từ trình quản lý mật khẩu.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Xác nhận mật khẩu',
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
                        decoration: InputDecoration(
                          hintText: 'Nhập lại mật khẩu',
                          prefixIcon: const Icon(Icons.verified_user_outlined),
                          suffixIcon: IconButton(
                            tooltip: hidden ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                            onPressed: () => setState(() => hidden = !hidden),
                            icon: Icon(
                              hidden
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
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
                            Icons.offline_pin_outlined,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dữ liệu học tập và ghi chú được tách riêng theo từng tài khoản trên thiết bị.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 18,
                                  color: colors.onErrorContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: TextStyle(
                                      color: colors.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (needsConfirmationPrompt) ...[
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () => _openVerification(email.text),
                                icon: const Icon(
                                  Icons.mark_email_unread_outlined,
                                ),
                                label: const Text(
                                  'Mở hướng dẫn xác nhận email',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (state.valueOrNull != null || previewNotice != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          previewNotice ?? state.valueOrNull!,
                          style: TextStyle(color: colors.onSecondaryContainer),
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
                                  ? 'Đang xử lý…'
                                  : register
                                  ? 'Đăng ký'
                                  : 'Đăng nhập',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      height: 20,
                      color: tones.subtleBorder.withValues(alpha: 0.4),
                    ),
                    TextButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              ref
                                  .read(authControllerProvider.notifier)
                                  .clearFeedback();
                              setState(() {
                                register = !register;
                                validation = null;
                                previewNotice = null;
                              });
                            },
                      child: Text(
                        register
                            ? 'Đã có tài khoản? Đăng nhập'
                            : 'Tạo tài khoản mới',
                      ),
                    ),
                    if (widget.previewMode)
                      TextButton.icon(
                        onPressed: () => _openVerification(
                          email.text.trim().isEmpty
                              ? 'hocvien@bunly.edu.vn'
                              : email.text.trim(),
                        ),
                        icon: const Icon(
                          Icons.mark_email_unread_outlined,
                          size: 18,
                        ),
                        label: const Text('Xem màn hình xác nhận email (S03)'),
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
