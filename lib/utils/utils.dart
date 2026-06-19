/// Logging utilities and Dart / Flutter extension methods.
///
/// **Logging** (`app_logger.dart`)
/// - [trace], [debug], [info], [warn], [err], [fatal] — structured log helpers
/// - [simpleLog] — lightweight debug print (no-op in release)
/// - [devLog] — writes to `dart:developer` (visible in DevTools)
/// - [AppFilter] — [LogFilter] that passes only warning + error events
///
/// **Extensions**
/// - [ContextExtension] — [BuildContext.m3MarkdownStyle] for themed Markdown
/// - [StringExtension] — flavor detection and Firebase options from bundle ID
// ignore: unnecessary_library_name
library utils;

export 'app_logger.dart';
export 'extensions/context_extension.dart';
export 'extensions/string_extension.dart';
