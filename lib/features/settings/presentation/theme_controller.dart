import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_settings_repository.dart';

class ThemeController extends StateNotifier<AppThemePreference> {
  ThemeController(this._repository) : super(AppThemePreference.system) {
    unawaited(_restore());
  }

  final AppSettingsRepository? _repository;
  bool _userChanged = false;

  Future<void> _restore() async {
    final repo = _repository;
    if (repo == null) return;
    try {
      final loaded = await repo.loadThemePreference();
      if (mounted && !_userChanged) state = loaded;
    } catch (_) {}
  }

  Future<bool> setPreference(AppThemePreference preference) async {
    _userChanged = true;
    state = preference;
    final repo = _repository;
    if (repo == null) return true;
    try {
      await repo.saveThemePreference(preference);
      return true;
    } catch (_) {
      return false;
    }
  }
}
