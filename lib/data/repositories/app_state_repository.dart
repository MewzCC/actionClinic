import 'dart:convert';

import '../../core/constants/storage_keys.dart';
import '../local/key_value_store.dart';
import '../local/key_value_store_base.dart';
import '../models/app_setting_model.dart';
import '../models/task_model.dart';

class PersistedAppState {
  const PersistedAppState({
    required this.tasks,
    required this.currentTaskId,
    required this.settings,
  });

  final List<ClinicTask> tasks;
  final String currentTaskId;
  final UserSettings settings;
}

class AppStateRepository {
  AppStateRepository({KeyValueStore? store})
    : _store = store ?? createKeyValueStore();

  final KeyValueStore _store;

  Future<PersistedAppState> load() async {
    final tasks = _decodeTasks(
      await _store.read(StorageKeys.tasks),
    ).where((task) => !_defaultSeedIds.contains(task.id)).toList();
    final savedTasks = tasks;
    final currentTaskId = await _store.read(StorageKeys.currentTaskId) ?? '';
    final settings = _decodeSettings(await _store.read(StorageKeys.settings));

    return PersistedAppState(
      tasks: savedTasks,
      currentTaskId: savedTasks.any((task) => task.id == currentTaskId)
          ? currentTaskId
          : (savedTasks.isEmpty ? '' : savedTasks.first.id),
      settings: settings,
    );
  }

  Future<void> save({
    required List<ClinicTask> tasks,
    required String currentTaskId,
    required UserSettings settings,
  }) async {
    await _store.write(
      StorageKeys.tasks,
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
    await _store.write(StorageKeys.currentTaskId, currentTaskId);
    await _store.write(StorageKeys.settings, jsonEncode(settings.toJson()));
  }

  List<ClinicTask> _decodeTasks(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((task) => ClinicTask.fromJson(Map<String, Object?>.from(task)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  UserSettings _decodeSettings(String? raw) {
    if (raw == null || raw.isEmpty) return UserSettings.initial();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return UserSettings.initial();
      return UserSettings.fromJson(Map<String, Object?>.from(decoded));
    } catch (_) {
      return UserSettings.initial();
    }
  }
}

const _defaultSeedIds = {'task_prd', 'task_reading', 'task_exercise'};
