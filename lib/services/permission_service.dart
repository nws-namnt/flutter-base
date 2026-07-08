import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_base/utils/app_utils.dart';
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
  Future<void> openSettings() async {
    final canOpen = await openAppSettings();
    if (!canOpen) {
      showToast('Unable to open app setting');
    }
  }

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

  /// Requests access to photos/images before opening a picker.
  ///
  /// Android 13+ (API 33+): no permission needed — image_picker uses the
  /// Android Photo Picker (system UI) which does not require any manifest
  /// permission. Returns [PermissionStatus.granted] immediately.
  /// Android 12 and below (API 32-): requests `READ_EXTERNAL_STORAGE`.
  /// iOS: requests `PHPhotoLibrary` — plist: `NSPhotoLibraryUsageDescription`.
  Future<PermissionStatus> requestPhotos() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (sdk >= 33) return PermissionStatus.granted;
      return requestPermission(Permission.storage);
    }
    return requestPermission(Permission.photos);
  }

  /// Requests access to video files before opening a picker.
  ///
  /// Android 13+ (API 33+): no permission needed — image_picker uses the
  /// Android Photo Picker; file_picker uses SAF. Returns [PermissionStatus.granted].
  /// Android 12 and below (API 32-): requests `READ_EXTERNAL_STORAGE`.
  /// iOS: no permission needed — returns [PermissionStatus.granted] directly.
  Future<PermissionStatus> requestVideos() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (sdk >= 33) return PermissionStatus.granted;
      return requestPermission(Permission.storage);
    }
    return PermissionStatus.granted;
  }

  /// Requests access to audio files before opening a picker.
  ///
  /// Android 13+ (API 33+): no permission needed — file_picker uses SAF.
  /// Returns [PermissionStatus.granted] immediately.
  /// Android 12 and below (API 32-): requests `READ_EXTERNAL_STORAGE`.
  /// iOS: no permission needed — returns [PermissionStatus.granted] directly.
  Future<PermissionStatus> requestAudio() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (sdk >= 33) return PermissionStatus.granted;
      return requestPermission(Permission.storage);
    }
    return PermissionStatus.granted;
  }

  /// Requests write access to the public Downloads directory, for code that
  /// writes there via a raw [Directory]/[File] path (e.g. [getAppDirectory]
  /// on Android) rather than through `MediaStore`.
  ///
  /// **Scoped storage caveat — read before relying on this:**
  ///
  /// - Android below 10 (API < 29): legacy storage model. Requests
  ///   `WRITE_EXTERNAL_STORAGE` via [Permission.storage]; once granted, raw
  ///   path writes to Downloads work normally.
  /// - Android 10 (API 29): scoped storage is opt-in. This only works if the
  ///   app manifest sets `android:requestLegacyExternalStorage="true"` —
  ///   without it, a granted [Permission.storage] does **not** guarantee a
  ///   raw path write to Downloads will succeed.
  /// - Android 11+ (API 30+): scoped storage is **enforced** regardless of
  ///   that manifest flag. `WRITE_EXTERNAL_STORAGE` no longer grants access
  ///   to public directories outside `MediaStore`. Reliable raw-path writes
  ///   would require `MANAGE_EXTERNAL_STORAGE`, a sensitive "all files
  ///   access" permission that Google Play restricts to apps whose core
  ///   function is file management — this method deliberately does **not**
  ///   request it, since granting it is a product/policy decision, not
  ///   something to default to silently.
  /// - iOS: not applicable — returns [PermissionStatus.granted].
  ///
  /// **Practical effect:** on API 30+ this will commonly report
  /// [PermissionStatus.denied]/[PermissionStatus.permanentlyDenied] even
  /// though [Permission.storage] itself is "granted" by the OS, because the
  /// underlying capability isn't actually there. Callers should treat a
  /// non-granted result as "raw Downloads writes aren't available on this
  /// device" and fall back to an app-private directory (no permission
  /// needed) or switch to a `MediaStore`-based plugin (e.g. `gal` /
  /// `saver_gallery`) instead of adopting `MANAGE_EXTERNAL_STORAGE`.
  Future<PermissionStatus> requestDownloadsWrite() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (sdk < 29) {
        return requestPermission(Permission.storage);
      }
      // Scoped storage (API 29+): don't prompt for a permission that can't
      // actually deliver raw Downloads access — surface the current status
      // so callers can decide to fall back instead.
      return Permission.storage.status;
    }
    return PermissionStatus.granted;
  }
}
