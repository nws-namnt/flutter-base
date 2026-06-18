import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base/utils/extensions/string_extension.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app/app_page.dart';
import 'common/app_env.dart';

/// Background FCM handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
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
    await Firebase.initializeApp(options: flavor.firebaseOptions);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Local storage.
    await GetStorage.init();

    runApp(const AppPage());
  }, (error, stack) {
    debugPrint('[ERROR] $error\n$stack');
  });
}
