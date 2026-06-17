import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import '../../firebase/dev/firebase_options.dart' as firebase_dev show DefaultFirebaseOptions;
import '../../firebase/dev/firebase_options.dart' as firebase_prod show DefaultFirebaseOptions;
import '../../firebase/dev/firebase_options.dart' as firebase_uat show DefaultFirebaseOptions;

extension StringExtension on String {
  String get flavor {
    if (endsWith('.dev')) return 'dev';
    if (endsWith('.uat')) return 'uat';
    return 'prod';
  }

  FirebaseOptions get firebaseOptions => switch (flavor) {
    'dev' => firebase_dev.DefaultFirebaseOptions.currentPlatform,
    'uat' => firebase_uat.DefaultFirebaseOptions.currentPlatform,
    _ => firebase_prod.DefaultFirebaseOptions.currentPlatform,
  };
}