import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sign_out.dart';

class SignOutController extends StateNotifier<AsyncValue<void>> {
  SignOutController(this.signOut) : super(const AsyncData(null));
  final SignOut signOut;

  Future<bool> submit() async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(signOut.call);
    if (mounted) state = result;
    return !result.hasError;
  }
}
