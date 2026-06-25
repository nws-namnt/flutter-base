import 'dart:io' show File;

import 'package:url_launcher/url_launcher.dart';

import '../common/app_enums.dart';
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
      LaunchExternalType.sms || LaunchExternalType.tel => Uri(
          scheme: externalType.type,
          path: data,
        ),
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
        (mode == LaunchMode.inAppWebView || mode == LaunchMode.inAppBrowserView) &&
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
