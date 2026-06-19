import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import '../../firebase/dev/firebase_options.dart' as firebase_dev show DefaultFirebaseOptions;
import '../../firebase/dev/firebase_options.dart' as firebase_prod show DefaultFirebaseOptions;
import '../../firebase/dev/firebase_options.dart' as firebase_uat show DefaultFirebaseOptions;

/// String helpers used during app startup to resolve the active flavor.
///
/// Applied to `PackageInfo.packageName` in `main()`.
extension StringExtension on String {
  /// Derives the active flavor from the bundle ID / package name suffix.
  ///
  /// - Ends with `.dev` → `'dev'`
  /// - Ends with `.uat` → `'uat'`
  /// - Otherwise → `'prod'`
  String get flavor {
    if (endsWith('.dev')) return 'dev';
    if (endsWith('.uat')) return 'uat';
    return 'prod';
  }

  /// Returns the [FirebaseOptions] that match this string's [flavor].
  ///
  /// Used in `main()` to call `Firebase.initializeApp(options: flavor.firebaseOptions)`.
  FirebaseOptions get firebaseOptions => switch (flavor) {
    'dev' => firebase_dev.DefaultFirebaseOptions.currentPlatform,
    'uat' => firebase_uat.DefaultFirebaseOptions.currentPlatform,
    _ => firebase_prod.DefaultFirebaseOptions.currentPlatform,
  };
}