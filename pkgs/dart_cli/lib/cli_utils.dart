library cli_utils;

import 'dart:io';

import 'package:ansicolor/ansicolor.dart' show AnsiPen;
import 'package:cli_spinner/cli_spinner.dart';
import 'package:interact_cli/interact_cli.dart' hide Spinner;

/// Shared theme applied to all interactive prompts in this CLI.
final cliTheme = Theme.colorfulTheme.copyWith(
  activeItemPrefix: '▶ ',
  inactiveItemPrefix: '  ',
);

/// Displays a single-choice prompt and returns the selected option string.
///
/// The [prompt] is shown above the list. Pass [defaultValue] to pre-select
/// a specific entry; if omitted the first option is selected.
String promptSelect(String prompt, List<String> options, {String? defaultValue}) {
  final initialIndex = defaultValue != null
      ? options.indexOf(defaultValue).clamp(0, options.length - 1)
      : 0;
  final index = Select.withTheme(
    theme: cliTheme,
    prompt: prompt,
    options: options,
    initialIndex: initialIndex,
  ).interact();
  return options[index];
}

/// Extensions for building spinners from nullable strings.
extension SpinnerBuilder on String? {
  /// A [Spinner] using this string as its message, or `'Processing...'` if null.
  Spinner get renderSpinner => Spinner.type(this ?? 'Processing...', SpinnerType.dots);
}

/// Extensions on [String].
extension StringExtension on String {
  /// This string with its first character uppercased and the rest lowercased.
  String get firstLetterUppercase {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

/// Resolves the executable prefix for [tool], prepending `fvm` when available.
///
/// Returns `['fvm', tool]` if the `fvm` binary is found on PATH, otherwise
/// returns `[tool]`. Results are cached so `which fvm` runs at most once.
Future<List<String>> _resolveExec(String tool) async {
  final check = await Process.run('which', ['fvm'], runInShell: true);
  final hasFvm = check.exitCode == 0 && check.stdout.toString().trim().isNotEmpty;
  return hasFvm ? ['fvm', tool] : [tool];
}

// Cached resolution futures — evaluated once per process lifetime.
Future<List<String>>? _flutterExecCache;
Future<List<String>>? _dartExecCache;

/// The resolved Flutter executable prefix, FVM-aware.
Future<List<String>> get flutterExec => _flutterExecCache ??= _resolveExec('flutter');

/// The resolved Dart executable prefix, FVM-aware.
Future<List<String>> get dartExec => _dartExecCache ??= _resolveExec('dart');

/// Prints the full Flutter command that will be executed, including any FVM prefix.
///
/// Example output: `Execute: fvm flutter pub get`
Future<void> printExec(List<String> args) async {
  final exec = await flutterExec;
  t('Execute: ${[...exec, ...args].join(' ')}');
}

/// Prints the full Dart command that will be executed, including any FVM prefix.
///
/// Example output: `Execute: fvm dart run pigeon --input pigeon/api.dart`
Future<void> printExecDart(List<String> args) async {
  final exec = await dartExec;
  t('Execute: ${[...exec, ...args].join(' ')}');
}

/// Runs [cmd] with [args], showing a spinner while the process is running.
///
/// Throws [ProcessException] if the process exits with a non-zero code.
Future<void> runCmd(String cmd, List<String> args, {String? spinnerMsg}) async {
  final spinner = (spinnerMsg ?? 'Running...').renderSpinner;
  spinner.start();

  try {
    final result = await Process.run(cmd, args, runInShell: true);

    spinner.stop();

    if (result.exitCode != 0) {
      final errMsg = result.stderr.toString().trim();
      if (errMsg.isNotEmpty) e(errMsg);
      throw ProcessException(cmd, args, 'Exited with code ${result.exitCode}', result.exitCode);
    }

    if (result.stdout.toString().isNotEmpty) t(result.stdout.toString());
  } catch (err) {
    spinner.stop();
    rethrow;
  }
}

/// Runs a Flutter command, resolving FVM automatically if available.
///
/// Throws [ProcessException] on non-zero exit.
Future<void> runFlutter(List<String> args, {String? spinnerMsg}) async {
  final exec = await flutterExec;
  await runCmd(exec.first, [...exec.skip(1), ...args], spinnerMsg: spinnerMsg);
}

/// Runs a Dart command, resolving FVM automatically if available.
///
/// Throws [ProcessException] on non-zero exit.
Future<void> runDart(List<String> args, {String? spinnerMsg}) async {
  final exec = await dartExec;
  await runCmd(exec.first, [...exec.skip(1), ...args], spinnerMsg: spinnerMsg);
}

/// Runs a Flutter command in interactive mode, sharing stdio with the parent.
///
/// Use this for commands that require user input, such as `flutter run` or
/// `flutter doctor`. Throws on non-zero exit code.
Future<void> runFlutterInteractive(List<String> args) async {
  final exec = await flutterExec;
  final process = await Process.start(
    exec.first,
    [...exec.skip(1), ...args],
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    e('Process exited with code $exitCode');
  }
}

// ─── Logging helpers ───────────────────────────────────────────────────────

final AnsiPen successPen = AnsiPen()..green(bold: true);
final AnsiPen errorPen   = AnsiPen()..red(bold: true);
final AnsiPen infoPen    = AnsiPen()..blue(bold: true);
final AnsiPen warnPen    = AnsiPen()..yellow(bold: true);
final AnsiPen normalPen  = AnsiPen()..white(bold: true);

/// Prints a success message in green.
void s(String msg) => print(successPen(msg));

/// Prints an error message in red.
void e(String msg) => print(errorPen(msg));

/// Prints an info message in blue.
void i(String msg) => print(infoPen(msg));

/// Prints a warning message in yellow.
void w(String msg) => print(warnPen(msg));

/// Prints a normal (white bold) message.
void t(String msg) => print(normalPen(msg));
