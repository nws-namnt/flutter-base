import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base/utils/extensions/string_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app/app_page.dart';
import 'common/app_env.dart';
import 'services/firebase_notification_service.dart';
import 'storage/app_preference.dart';
import 'storage/app_storage.dart';

/// Background FCM handler — must be a top-level function.
/// Runs in a separate Dart isolate; initialize Firebase with the correct flavor
/// options using [appFlavor], a compile-time constant baked in at build time.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: appFlavor.firebaseOptions);
  }
  // TODO: handle background push notification
}

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock orientation to portrait.
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    // Detect flavor from bundle ID / package name suffix:
    //   com.example.app.dev → 'dev'
    //   com.example.app.uat → 'uat'
    //   com.example.app     → 'prod'
    final packageInfo = await PackageInfo.fromPlatform();
    final flavor = packageInfo.packageName.flavor;

    await AppEnv.load(flavor: flavor);

    // Firebase — pick options matching the active flavor.
    // On iOS, Firebase may auto-initialize from GoogleService-Info.plist before Flutter starts.
    await Firebase.initializeApp(options: flavor.firebaseOptions);

    // Register background handler BEFORE initialize() — FCM requirement.
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Init local notifications + FCM token + foreground/background message streams.
    await FirebaseNotificationService.instance.initialize();

    // Local storage.
    await AppStorage.init();
    await AppPreference.init();

    // Disable Crashlytics in debug mode to avoid noise on the dashboard.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Catch errors thrown by the Flutter framework (widget build, layout, render, etc.)
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Catch async errors outside the Flutter framework (platform-level errors).
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    runApp(const AppPage());
  }, (error, stack) {
    // Catch uncaught async errors in this Dart zone (Future, Stream, Timer).
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}
