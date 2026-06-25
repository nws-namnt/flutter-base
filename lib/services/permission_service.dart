import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Global getter — shorthand for [PermissionService.instance].
///
/// ```dart
/// final status = await permissionService.requestCamera();
/// if (status.isGranted) { ... }
/// ```
PermissionService get permissionService => PermissionService.instance;

/// Singleton service centralizing all runtime permission requests.
///
/// For the full list of available permissions and their platform requirements,
/// see [PERMISSIONS.md](../../../doc/PERMISSIONS.md).
class PermissionService {
  PermissionService._internal();

  static final PermissionService instance = PermissionService._internal();

  /// Returns the current [PermissionStatus] without requesting.
  ///
  /// Use this to check before deciding whether to show a rationale UI
  /// or call [requestPermission] directly.
  Future<PermissionStatus> checkStatus(Permission permission) =>
      permission.status;

  /// Requests a single [permission] and returns its [PermissionStatus].
  ///
  /// Automatically calls [openAppSettings] when the status is
  /// [PermissionStatus.permanentlyDenied] — show a message directing the
  /// user to re-enable the permission in Settings.
  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isPermanentlyDenied) await openAppSettings();
    return status;
  }

  /// Requests multiple permissions in a single call.
  ///
  /// Returns a map of each [Permission] to its [PermissionStatus].
  /// Permissions already granted will not trigger a dialog.
  ///
  /// Note: [openAppSettings] is NOT called automatically here — check for
  /// [PermissionStatus.isPermanentlyDenied] in the result and call
  /// [openSettings] manually when appropriate.
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) =>
      permissions.request();

  /// Opens the app's system settings page.
  ///
  /// Call this when a permission is [PermissionStatus.permanentlyDenied]
  /// or [PermissionStatus.restricted].
  Future<void> openSettings() => openAppSettings();

  // COMMON PERMISSION WRAPPERS
  /// Requests camera access (front and back).
  ///
  /// Android: `CAMERA` — iOS: `NSCameraUsageDescription`
  Future<PermissionStatus> requestCamera() =>
      requestPermission(Permission.camera);

  /// Requests microphone access for audio recording.
  ///
  /// Android: `RECORD_AUDIO` — iOS: `NSMicrophoneUsageDescription`
  Future<PermissionStatus> requestMicrophone() =>
      requestPermission(Permission.microphone);

  /// Requests permission to send push notifications.
  ///
  /// Android 13+ (API 33+): shows a runtime dialog.
  /// Android below 13: always returns [PermissionStatus.granted] — no dialog.
  /// iOS: `UNUserNotificationCenter` authorization (alert, sound, badge).
  Future<PermissionStatus> requestNotification() =>
      requestPermission(Permission.notification);

  /// Requests read/write access to device contacts.
  ///
  /// Android: `READ_CONTACTS`, `WRITE_CONTACTS` — iOS: `NSContactsUsageDescription`
  Future<PermissionStatus> requestContacts() =>
      requestPermission(Permission.contacts);

  /// Requests all Bluetooth permissions required for full BLE functionality.
  ///
  /// Android 12+ (API 31+): requests `BLUETOOTH_SCAN` + `BLUETOOTH_ADVERTISE`
  /// + `BLUETOOTH_CONNECT` as a batch. Returns [PermissionStatus.granted] only
  /// when all three are granted; [PermissionStatus.denied] otherwise.
  /// Android below 12 / iOS: requests [Permission.bluetooth] directly.
  Future<PermissionStatus> requestBluetooth() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (sdk >= 31) {
        final results = await requestPermissions([
          Permission.bluetoothScan,
          Permission.bluetoothAdvertise,
          Permission.bluetoothConnect,
        ]);
        if (results.values.any((s) => s.isPermanentlyDenied)) {
          await openAppSettings();
          return PermissionStatus.permanentlyDenied;
        }
        return results.values.every((s) => s.isGranted)
            ? PermissionStatus.granted
            : PermissionStatus.denied;
      }
    }
    return requestPermission(Permission.bluetooth);
  }

  // PERMISSIONS WITH PLATFORM-SPECIFIC LOGIC
  /// Requests foreground location access (while app is in use).
  ///
  /// Android: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION`
  /// iOS: CoreLocation WhenInUse — plist: `NSLocationWhenInUseUsageDescription`
  Future<PermissionStatus> requestLocationWhenInUse() =>
      requestPermission(Permission.locationWhenInUse);

  /// Requests access to photos/images.
  ///
  /// Android 13+ (API 33+): `READ_MEDIA_IMAGES`
  /// Android 12 and below: `READ_EXTERNAL_STORAGE`
  /// iOS: `PHPhotoLibrary` read+write — plist: `NSPhotoLibraryUsageDescription`
  Future<PermissionStatus> requestPhotos() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      return requestPermission(
        sdk >= 33 ? Permission.photos : Permission.storage,
      );
    }
    return requestPermission(Permission.photos);
  }

  /// Requests access to video files.
  ///
  /// Android 13+ (API 33+): `READ_MEDIA_VIDEO`
  /// Android 12 and below: `READ_EXTERNAL_STORAGE`
  /// iOS: not applicable — returns [PermissionStatus.granted] directly,
  /// video files are accessible via file picker without a runtime permission.
  Future<PermissionStatus> requestVideos() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      return requestPermission(
        sdk >= 33 ? Permission.videos : Permission.storage,
      );
    }
    return PermissionStatus.granted;
  }

  /// Requests access to audio files.
  ///
  /// Android 13+ (API 33+): `READ_MEDIA_AUDIO`
  /// Android 12 and below: `READ_EXTERNAL_STORAGE`
  /// iOS: not applicable — returns [PermissionStatus.granted] directly,
  /// audio files are accessible via file picker without a runtime permission.
  Future<PermissionStatus> requestAudio() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      return requestPermission(
        sdk >= 33 ? Permission.audio : Permission.storage,
      );
    }
    return PermissionStatus.granted;
  }
}
