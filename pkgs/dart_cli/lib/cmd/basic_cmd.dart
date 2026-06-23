library cmd_basic;

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart' show Command;
import 'package:interact_cli/interact_cli.dart';

import '../cli_config.dart';
import '../cli_models.dart' show MenuOption;
import '../cli_utils.dart';

/// Runs the Flutter project on a connected device or emulator.
///
/// Prompts for flavor, run mode, and device when called interactively.
/// Accepts `--flavor`, `--mode`, and `--device` flags when called directly.
class RunCommand extends Command {
  @override
  String get description => MenuOption.run.description;

  @override
  String get name => MenuOption.run.cliTitle;

  /// Creates a [RunCommand] and registers its flags.
  RunCommand() {
    argParser.addOption('flavor', abbr: 'f', allowed: ['dev', 'uat', 'prod'], defaultsTo: 'dev');
    argParser.addOption('mode',   abbr: 'm', allowed: ['debug', 'profile', 'release'], defaultsTo: 'debug');
    argParser.addOption('device', abbr: 'd');
  }

  @override
  Future<void> run() async {
    final hasArgs = argResults!.arguments.isNotEmpty;
    final cliConfig = await CliConfig.load();

    final flavor = hasArgs
        ? argResults!['flavor'] as String
        : promptSelect('Select flavor:', ['dev', 'uat', 'prod'], defaultValue: cliConfig.defaultFlavor);

    final mode = hasArgs
        ? argResults!['mode'] as String
        : promptSelect('Select run mode:', ['debug', 'profile', 'release'], defaultValue: cliConfig.defaultMode);

    final deviceId = hasArgs && argResults!['device'] != null
        ? argResults!['device'] as String
        : await _promptDevice();

    if (deviceId == null) {
      e('No device selected.');
      return;
    }

    final args = ['run', '--flavor', flavor, '--$mode', '-d', deviceId];
    await printExec(args);
    await runFlutterInteractive(args);
  }

  /// Fetches connected devices and prompts the user to select one.
  ///
  /// Returns the selected device ID, or null if no devices are available.
  Future<String?> _promptDevice() async {
    i('Fetching connected devices...');

    final exec = await flutterExec;
    final result = await Process.run(
      exec.first,
      [...exec.skip(1), 'devices', '--machine'],
      runInShell: true,
    );

    if (result.exitCode != 0 || result.stdout.toString().trim().isEmpty) {
      e('Failed to fetch devices.');
      return null;
    }

    final List<dynamic> raw = jsonDecode(result.stdout.toString());
    final devices = raw
        .map((d) => (id: d['id'] as String, name: '${d['name']} (${d['targetPlatform']})'))
        .toList();

    if (devices.isEmpty) {
      e('No connected devices found. Connect a device or start an emulator.');
      return null;
    }

    final index = Select.withTheme(
      theme: cliTheme,
      prompt: 'Select device:',
      options: devices.map((d) => d.name).toList(),
    ).interact();

    return devices[index].id;
  }
}

/// Builds the Flutter project as APK, App Bundle, or IPA.
///
/// Prompts for flavor, build type, and mode interactively.
/// Accepts `--flavor`, `--type`, and `--mode` flags when called directly.
class BuildCommand extends Command {
  @override
  String get description => MenuOption.build.description;

  @override
  String get name => MenuOption.build.cliTitle;

  /// Creates a [BuildCommand] and registers its flags.
  BuildCommand() {
    argParser.addOption('flavor', abbr: 'f', allowed: ['dev', 'uat', 'prod'], defaultsTo: 'dev');
    argParser.addOption('type',   abbr: 't', allowed: ['apk', 'appbundle', 'ipa'], defaultsTo: 'apk');
    argParser.addOption('mode',   abbr: 'm', allowed: ['debug', 'profile', 'release'], defaultsTo: 'release');
  }

  @override
  Future<void> run() async {
    final hasArgs = argResults!.arguments.isNotEmpty;
    final cliConfig = await CliConfig.load();

    final flavor = hasArgs
        ? argResults!['flavor'] as String
        : promptSelect('Select flavor:', ['dev', 'uat', 'prod'], defaultValue: cliConfig.defaultFlavor);

    final type = hasArgs
        ? argResults!['type'] as String
        : promptSelect('Select build type:', ['apk', 'appbundle', 'ipa'], defaultValue: cliConfig.defaultBuildType);

    final mode = hasArgs
        ? argResults!['mode'] as String
        : promptSelect('Select build mode:', ['debug', 'profile', 'release'], defaultValue: cliConfig.defaultMode);

    final args = ['build', type, '--flavor', flavor, '--$mode'];
    await printExec(args);

    try {
      await runFlutter(args, spinnerMsg: 'Building $type ($flavor / $mode)...');
    } catch (_) {
      e('❌ Build failed.');
      return;
    }

    final outputPath = _outputPath(type, flavor, mode);
    s('✅ Build completed — $type / $flavor / $mode');
    i('📂 Output: ${_hyperlink(outputPath, outputPath)}');

    final spinners = MultiSpinner();
    final s1 = spinners.add(Spinner(
      icon: '📋',
      rightPrompt: (state) => switch (state) {
        SpinnerStateType.inProgress => 'Copying output path...',
        SpinnerStateType.done       => 'Path copied to clipboard',
        SpinnerStateType.failed     => 'Copy failed',
      },
    ));
    final s2 = spinners.add(Spinner(
      icon: '📂',
      rightPrompt: (state) => switch (state) {
        SpinnerStateType.inProgress => 'Opening Finder...',
        SpinnerStateType.done       => 'Finder opened',
        SpinnerStateType.failed     => 'Could not open Finder',
      },
    ));

    await Future.wait([
      _copyToClipboard(outputPath).then((_) => s1.done()).catchError((_) => s1.failed()),
      Process.run('open', [outputPath], runInShell: true).then((_) => s2.done()).catchError((_) => s2.failed()),
    ]);
  }

