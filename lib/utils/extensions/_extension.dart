import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'string_extension.dart';

/// Convenience getters built on top of [PackageInfo] (`package_info_plus`).
///
/// Useful for About screens, crash report metadata, and Dio `User-Agent` headers.
extension PackageExtension on PackageInfo {
  /// Active flavor derived from [PackageInfo.packageName] — `'dev'` | `'uat'` | `'prod'`.
  ///
  /// See [StringExtension.flavor].
  String get flavor => packageName.flavor;

  /// `version+buildNumber`, e.g. `1.2.3+45`.
  String get fullVersion => '$version+$buildNumber';

  /// Human-readable version for display, e.g. `v1.2.3 (45)`.
  String get displayVersion => 'v$version ($buildNumber)';

  /// `true` if the app was installed through an app store (Play Store,
  /// App Store, etc.) rather than sideloaded.
  ///
  /// [PackageInfo.installerStore] is null/empty for sideloaded APKs and most
  /// debug builds.
  bool get isInstalledFromStore =>
      installerStore != null && installerStore!.isNotEmpty;

  /// Compact identifier for Dio `User-Agent` headers and crash report context.
  String get userAgent => '$appName/$version (Build $buildNumber; $packageName)';
}

/// Cross-platform convenience getters built on top of [DeviceInfoPlugin]
/// (`device_info_plus`).
///
/// Resolves the Android/iOS branch internally so call sites (e.g.
/// [PermissionService]) don't need repeated `Platform.isAndroid` checks.
extension DeviceInfoExtension on DeviceInfoPlugin {
  /// Human-readable platform name — `'Android'`, `'iOS'`, or
  /// [Platform.operatingSystem] as a fallback.
  String get platformName {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return Platform.operatingSystem;
  }

  /// Android API level, e.g. `34`. Returns `0` on non-Android platforms.
  Future<int> get androidSdkInt async {
    if (!Platform.isAndroid) return 0;
    return (await androidInfo).version.sdkInt;
  }

  /// OS version string — Android `release` (e.g. `14`) or iOS `systemVersion`
  /// (e.g. `17.4`). Empty string on unsupported platforms.
  Future<String> get osVersion async {
    if (Platform.isAndroid) return (await androidInfo).version.release;
    if (Platform.isIOS) return (await iosInfo).systemVersion;
    return '';
  }

  /// Commercial/marketing device model name — Android `model` (e.g.
  /// `Pixel 8`) or iOS `modelName` (e.g. `iPhone 16 Pro`). Empty string on
  /// unsupported platforms.
  ///
  /// Note: iOS's own `model` field (unlike Android's) is *not* specific —
  /// `UIDevice.model` returns the generic `"iPhone"`/`"iPad"` on every
  /// device, so `modelName` is used instead to stay meaningful.
  Future<String> get deviceModel async {
    if (Platform.isAndroid) return (await androidInfo).model;
    if (Platform.isIOS) return (await iosInfo).modelName;
    return '';
  }

  /// User-assigned device name (Android `Settings.Global.DEVICE_NAME` /
  /// iOS `UIDevice.name`), e.g. `"Fox's iPhone"`. Empty string on
  /// unsupported platforms.
  ///
  /// This is personal data (PII), not a hardware model — think before
  /// logging it to analytics/crash reports. On iOS 16+, Apple returns a
  /// generic placeholder unless the app has the Apple-granted
  /// `com.apple.developer.device-information.user-assigned-device-name`
  /// entitlement.
  Future<String> get deviceName async {
    if (Platform.isAndroid) return (await androidInfo).name;
    if (Platform.isIOS) return (await iosInfo).name;
    return '';
  }

  /// Internal Android build codename (`Build.PRODUCT`, e.g. `"raven"` for
  /// the Pixel 6 Pro) — not user-facing, useful for device-specific debug
  /// lookups. Android-only; empty string on other platforms since iOS has
  /// no equivalent concept (see [deviceModel] / [iosMachineIdentifier]
  /// instead).
  Future<String> get androidProductCodename async =>
      Platform.isAndroid ? (await androidInfo).product : '';

  /// Raw iOS hardware identifier (e.g. `iPhone15,2`), not the marketing
  /// name — use [deviceModel] for a human-readable name. iOS-only; empty
  /// string on other platforms.
  Future<String> get iosMachineIdentifier async =>
      Platform.isIOS ? (await iosInfo).utsname.machine : '';

  /// `false` when running on an emulator/simulator, `true` on a physical
  /// device (and as a safe default on unsupported platforms).
  Future<bool> get isPhysicalDevice async {
    if (Platform.isAndroid) return (await androidInfo).isPhysicalDevice;
    if (Platform.isIOS) return (await iosInfo).isPhysicalDevice;
    return true;
  }

  /// iOS-only vendor-scoped identifier (resets on app uninstall, shared
  /// across apps from the same vendor). `null` on Android — this plugin does
  /// not expose a persistent device identifier there by design (privacy).
  Future<String?> get iosVendorId async =>
      Platform.isIOS ? (await iosInfo).identifierForVendor : null;

  /// Free disk space, in **bytes** (`AndroidDeviceInfo.freeDiskSize` /
  /// `IosDeviceInfo.freeDiskSize` — both already built into
  /// `device_info_plus`, no extra package needed). `0` on unsupported
  /// platforms.
  Future<int> get freeDiskSize async {
    if (Platform.isAndroid) return (await androidInfo).freeDiskSize;
    if (Platform.isIOS) return (await iosInfo).freeDiskSize;
    return 0;
  }

  /// Total disk capacity, in **bytes**. `0` on unsupported platforms.
  Future<int> get totalDiskSize async {
    if (Platform.isAndroid) return (await androidInfo).totalDiskSize;
    if (Platform.isIOS) return (await iosInfo).totalDiskSize;
    return 0;
  }

  /// Total physical RAM, in **megabytes**. `0` on unsupported platforms.
  Future<int> get physicalRamSize async {
    if (Platform.isAndroid) return (await androidInfo).physicalRamSize;
    if (Platform.isIOS) return (await iosInfo).physicalRamSize;
    return 0;
  }

  /// Currently unallocated ("free") RAM, in **megabytes**. `0` on
  /// unsupported platforms.
  Future<int> get availableRamSize async {
    if (Platform.isAndroid) return (await androidInfo).availableRamSize;
    if (Platform.isIOS) return (await iosInfo).availableRamSize;
    return 0;
  }

  /// `true` if Android considers this a low-RAM device
  /// (`ActivityManager.isLowRamDevice`). Android-only — always `false` on
  /// iOS/other platforms since there's no equivalent API.
  Future<bool> get isLowRamDevice async =>
      Platform.isAndroid ? (await androidInfo).isLowRamDevice : false;
}
