import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_repository.dart';
import '../domain/update_password.dart';

class UpdatePasswordController extends StateNotifier<AsyncValue<bool>> {
  UpdatePasswordController(this._updatePassword, this._authRepository)
    : super(const AsyncData(false));

  final UpdatePassword _updatePassword;
  final AuthRepository _authRepository;

  Future<bool> submit(String newPassword) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard<bool>(() async {
      await _updatePassword(newPassword);
      return true;
    });
    if (mounted) state = result;
    return result.valueOrNull == true;
  }

  Future<void> finishRecovery() => _authRepository.completeRecovery();

  Future<void> cancelRecovery() async {
    await _authRepository.completeRecovery();
    await _authRepository.signOut();
  }
}
