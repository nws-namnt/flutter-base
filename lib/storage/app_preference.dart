import 'package:shared_preferences/shared_preferences.dart';

import '../common/app_enums.dart' show AppPreferenceKey;

/// A singleton wrapper around [SharedPreferences] for persistent key-value storage.
///
/// Suited for primitive values (bool, String, int, double) such as auth tokens,
/// user settings, and onboarding flags. For complex objects or reactive storage,
/// prefer [AppStorage] (GetStorage).
///
/// All keys are typed via [AppPreferenceKey] to prevent typos and centralise
/// key management. Add new keys to [AppPreferenceKey] before adding methods here.
///
/// ## Setup
///
/// Call [AppPreference.init] once in `main()` before [runApp]:
///
/// ```dart
/// await AppPreference.init();
/// runApp(const AppPage());
/// ```
///
/// ## Usage
///
/// ```dart
/// // Write
/// await AppPreference.instance.setTest(true);
///
/// // Read (returns false if not set)
/// final isTest = AppPreference.instance.getTest();
///
/// // Check existence
/// final exists = AppPreference.instance.existData(AppPreferenceKey.kTest);
///
/// // Remove a single key
/// await AppPreference.instance.removeTest();
///
/// // Remove all keys defined in AppPreferenceKey
/// await AppPreference.instance.clearAllKey();
///
/// // Clear the entire SharedPreferences store
/// await AppPreference.instance.clearAll();
/// ```
class AppPreference {
  AppPreference._();

  /// The global singleton instance.
  static final AppPreference instance = AppPreference._();

  static late SharedPreferences _prefs;

  /// Initialises [SharedPreferences]. Must be awaited in `main()` before [runApp].
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Returns `true` if [key] has a stored value.
  bool existData(AppPreferenceKey key) => _prefs.containsKey(key.key);

  /// Removes the value associated with [key].
  Future<void> removeKey(AppPreferenceKey key) => _prefs.remove(key.key);

  /// Removes every key defined in [AppPreferenceKey].
  Future<void> clearAllKey() async {
    for (final k in AppPreferenceKey.values) {
      await removeKey(k);
    }
  }

  /// Clears the entire [SharedPreferences] store, including keys outside [AppPreferenceKey].
  Future<void> clearAll() => _prefs.clear();

  // Key-specific helpers — add one set (set / get / remove) per AppPreferenceKey.
  /// Persists [value] under [AppPreferenceKey.kTest].
  Future<void> setTest(bool value) => _prefs.setBool(AppPreferenceKey.kTest.key, value);

  /// Returns the stored test flag, or `false` if not set.
  bool getTest() => _prefs.getBool(AppPreferenceKey.kTest.key) ?? false;

  /// Removes [AppPreferenceKey.kTest] from storage.
  Future<void> removeTest() => removeKey(AppPreferenceKey.kTest);
}
