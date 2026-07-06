import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/app_enums.dart';
import '../models/picked_file.dart';
import '../services/permission_service.dart';
import 'app_logger.dart' show err;

/// Launches an external app or URL using [url_launcher].
///
/// The [externalType] determines how [data] is interpreted and which URI
/// scheme is used:
///
/// | [externalType]              | Expected [data]                                            |
/// |-----------------------------|------------------------------------------------------------|
/// | [LaunchExternalType.webview]| Full URL string — `'https://example.com/path?q=1'`        |
/// | [LaunchExternalType.mail]   | Recipient email address — `'user@example.com'`             |
/// | [LaunchExternalType.tel]    | Phone number with country code — `'+84123456789'`          |
/// | [LaunchExternalType.sms]    | Phone number with country code — `'+84123456789'`          |
/// | [LaunchExternalType.file]   | Absolute file-system path — `'/storage/emulated/0/a.pdf'` |
///
/// [mailSubject] is only used when [externalType] is [LaunchExternalType.mail];
/// it is omitted from the `mailto:` URI when `null`.
///
/// [mode] mirrors [LaunchMode] from `url_launcher`. Passing
/// [LaunchMode.inAppWebView] or [LaunchMode.inAppBrowserView] for a non-http(s)
/// scheme automatically falls back to [LaunchMode.externalApplication] to
/// prevent an [ArgumentError] inside `launchUrl`.
///
/// For [LaunchExternalType.file], the file is verified to exist on disk before
/// launching; a missing file is treated as a non-launchable URI.
///
/// Errors are logged via [err] and swallowed — this function never throws.
Future<void> onLaunchExternalApp({
  LaunchExternalType externalType = LaunchExternalType.webview,
  required String data,
  String? mailSubject,
  LaunchMode mode = LaunchMode.platformDefault,
}) async {
  try {
    final Uri uri = switch (externalType) {
      LaunchExternalType.mail => Uri(
        scheme: externalType.type,
        path: data,
        queryParameters: mailSubject != null ? {'subject': mailSubject} : null,
      ),
      LaunchExternalType.sms ||
      LaunchExternalType.tel => Uri(scheme: externalType.type, path: data),
      LaunchExternalType.webview => Uri.parse(data),
      LaunchExternalType.file => Uri.file(data),
    };

    if (externalType == LaunchExternalType.file &&
        !File(uri.toFilePath()).existsSync()) {
      err('File does not exist: $uri');
      return;
    }

    // inAppWebView/inAppBrowserView only support http(s) — fall back for other schemes
    final effectiveMode =
        (mode == LaunchMode.inAppWebView ||
                mode == LaunchMode.inAppBrowserView) &&
            !(uri.scheme == 'https' || uri.scheme == 'http')
        ? LaunchMode.externalApplication
        : mode;

    // canLaunchUrl is unreliable on Android for well-known schemes (https, http, mailto, tel, sms)
    // — it frequently returns false even when the device can handle the URL, due to Android 11+
    // package visibility restrictions. Skip the check for known schemes and let launchUrl throw
    // if the OS truly cannot handle the URI. Only gate on canLaunchUrl for custom/unknown schemes.
    const knownSchemes = {'https', 'http', 'mailto', 'tel', 'sms'};
    if (!knownSchemes.contains(uri.scheme) && !await canLaunchUrl(uri)) {
      err('Cannot launch URI: $uri');
      return;
    }

    await launchUrl(uri, mode: effectiveMode);
  } catch (e) {
    err(e.toString());
  }
}

// IMAGE PICKERS

/// Captures a photo with the device camera.
///
/// Requests [Permission.camera] before launching. Returns `null` when the
/// permission is denied or the user cancels the camera UI.
Future<PickedFile?> pickImageFromCamera() async {
  try {
    final status = await permissionService.requestCamera();
    if (!status.isGranted) return null;
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file == null) return null;
    return PickedFile.fromXFile(file, size: await file.length());
  } catch (e) {
    err('pickImageFromCamera: $e');
    return null;
  }
}

/// Opens the system image gallery and lets the user pick a single image.
///
/// Requests photo library permission before launching (platform-aware — see
/// [PermissionService.requestPhotos]). Returns `null` on permission denied or
/// user cancellation.
Future<PickedFile?> pickImageFromGallery() async {
  try {
    final status = await permissionService.requestPhotos();
    if (!status.isGranted) return null;
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    return PickedFile.fromXFile(file, size: await file.length());
  } catch (e) {
    err('pickImageFromGallery: $e');
    return null;
  }
}

/// Opens the system image gallery and lets the user pick multiple images.
///
/// Returns an empty list on permission denied or user cancellation.
Future<List<PickedFile>> pickMultipleImagesFromGallery() async {
  try {
    final status = await permissionService.requestPhotos();
    if (!status.isGranted) return [];
    final files = await ImagePicker().pickMultiImage();
    return Future.wait(
      files.map((f) async => PickedFile.fromXFile(f, size: await f.length())),
    );
  } catch (e) {
    err('pickMultipleImagesFromGallery: $e');
    return [];
  }
}

// VIDEO PICKERS

/// Records a video with the device camera.
///
/// Requests [Permission.camera] before launching. Returns `null` when the
/// permission is denied or the user cancels.
Future<PickedFile?> pickVideoFromCamera() async {
  try {
    final status = await permissionService.requestCamera();
    if (!status.isGranted) return null;
    final file = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (file == null) return null;
    return PickedFile.fromXFile(file, size: await file.length());
  } catch (e) {
    err('pickVideoFromCamera: $e');
    return null;
  }
}

