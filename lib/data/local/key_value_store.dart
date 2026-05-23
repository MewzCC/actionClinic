import 'key_value_store_stub.dart'
    if (dart.library.io) 'key_value_store_io.dart'
    if (dart.library.html) 'key_value_store_web.dart';
import 'key_value_store_base.dart';

KeyValueStore createKeyValueStore() => createStore();
