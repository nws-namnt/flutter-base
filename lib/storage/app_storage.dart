import 'package:get_storage/get_storage.dart';

import '../common/app_enums.dart' show AppStorageKey;

/// A singleton wrapper around [GetStorage] for key-value local storage.
///
/// All keys are typed via [AppStorageKey] to prevent typos and centralise
/// key management. Add new keys to [AppStorageKey] before adding methods here.
///
/// ## Setup
///
/// Call [AppStorage.init] once in `main()` before [runApp]:
///
/// ```dart
/// await AppStorage.init();
/// runApp(const AppPage());
/// ```
///
/// ## Usage
///
/// ```dart
/// // Write
/// await AppStorage.instance.setTest(true);
///
/// // Read (returns false if not set)
/// final isTest = AppStorage.instance.getTest();
///
/// // Check existence
/// final exists = AppStorage.instance.existData(AppStorageKey.kTest);
///
/// // Remove a single key
/// await AppStorage.instance.removeTest();
///
/// // Remove all keys defined in AppStorageKey
/// await AppStorage.instance.clearAllKey();
///
/// // Erase the entire storage box
/// await AppStorage.instance.clearStorage();
/// ```
class AppStorage {
  AppStorage._();

  /// The global singleton instance.
  static final AppStorage instance = AppStorage._();

  final GetStorage _storage = GetStorage();

  /// Initialises [GetStorage]. Must be awaited in `main()` before [runApp].
  static Future<void> init() => GetStorage.init();

  /// Erases all data in the storage box.
  Future<void> clearStorage() => _storage.erase();

  /// Removes the value associated with [k].
  Future<void> clearKey(AppStorageKey k) => _storage.remove(k.key);

  /// Removes every key defined in [AppStorageKey].
  Future<void> clearAllKey() async {
    for (final k in AppStorageKey.values) {
      await clearKey(k);
    }
  }

  /// Returns `true` if [key] has a stored value.
  bool existData(AppStorageKey key) => _storage.hasData(key.key);

  // Key-specific helpers — add one set (set / get / remove) per AppStorageKey.
  /// Persists [value] under [AppStorageKey.kTest].
  Future<void> setTest(bool value) => _storage.write(AppStorageKey.kTest.key, value);

  /// Returns the stored test flag, or `false` if not set.
  bool getTest() => _storage.read<bool?>(AppStorageKey.kTest.key) ?? false;

  /// Removes [AppStorageKey.kTest] from storage.
  Future<void> removeTest() => clearKey(AppStorageKey.kTest);
}
