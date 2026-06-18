import 'dart:io';

import 'package:ansicolor/ansicolor.dart' show AnsiPen;
import 'package:cli_spinner/cli_spinner.dart';
import 'package:interact_cli/interact_cli.dart' hide Spinner;

/// Shared theme for all interactive prompts.
final cliTheme = Theme.colorfulTheme.copyWith(
  activeItemPrefix: '▶ ',
  inactiveItemPrefix: '  ',
);

/// Top-level prompt helper — shared across all commands.
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

/// Extensions for helper functions.
extension SpinnerBuilder on String? {
  Spinner get renderSpinner => Spinner.type(this ?? 'Processing...', SpinnerType.dots);
}

extension StringExtension on String {
  String get firstLetterUppercase {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

/// Resolves Flutter / Dart executable prefix (FVM-aware).
/// Results are cached — `which fvm` runs at most once per session.
Future<List<String>> _resolveExec(String tool) async {
  final check = await Process.run('which', ['fvm'], runInShell: true);
  final hasFvm = check.exitCode == 0 && check.stdout.toString().trim().isNotEmpty;
  return hasFvm ? ['fvm', tool] : [tool];
}

// #2 FVM cache — resolved once per session via ??=
Future<List<String>>? _flutterExecCache;
Future<List<String>>? _dartExecCache;

Future<List<String>> get flutterExec => _flutterExecCache ??= _resolveExec('flutter');
Future<List<String>> get dartExec    => _dartExecCache    ??= _resolveExec('dart');

/// Prints the real command that will be executed (including FVM prefix if present).
/// e.g. "Execute: fvm flutter doctor -v" or "Execute: flutter doctor -v"
Future<void> printExec(List<String> args) async {
  final exec = await flutterExec;
  t('Execute: ${[...exec, ...args].join(' ')}');
}

/// Runs a shell command with a spinner.
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

/// Runs a Flutter command, automatically resolving FVM if available.
Future<void> runFlutter(List<String> args, {String? spinnerMsg}) async {
  final exec = await flutterExec;
  await runCmd(exec.first, [...exec.skip(1), ...args], spinnerMsg: spinnerMsg);
}

/// Runs a Dart command, automatically resolving FVM if available.
Future<void> runDart(List<String> args, {String? spinnerMsg}) async {
  final exec = await dartExec;
  await runCmd(exec.first, [...exec.skip(1), ...args], spinnerMsg: spinnerMsg);
}

/// Runs a Flutter command interactively (stdin/stdout/stderr shared with parent).
/// Use for commands needing user interaction: flutter run, doctor, watch.
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

/// Logging
final AnsiPen successPen = AnsiPen()..green(bold: true);
final AnsiPen errorPen   = AnsiPen()..red(bold: true);
final AnsiPen infoPen    = AnsiPen()..blue(bold: true);
final AnsiPen warnPen    = AnsiPen()..yellow(bold: true);
final AnsiPen normalPen  = AnsiPen()..white(bold: true);

void s(String msg) => print(successPen(msg));
void e(String msg) => print(errorPen(msg));
void i(String msg) => print(infoPen(msg));
void w(String msg) => print(warnPen(msg));
void t(String msg) => print(normalPen(msg));
