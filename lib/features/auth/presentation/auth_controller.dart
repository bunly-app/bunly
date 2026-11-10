import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/authenticate.dart';

enum AuthSubmitOutcome { signedIn, needsConfirmation, failed }

class AuthController extends StateNotifier<AsyncValue<String?>> {
  AuthController(this.authenticate) : super(const AsyncData(null));
  final Authenticate authenticate;

  Future<AuthSubmitOutcome> submit(
    String email,
    String password, {
    required bool register,
  }) async {
    if (state.isLoading) return AuthSubmitOutcome.failed;
    state = const AsyncLoading();
    var outcome = AuthSubmitOutcome.failed;
    final result = await AsyncValue.guard<String?>(() async {
      final hasSession = await authenticate(
        email,
        password,
        register: register,
      );
      outcome = hasSession
          ? AuthSubmitOutcome.signedIn
          : AuthSubmitOutcome.needsConfirmation;
      return hasSession
          ? null
          : 'Kiểm tra hộp thư để xác nhận tài khoản, sau đó đăng nhập.';
    });
    if (mounted) state = result;
    return result.hasError ? AuthSubmitOutcome.failed : outcome;
  }

  void clearFeedback() {
    if (!state.isLoading) {
      state = const AsyncData(null);
    }
  }
}
