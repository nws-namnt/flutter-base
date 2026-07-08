import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base/pages/widgets/render_error_widget.dart' show RenderErrorWidget;
import 'package:flutter_base/utils/extensions/_extension.dart';
import 'package:flutter_base/utils/extensions/string_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app/app_page.dart';
import 'common/app_env.dart';
import 'services/firebase_notification_service.dart';
import 'services/network_service.dart';
import 'storage/app_preference.dart';
import 'storage/app_storage.dart';
import 'utils/extensions/file_extension.dart';

/// Background FCM handler — must be a top-level function.
/// Runs in a separate Dart isolate; initialize Firebase with the correct flavor
/// options using [appFlavor], a compile-time constant baked in at build time.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: appFlavor.firebaseOptions);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
  // TODO: handle background push notification
}

/// Shared entry point invoked by [main_dev.main], [main_uat.main], and
/// [main_prod.main].
///
/// Detects the active flavor from the bundle ID suffix, loads the matching
/// `.env.<flavor>` config via [AppEnv.load], initializes Firebase, local
/// notifications/FCM, local storage, and network monitoring, wires up
/// Crashlytics error reporting, then runs [AppPage] inside a guarded zone
/// so uncaught async errors are reported instead of crashing silently.
Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Replace Flutter's default red error screen. Must be set before any
      // widget builds — as early as possible in main().
      ErrorWidget.builder = (details) => RenderErrorWidget(details: details);

      // Lock orientation to portrait.
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Detect flavor from bundle ID / package name suffix:
      //   com.example.app.dev → 'dev'
      //   com.example.app.uat → 'uat'
      //   com.example.app     → 'prod'
      final packageInfo = await PackageInfo.fromPlatform();
      final flavor = packageInfo.flavor;

      await AppEnv.load(flavor: flavor);

      // Firebase initialization.
      //
      // On ALL platforms, Firebase is auto-initialized by the native layer before
      // Dart starts:
      //   - iOS/macOS: FLTFirebaseCorePlugin calls [FIRApp configure] during plugin
      //     registration, using GoogleService-Info.plist copied by the Xcode Run Script.
      //   - Android: FirebaseInitProvider (a ContentProvider) runs at app start using
      //     the google-services.json baked in by the google-services Gradle plugin.
      //     For this project, flavor-specific files under src/<flavor>/google-services.json
      //     are automatically selected at build time, so the correct Firebase project is
      //     always used.
      //
      // Dart's initializeApp() must NOT pass options — it only attaches to the
      // already-running native instance.
      await Firebase.initializeApp();

      // Register background handler BEFORE initialize() — FCM requirement.
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

      // Init local notifications + FCM token + foreground/background message streams.
      await FirebaseNotificationService.instance.initialize();

      // Local storage.
      await AppStorage.init();
      await AppPreference.init();

      // Sweep stale copies out of the temp `Files` directory (see
      // file_extension.dart). Fire-and-forget: cleanup hygiene shouldn't delay
      // app launch, and a failure here is non-fatal (logged internally).
      unawaited(clearExpiredTmpFiles());

      // Network monitoring — must run before runApp so isConnected is valid
      // on the first frame.
      await networkService.initialize();

      // Disable Crashlytics in debug mode to avoid noise on the dashboard.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );

      // Catch errors thrown by the Flutter framework (widget build, layout, render, etc.)
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Catch async errors outside the Flutter framework (platform-level errors).
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      runApp(const AppPage());
    },
    (error, stack) {
      // Catch uncaught async errors in this Dart zone (Future, Stream, Timer).
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}
