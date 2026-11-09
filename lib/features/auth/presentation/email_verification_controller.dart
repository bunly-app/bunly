import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/resend_confirmation.dart';

class EmailVerificationController extends StateNotifier<AsyncValue<String?>> {
  EmailVerificationController(this._resend) : super(const AsyncData(null));

  final ResendConfirmation _resend;

  Future<bool> resend(String email) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard<String?>(() async {
      await _resend(email);
      return 'Nếu địa chỉ này đang chờ xác nhận, Bunly đã gửi lại liên kết vào hộp thư của bạn.';
    });
    if (mounted) state = result;
    return !result.hasError;
  }

  void clear() {
    if (!state.isLoading) state = const AsyncData(null);
  }
}
