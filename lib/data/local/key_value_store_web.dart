// ignore_for_file: avoid_web_libraries_in_flutter

// ignore: deprecated_member_use
import 'dart:html' as html;

import 'key_value_store_base.dart';

KeyValueStore createStore() => _WebKeyValueStore();

class _WebKeyValueStore implements KeyValueStore {
  @override
  Future<String?> read(String key) async => html.window.localStorage[key];

  @override
  Future<void> write(String key, String value) async {
    html.window.localStorage[key] = value;
  }
}