/// Opens the system video gallery and lets the user pick a single video.
///
/// Requests video access permission before launching (platform-aware — see
/// [PermissionService.requestVideos]). Returns `null` on denial or cancellation.
Future<PickedFile?> pickVideoFromGallery() async {
  try {
    final status = await permissionService.requestVideos();
    if (!status.isGranted) return null;
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file == null) return null;
    return PickedFile.fromXFile(file, size: await file.length());
  } catch (e) {
    err('pickVideoFromGallery: $e');
    return null;
  }
}

// AUDIO PICKER

/// Opens the system file picker filtered to audio files.
///
/// Uses `file_picker` with [FileType.audio], which routes to
/// `UIDocumentPickerViewController` on iOS and SAF on Android — no manifest
/// permission is required on API 33+; [PermissionService.requestAudio] handles
/// the legacy READ_EXTERNAL_STORAGE case on API 32 and below.
///
/// Returns `null` on permission denied or user cancellation.
Future<PickedFile?> pickAudio() async {
  try {
    final status = await permissionService.requestAudio();
    if (!status.isGranted) return null;
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null) return null;
    return PickedFile.fromPlatformFile(result.files.single);
  } catch (e) {
    err('pickAudio: $e');
    return null;
  }
}

// FILE PICKERS

/// Opens the system file picker and lets the user pick a single file.
///
/// When [allowedExtensions] is provided (e.g. `['pdf', 'docx']`), the picker
/// is filtered to those types ([FileType.custom]). Otherwise all file types are
/// shown ([FileType.any]).
///
/// No runtime permission is requested — `file_picker` uses SAF on Android and
/// `UIDocumentPickerViewController` on iOS, both of which are sandboxed by the OS.
///
/// Returns `null` when the user cancels.
Future<PickedFile?> pickSingleFile({List<String>? allowedExtensions}) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );
    if (result == null) return null;
    return PickedFile.fromPlatformFile(result.files.single);
  } catch (e) {
    err('pickSingleFile: $e');
    return null;
  }
}

/// Opens the system file picker and lets the user pick multiple files.
///
/// Behaves like [pickSingleFile] but with `allowMultiple: true`.
/// Returns an empty list when the user cancels.
Future<List<PickedFile>> pickMultipleFiles({
  List<String>? allowedExtensions,
}) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );
    if (result == null) return [];
    return result.files.map(PickedFile.fromPlatformFile).toList();
  } catch (e) {
    err('pickMultipleFiles: $e');
    return [];
  }
}

/// Shows a native toast using [Fluttertoast] — no [BuildContext] required.
///
/// Wraps [Fluttertoast.showToast] with sensible defaults and optional
/// [AppNotifyType]-based styling. Because this uses the platform's native
/// toast API (Android) or Toastify-JS (web), it works outside the widget tree
/// and is ideal for quick one-liner feedback from services or utilities.
///
/// **Android 11+ note:** Only [msg] and [toastLength] are respected on
/// Android 11 and above — all visual properties ([backgroundColor],
/// [textColor], [fontSize]) are silently ignored by the OS. Use
/// [BuildContext.showNotify] (flushbar-based) when full UI control is needed.
///
/// Parameters mirror [Fluttertoast.showToast]:
///
/// - [msg] — the message string to display (required).
/// - [type] — when provided, [backgroundColor] and [textColor] default to
///   [AppNotifyType.bgColor] and [Colors.white] respectively; pass explicit
///   values to override.
/// - [toastLength] — [Toast.LENGTH_SHORT] (default) or [Toast.LENGTH_LONG].
/// - [gravity] — vertical position; [ToastGravity.BOTTOM] by default.
/// - [timeInSecForIosWeb] — visible duration in seconds on iOS and web.
/// - [backgroundColor] — overrides the [type]-derived background color.
/// - [textColor] — text color; defaults to [Colors.white].
/// - [fontSize] — text size in logical pixels.
///
/// Returns a [Future] that resolves to `true` when the toast is shown,
/// `false` on failure, or `null` when the platform returns no result.
///
/// Example:
/// ```dart
/// showToast('Profile saved!', type: AppNotifyType.success);
/// showToast('Network error', type: AppNotifyType.error, toastLength: Toast.LENGTH_LONG);
/// ```
Future<bool?> showToast(
  String msg, {
  AppNotifyType type = AppNotifyType.info,
  Toast toastLength = Toast.LENGTH_SHORT,
  ToastGravity gravity = ToastGravity.BOTTOM,
  int timeInSecForIosWeb = 1,
  Color? backgroundColor,
  Color textColor = Colors.white,
  double fontSize = 16.0,
}) => Fluttertoast.showToast(
  msg: msg,
  toastLength: toastLength,
  gravity: gravity,
  timeInSecForIosWeb: timeInSecForIosWeb,
  backgroundColor: backgroundColor ?? type.bgColor,
  textColor: textColor,
  fontSize: fontSize,
);

/// Cancels all pending toasts immediately.
///
/// Useful when navigating away from a screen to prevent stale messages
/// from appearing on the next screen.
Future<bool?> cancelToast() => Fluttertoast.cancel();
