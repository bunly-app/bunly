enum AppThemePreference {
  system,
  light,
  dark;

  String get storageValue => name;

  static AppThemePreference fromStorageValue(String? raw) {
    return switch (raw) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => AppThemePreference.system,
    };
  }
}

abstract interface class AppSettingsRepository {
  Future<AppThemePreference> loadThemePreference();
  Future<void> saveThemePreference(AppThemePreference preference);
}
