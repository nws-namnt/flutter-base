// ─── Pigeon API definition file ───────────────────────────────────────────────
//
// This file is the single source of truth for all Flutter ↔ native interfaces.
// It is NOT compiled as part of the app — it is only read by the Pigeon tool.
//
// ── Regenerating generated code ──────────────────────────────────────────────
//
//   dart run pigeon --input pigeon/api.dart
//
// Run this command every time you add, remove, or rename an interface or method.
// The command overwrites:
//   • lib/generated/pigeon_api.g.dart          (Dart — do not edit manually)
//   • android/.../generated/PigeonApi.g.kt     (Kotlin — do not edit manually)
//   • ios/Runner/generated/PigeonApi.g.swift   (Swift — do not edit manually)
//
// ── Adding a new API ─────────────────────────────────────────────────────────
//
// 1. Declare a new abstract class here annotated with @HostApi().
// 2. Run: dart run pigeon --input pigeon/api.dart
// 3. Create the implementation class in each native platform:
//      Android : android/app/src/main/kotlin/.../bridge/<Name>Bridge.kt
//      iOS     : ios/Runner/Bridge/<Name>Bridge.swift
// 4. Register the implementation in MainActivity.kt and AppDelegate.swift:
//      Android : <ClassName>Api.setUp(messenger, <ClassName>Bridge(...))
//      iOS     : <ClassName>ApiSetup.setUp(binaryMessenger: ..., api: <ClassName>Bridge())
// 5. Use the generated Dart class directly in your Dart code:
//      final api = <ClassName>Api();
//      final result = await api.<methodName>();
//
// ── Channel naming ────────────────────────────────────────────────────────────
//
// Pigeon derives channel names from the class names automatically.
// Do not create manual MethodChannels for anything declared here.
//
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/generated/pigeon_api.g.dart',
  dartPackageName: 'flutter_base',
  kotlinOut: 'android/app/src/main/kotlin/com/fox/base/flutter/generated/PigeonApi.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.fox.base.flutter.generated'),
  swiftOut: 'ios/Runner/generated/PigeonApi.g.swift',
))

// ── BatteryApi ────────────────────────────────────────────────────────────────
//
// Reads battery information from the host platform.
//
// Android implementation : bridge/BatteryApiBridge.kt
// iOS implementation     : Bridge/BatteryApiBridge.swift
//
// Usage (Dart):
//   final battery = BatteryApi();
//   final level = await battery.getBatteryLevel(); // e.g. 87
@HostApi()
abstract class BatteryApi {
  /// Returns the current battery charge level as a percentage (0–100).
  ///
  /// Throws a [PlatformException] if the battery state is unavailable
  /// (e.g. some Android emulators or iOS Simulator without mock handling).
  int getBatteryLevel();
}

// ── DeviceApi ─────────────────────────────────────────────────────────────────
//
// Reads device identity and model information from the host platform.
//
// Android implementation : bridge/DeviceApiBridge.kt
// iOS implementation     : Bridge/DeviceApiBridge.swift
//
// Usage (Dart):
//   final device = DeviceApi();
//   final id    = await device.getDeviceId(); // e.g. "A1B2C3D4-..."
//   final model = await device.getModel();    // e.g. "Samsung Galaxy S24"
@HostApi()
abstract class DeviceApi {
  /// Returns a unique device identifier.
  ///
  /// Android: [android.os.Build.ID].
  /// iOS: [UIDevice.identifierForVendor] UUID string, or `"unknown"` if nil.
  String getDeviceId();

  /// Returns a human-readable device model string.
  ///
  /// Android: `"<Manufacturer> <Model>"` (e.g. `"Samsung SM-S921B"`).
  /// iOS: [UIDevice.model] (e.g. `"iPhone"`).
  String getModel();
}

// ── BluetoothApi ──────────────────────────────────────────────────────────────
//
// Queries Bluetooth state and bonded/paired devices from the host platform.
//
// Android implementation : bridge/BluetoothApiBridge.kt
// iOS implementation     : Bridge/BluetoothApiBridge.swift  (TODO)
//
// Android permissions required (AndroidManifest.xml):
//   API ≤ 30 : BLUETOOTH, BLUETOOTH_ADMIN
//   API ≥ 31 : BLUETOOTH_CONNECT, BLUETOOTH_SCAN
//
// Usage (Dart):
//   final bt = BluetoothApi();
//   if (await bt.isEnabled()) {
//     final devices = await bt.getDevices();
//   }
@HostApi()
abstract class BluetoothApi {
  /// Returns a list of bonded (paired) Bluetooth device names.
  ///
  /// Returns an empty list if Bluetooth is disabled or permission is denied.
  List<String> getDevices();

  /// Returns `true` if Bluetooth is currently enabled on the device.
  bool isEnabled();
}