  /// The output directory path for [type], [flavor], and [mode].
  String _outputPath(String type, String flavor, String mode) {
    final cwd = Directory.current.path;
    return switch (type) {
      'apk'       => '$cwd/build/app/outputs/flutter-apk',
      'appbundle' => '$cwd/build/app/outputs/bundle/$flavor${_capitalize(mode)}',
      'ipa'       => '$cwd/build/ios/ipa',
      _           => '$cwd/build',
    };
  }

  /// [s] with its first character uppercased.
  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  /// Copies [text] to the system clipboard using `pbcopy`.
  Future<void> _copyToClipboard(String text) async {
    final process = await Process.start('pbcopy', [], runInShell: true);
    process.stdin.write(text);
    await process.stdin.close();
    await process.exitCode;
  }

  /// Returns an OSC 8 terminal hyperlink for [url] with display [label].
  String _hyperlink(String url, String label) {
    final uri = url.startsWith('http') ? url : 'file://$url';
    return '\x1B]8;;$uri\x07$label\x1B]8;;\x07';
  }
}

/// Regenerates Pigeon type-safe platform channel code.
///
/// Runs `dart run pigeon --input pigeon/api.dart` from the project root,
/// which overwrites the three generated files:
///   - `lib/generated/pigeon_api.g.dart`
///   - `android/.../generated/PigeonApi.g.kt`
///   - `ios/Runner/generated/PigeonApi.g.swift`
///
/// Run this whenever `pigeon/api.dart` is modified.
class PigeonCommand extends Command {
  @override
  String get description => MenuOption.pigeon.description;

  @override
  String get name => MenuOption.pigeon.cliTitle;

  @override
  Future<void> run() async {
    final args = ['run', 'pigeon', '--input', 'pigeon/api.dart'];
    await printExecDart(args);
    try {
      await runDart(args, spinnerMsg: 'Generating Pigeon bridge code...');
      s('✅ Pigeon generation completed.');
    } catch (_) {
      e('❌ Pigeon generation failed.');
    }
  }
}

/// Runs `build_runner` for code generation in build or watch mode.
class GenCommand extends Command {
  @override
  String get description => MenuOption.gen.description;

  @override
  String get name => MenuOption.gen.cliTitle;

  @override
  Future<void> run() async {
    final hasArgs = argResults!.arguments.isNotEmpty;

    final mode = hasArgs
        ? argResults!.rest.firstOrNull ?? 'build'
        : promptSelect('Select gen mode:', ['build', 'watch']);

    final brArgs = ['pub', 'run', 'build_runner', mode, '--delete-conflicting-outputs'];
    await printExec(brArgs);

    if (mode == 'watch') {
      i('Starting build_runner watch... (Ctrl+C to stop)');
      await runFlutterInteractive(brArgs);
    } else {
      try {
        await runFlutter(brArgs, spinnerMsg: 'Running build_runner build...');
        s('✅ Code generation completed.');
      } catch (_) {
        e('❌ Code generation failed.');
      }
    }
  }
}

/// Runs `flutter doctor -v` to check the environment and dependencies.
class DoctorCommand extends Command {
  @override
  String get name => MenuOption.doctor.cliTitle;

  @override
  String get description => MenuOption.doctor.description;

  @override
  Future<void> run() async {
    await printExec(['doctor', '-v']);
    await runFlutterInteractive(['doctor', '-v']);
  }
}

/// Runs `flutter clean` to remove build artifacts and temporary files.
class CleanCommand extends Command {
  @override
  String get name => MenuOption.clean.cliTitle;

  @override
  String get description => MenuOption.clean.description;

  @override
  Future<void> run() async {
    await printExec(['clean']);
    try {
      await runFlutter(['clean'], spinnerMsg: 'Cleaning Flutter build...');
      s('✅ Flutter clean completed.');
    } catch (_) {
      e('❌ Flutter clean failed.');
    }
  }
}

/// Lists all connected devices via `flutter devices`.
class DeviceCommand extends Command {
  @override
  String get name => MenuOption.device.cliTitle;

  @override
  String get description => MenuOption.device.description;

  @override
  Future<void> run() async {
    await printExec(['devices']);
    await runFlutterInteractive(['devices']);
  }
}

/// Lists available emulators and launches the one the user selects.
class EmulatorCommand extends Command {
  @override
  String get name => MenuOption.emulator.cliTitle;

  @override
  String get description => MenuOption.emulator.description;

  @override
  Future<void> run() async {
    i('Fetching available emulators...');

    final exec = await flutterExec;
    final result = await Process.run(
      exec.first,
      [...exec.skip(1), 'emulators'],
      runInShell: true,
    );

    final lines = result.stdout.toString().split('\n');
    final emulatorLines = lines.where((l) => l.contains('•')).toList();

    if (emulatorLines.isEmpty) {
      w('No emulators found. Create one via Android Studio / Xcode.');
      return;
    }

    final emulators = emulatorLines.map((line) {
      final parts = line.trim().split('•');
      return (id: parts[0].trim(), label: line.trim());
    }).toList();

    final index = Select.withTheme(
      theme: cliTheme,
      prompt: 'Select emulator to launch:',
      options: emulators.map((e) => e.label).toList(),
    ).interact();

    final selectedId = emulators[index].id;
    await printExec(['emulators', '--launch', selectedId]);
    await runFlutterInteractive(['emulators', '--launch', selectedId]);
  }
}
