import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/authenticate.dart';

class AuthController extends StateNotifier<AsyncValue<String?>> {
  AuthController(this.authenticate) : super(const AsyncData(null));
  final Authenticate authenticate;

  Future<void> submit(
    String email,
    String password, {
    required bool register,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard<String?>(() async {
      final hasSession = await authenticate(
        email,
        password,
        register: register,
      );
      return hasSession
          ? null
          : 'Kiểm tra hộp thư để xác nhận tài khoản, sau đó đăng nhập.';
    });
    if (mounted) state = result;
  }
}
