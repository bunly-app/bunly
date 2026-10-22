import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool register = false;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bunly')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                register ? 'Tạo tài khoản' : 'Đăng nhập',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: email,
                enabled: !state.isLoading,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                enabled: !state.isLoading,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu (ít nhất 8 ký tự)',
                ),
              ),
              const SizedBox(height: 16),
              if (state.hasError)
                Text(
                  state.error is FormatException
                      ? (state.error as FormatException).message
                      : 'Không thể xác thực. Kiểm tra tài khoản, xác nhận email và kết nối mạng.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (state.valueOrNull != null) Text(state.valueOrNull!),
              FilledButton(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                          .read(authControllerProvider.notifier)
                          .submit(
                            email.text,
                            password.text,
                            register: register,
                          ),
                child: Text(
                  state.isLoading
                      ? 'Đang xử lý…'
                      : register
                      ? 'Đăng ký'
                      : 'Đăng nhập',
                ),
              ),
              TextButton(
                onPressed: state.isLoading
                    ? null
                    : () => setState(() => register = !register),
                child: Text(
                  register ? 'Đã có tài khoản? Đăng nhập' : 'Tạo tài khoản mới',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
