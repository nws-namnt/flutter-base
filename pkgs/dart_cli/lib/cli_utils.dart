import 'dart:io';

import 'package:ansicolor/ansicolor.dart' show AnsiPen;
import 'package:cli_spinner/cli_spinner.dart';
import 'package:interact_cli/interact_cli.dart' show Theme;

/// Shared theme for all interactive prompts.
final cliTheme = Theme.colorfulTheme.copyWith(
  activeItemPrefix: '▶ ',
  inactiveItemPrefix: '  ',
);

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

/// Helper method for resolving the Flutter / Dart executable prefix.
/// Detects whether FVM is available and returns the appropriate
/// flutter / dart executable prefix.
///
/// - FVM present  → ['fvm', 'flutter'] or ['fvm', 'dart']
/// - FVM absent   → ['flutter'] or ['dart']
Future<List<String>> _resolveExec(String tool) async {
  final check = await Process.run('which', ['fvm'], runInShell: true);
  final hasFvm = check.exitCode == 0 && check.stdout.toString().trim().isNotEmpty;
  return hasFvm ? ['fvm', tool] : [tool];
}

/// Convenience wrappers so commands don't need to think about FVM.
Future<List<String>> get flutterExec => _resolveExec('flutter');
Future<List<String>> get dartExec => _resolveExec('dart');

Future<void> runCmd(String cmd, List<String> args, {String? spinnerMsg}) async {
  final spinner = (spinnerMsg ?? 'Running executable...').renderSpinner;
  spinner.start();

  try {
    final result = await Process.run(
      cmd,
      args,
      runInShell: true,
    );

    spinner.updateMessage('Done.');
    spinner.stop();

    if(result.stdout != null && result.stdout.toString().isNotEmpty) {
      t(result.stdout);
    }

    if(result.stderr != null && result.stderr.toString().isNotEmpty) {
      e(result.stderr);
    }
  } catch(err) {
    spinner.updateMessage('Error: $err');
    spinner.stop();
    e('Failed to run $cmd: $err');
  }
}

/// Runs a Flutter command, automatically resolving FVM if available.
/// e.g. runFlutter(['clean']) → 'fvm flutter clean' or 'flutter clean'
Future<void> runFlutter(List<String> args, {String? spinnerMsg}) async {
  final exec = await flutterExec;
  final cmd = exec.first;
  final fullArgs = [...exec.skip(1), ...args];
  await runCmd(cmd, fullArgs, spinnerMsg: spinnerMsg);
}

/// Runs a Dart command, automatically resolving FVM if available.
Future<void> runDart(List<String> args, {String? spinnerMsg}) async {
  final exec = await dartExec;
  final cmd = exec.first;
  final fullArgs = [...exec.skip(1), ...args];
  await runCmd(cmd, fullArgs, spinnerMsg: spinnerMsg);
}

/// Runs a Flutter command interactively — streams stdout/stderr in real time.
/// Use for commands that need user interaction (hot reload, logs), e.g. `flutter run`.
Future<void> runFlutterInteractive(List<String> args) async {
  final exec = await flutterExec;
  final cmd = exec.first;
  final fullArgs = [...exec.skip(1), ...args];

  final process = await Process.start(
    cmd,
    fullArgs,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio, // stdin/stdout/stderr shared with parent
  );

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    e('Process exited with code $exitCode');
  }
}

/// Prints the real command that will be executed (including FVM prefix if present).
/// e.g. "Execute: fvm flutter doctor -v" or "Execute: flutter doctor -v"
Future<void> printExec(List<String> args) async {
  final exec = await flutterExec;
  t('Execute: ${[...exec, ...args].join(' ')}');
}

/// Logging
final AnsiPen successPen = AnsiPen()..green(bold: true);
final AnsiPen errorPen = AnsiPen()..red(bold: true);
final AnsiPen infoPen = AnsiPen()..blue(bold: true);
final AnsiPen warnPen = AnsiPen()..yellow(bold: true);
final AnsiPen normalPen = AnsiPen()..white(bold: true);

void s(String msg) => print(successPen(msg));
void e(String msg) => print(errorPen(msg));
void i(String msg) => print(infoPen(msg));
void w(String msg) => print(warnPen(msg));
void t(String msg) => print(normalPen(msg));
