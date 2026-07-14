import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

// Logger instance
final _logger = Logger(
  // filter: AppFilter(),
  filter: null, // Use the default LogFilter (-> only log in debug mode), uncomment the line to allow log in production mode
  printer: PrettyPrinter(
    methodCount: 2, // number of method calls to be displayed
    errorMethodCount: 5, // number of method calls if stacktrace is provided
    lineLength: 120, // width of the output (detect auto with io package io.stdout.terminalColumns)
    colors: true, // Colorful log messages (detect auto with io package io.stdout.supportsAnsiEscapes)
    printEmojis: true, // Print an emoji for each log message
    // printTime: false, // Should each log print contain a timestamp
    dateTimeFormat: DateTimeFormat.none, // Replace for printTime attribute that has been deprecated
    excludeBox: {
      // Level.all: true,
      // Level.trace: true,
      // Level.debug: true,
      // Level.info: true,
      // Level.warning: true,
      // Level.error: true,
      // Level.fatal: true,
      // Level.off: true,
    },
    noBoxingByDefault: true,
    levelColors: {},
    levelEmojis: {},
  ), // Use the PrettyPrinter to format and print log
  output: null, // Use the default LogOutput (-> send everything to console)
);

// ── Structured log helpers ────────────────────────────────────────────────────
// All functions accept an optional [error] and [stackTrace] for rich output.

/// Logs a [Level.trace] message (most verbose — granular flow tracing).
void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.t('🖇️ VERBOSE: $message', error: error, stackTrace: stackTrace);

/// Logs a [Level.debug] message (developer diagnostics).
void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.d('🐛 DEBUG: $message', error: error, stackTrace: stackTrace);

/// Logs a [Level.info] message (expected significant events).
void info(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.i('ℹ️ INFO: $message', error: error, stackTrace: stackTrace);

/// Logs a [Level.warning] message (unexpected but recoverable situation).
void warn(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.w('⚠️ WARNING: $message', error: error, stackTrace: stackTrace);

/// Logs a [Level.error] message (operation failed, app can continue).
void err(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.e('⛔ ERROR: $message', error: error, stackTrace: stackTrace);

/// Logs a [Level.fatal] message (unrecoverable error, app should terminate).
void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.f('💀 ERROR: $message', error: error, stackTrace: stackTrace);

/// Logs at an arbitrary [Level]. Use when the level must be chosen dynamically.
void customLog(Level level, dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.log(level, message, error: error, stackTrace: stackTrace);

/// Writes directly to `dart:developer` log (visible in the DevTools log view).
///
/// Useful when the [Logger] printer would add too much noise, e.g. inside
/// tight loops or platform channel callbacks.
void devLog(String mess) => developer.log('🦊 - $mess');

/// Prints [message] to the console in debug builds only (no-op in release).
void simpleLog(dynamic message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

/// Adds a one-line [log] shortcut to any value, printed via `dart:developer`.
extension LogExtension on Object? {
  /// Logs `toString()` of this value (or a highlighted `NULL` marker when
  /// this is `null`), prefixed with a fox emoji.
  ///
  /// ```dart
  /// 'fetched user'.log();
  /// ```
  void log() => developer.log('🦊 - ${this?.toString() ?? '\x1b[101m\x1b[30mNULL\x1b[0m'}');
}

/// A [LogFilter] that passes only [Level.warning] and [Level.error] events.
///
/// Swap in place of `null` in the [Logger] constructor to suppress verbose
/// output in release / production builds while still capturing actionable issues:
///
/// ```dart
/// filter: AppFilter(),
/// ```
class AppFilter extends LogFilter {
  /// Returns `true` only for [Level.warning] and [Level.error] events,
  /// suppressing everything else (trace/debug/info/fatal).
  @override
  bool shouldLog(LogEvent event) {
    if(event.level == Level.error || event.level == Level.warning) {
      return true;
    }

    return false;
  }
}

