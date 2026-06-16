import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'common/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect flavor from bundle ID / package name suffix.
  // Convention:
  //   com.example.app.dev  → 'dev'
  //   com.example.app.uat  → 'uat'
  //   com.example.app      → 'prod'  (no suffix)
  final packageInfo = await PackageInfo.fromPlatform();
  final flavor = _detectFlavor(packageInfo.packageName);

  // Load and validate the matching .env file.
  await AppEnv.load(flavor: flavor);
  debugPrint('AppEnv loaded with flavor: ${AppEnv.apiBaseUrl}');
  runApp(const MyApp());
}

/// Infers the build flavor from the app's package name (Android) /
/// bundle identifier (iOS).
String _detectFlavor(String packageName) {
  if (packageName.endsWith('.dev')) return 'dev';
  if (packageName.endsWith('.uat')) return 'uat';
  return 'prod';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Base',
      debugShowCheckedModeBanner: AppEnv.showDebugBanner,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Base')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Flavor: ${AppEnv.flavor}'),
              Text('API: ${AppEnv.apiBaseUrl}'),
            ],
          ),
        ),
      ),
    );
  }
}
