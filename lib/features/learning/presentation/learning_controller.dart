import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/personal_repository.dart';

class LearningController extends StateNotifier<AsyncValue<void>> {
  LearningController(this.useCase) : super(const AsyncData(null));
  final UpdateLearning useCase;
  Future<bool> perform(Future<void> Function(UpdateLearning) action) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => action(useCase));
    if (!mounted) return false;
    state = result;
    return !result.hasError;
  }
}
