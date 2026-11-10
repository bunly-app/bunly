import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/app_settings_repository.dart';

class LocalAppSettingsRepository implements AppSettingsRepository {
  LocalAppSettingsRepository(this.database);

  final AppDatabase database;

  static const _namespace = 'app';
  static const _ownerId = 'device';
  static const _entityTable = 'app_settings';
  static const _themeRecordId = 'theme_mode';

  @override
  Future<AppThemePreference> loadThemePreference() async {
    final row =
        await (database.select(database.personalRecords)..where(
              (r) =>
                  r.namespace.equals(_namespace) &
                  r.ownerId.equals(_ownerId) &
                  r.entityTable.equals(_entityTable) &
                  r.recordId.equals(_themeRecordId),
            ))
            .getSingleOrNull();
    if (row == null) return AppThemePreference.system;
    try {
      final decoded = jsonDecode(row.payload);
      if (decoded is Map<String, dynamic>) {
        return AppThemePreference.fromStorageValue(
          decoded['theme_mode'] as String?,
        );
      }
    } catch (_) {}
    return AppThemePreference.system;
  }

  @override
  Future<void> saveThemePreference(AppThemePreference preference) async {
    await database
        .into(database.personalRecords)
        .insertOnConflictUpdate(
          PersonalRecordsCompanion.insert(
            namespace: _namespace,
            ownerId: _ownerId,
            entityTable: _entityTable,
            recordId: _themeRecordId,
            payload: jsonEncode({'theme_mode': preference.storageValue}),
          ),
        );
  }
}
