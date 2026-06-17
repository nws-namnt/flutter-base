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

/// Logger level
void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.t('🖇️ VERBOSE: $message', error: error, stackTrace: stackTrace);
void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.d('🐛 DEBUG: $message', error: error, stackTrace: stackTrace);
void info(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.i('ℹ️ INFO: $message', error: error, stackTrace: stackTrace);
void warn(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.w('⚠️ WARNING: $message', error: error, stackTrace: stackTrace);
void err(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.e('⛔ ERROR: $message', error: error, stackTrace: stackTrace);
void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.f('💀 ERROR: $message', error: error, stackTrace: stackTrace);

void customLog(Level level, dynamic message, [dynamic error, StackTrace? stackTrace]) => _logger.log(level, message, error: error, stackTrace: stackTrace);

void devLog(String mess) => developer.log('🦊 - $mess');

void simpleLog(dynamic message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

class AppFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if(event.level == Level.error || event.level == Level.warning) {
      return true;
    }

    return false; // Allow log on production mode
  }
}

