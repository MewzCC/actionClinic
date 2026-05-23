import 'dart:convert';
import 'dart:io';

import 'key_value_store_base.dart';

KeyValueStore createStore() => _FileKeyValueStore();

class _FileKeyValueStore implements KeyValueStore {
  File get _file {
    final env = Platform.environment;
    final base =
        env['APPDATA'] ??
        env['XDG_CONFIG_HOME'] ??
        env['HOME'] ??
        Directory.systemTemp.path;
    return File(
      '$base${Platform.pathSeparator}actionClinic${Platform.pathSeparator}state.json',
    );
  }

  @override
  Future<String?> read(String key) async {
    final values = await _readAll();
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    final values = await _readAll();
    values[key] = value;
    await _file.parent.create(recursive: true);
    await _file.writeAsString(jsonEncode(values), flush: true);
  }

  Future<Map<String, String>> _readAll() async {
    try {
      if (!await _file.exists()) return {};
      final decoded = jsonDecode(await _file.readAsString());
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return {};
    }
  }
}
