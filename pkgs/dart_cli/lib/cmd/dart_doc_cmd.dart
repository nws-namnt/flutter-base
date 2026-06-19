import 'dart:io';

import 'package:args/command_runner.dart' show Command;

import '../cli_models.dart' show MenuOption;
import '../cli_utils.dart';

/// Generates dart doc for the project at the current working directory.
///
/// Resolves the Dart executable via [dartExec] so that FVM is used
/// automatically when available (`fvm dart doc .`), falling back to
/// plain `dart doc .` otherwise.
class GenDocCommand extends Command {
  @override
  String get name => MenuOption.genDoc.cliTitle;

  @override
  String get description => MenuOption.genDoc.description;

  @override
  Future<void> run() async {
    // Resolve 'fvm dart' or plain 'dart' depending on FVM availability.
    final exec = await dartExec;
    final args = [...exec.skip(1), 'doc', '.'];

    t('Execute: ${[...exec.take(1), ...args].join(' ')}');

    try {
      await runCmd(exec.first, args, spinnerMsg: 'Generating dart doc...');
      s('✅ Dart doc generated → doc/api/');
    } catch (_) {
      e('❌ Dart doc generation failed.');
    }
  }
}

/// Serves the generated dart doc via a local HTTP server on port 8080.
///
/// Starts `python3 -m http.server 8080` inside `doc/api/` and inherits
/// stdio so the server output is visible in the terminal. Press Ctrl+C
/// to stop the server and return to the menu.
class ViewDocCommand extends Command {
  @override
  String get name => MenuOption.viewDoc.cliTitle;

  @override
  String get description => MenuOption.viewDoc.description;

  @override
  Future<void> run() async {
    final docDir = Directory('doc/api');

    // Guard: doc/api must exist before attempting to serve.
    if (!docDir.existsSync()) {
      e('doc/api not found. Run "Gen doc" first to generate the documentation.');
      return;
    }

    i('Starting local doc server at http://localhost:8080 ...');
    i('Press Ctrl+C to stop.');

    // Inherit stdio so the user sees server logs and can Ctrl+C cleanly.
    final process = await Process.start(
      'python3',
      ['-m', 'http.server', '8080'],
      workingDirectory: docDir.path,
      runInShell: true,
      mode: ProcessStartMode.inheritStdio,
    );

    final exitCode = await process.exitCode;

    // Exit code 130 = SIGINT (Ctrl+C) — treat as a normal user stop.
    if (exitCode != 0 && exitCode != 130) {
      e('Server exited with code $exitCode.');
    } else {
      t('\n🛑 Doc server stopped.');
    }
  }
}
