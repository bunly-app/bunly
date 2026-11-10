import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/request_password_reset.dart';

class PasswordResetController extends StateNotifier<AsyncValue<bool>> {
  PasswordResetController(this._requestReset) : super(const AsyncData(false));

  final RequestPasswordReset _requestReset;

  Future<bool> submit(String email) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard<bool>(() async {
      await _requestReset(email);
      return true;
    });
    if (mounted) state = result;
    return result.valueOrNull == true;
  }

  void resetState() {
    if (!state.isLoading) state = const AsyncData(false);
  }
}
