import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart' show Command;
import 'package:interact_cli/interact_cli.dart';

import '../cli_config.dart';
import '../cli_models.dart' show MenuOption;
import '../cli_utils.dart';

class RunCommand extends Command {
  @override
  String get description => MenuOption.run.description;

  @override
  String get name => MenuOption.run.cliTitle;

  RunCommand() {
    argParser.addOption(
      'flavor',
      abbr: 'f',
      allowed: ['dev', 'uat', 'prod'],
      defaultsTo: 'dev',
      help: 'Run flavor / scheme.',
    );
    argParser.addOption(
      'mode',
      abbr: 'm',
      allowed: ['debug', 'profile', 'release'],
      defaultsTo: 'debug',
      help: 'Run mode.',
    );
    argParser.addOption(
      'device',
      abbr: 'd',
      help: 'Device ID to run on.',
    );
  }

  @override
  Future<void> run() async {
    final hasArgs = argResults!.arguments.isNotEmpty;
    final cliConfig = await CliConfig.load();

    final flavor = hasArgs
        ? argResults!['flavor'] as String
        : _promptSelect('Select flavor:', ['dev', 'uat', 'prod'],
            defaultValue: cliConfig.defaultFlavor);

    final mode = hasArgs
        ? argResults!['mode'] as String
        : _promptSelect('Select run mode:', ['debug', 'profile', 'release'],
            defaultValue: cliConfig.defaultMode);

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

  String _promptSelect(String prompt, List<String> options, {String? defaultValue}) {
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

    final List<dynamic> raw = jsonDecode(result.stdout as String);
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

class BuildCommand extends Command {
  @override
  String get description => MenuOption.build.description;

  @override
  String get name => MenuOption.build.cliTitle;

  BuildCommand() {
    argParser.addOption(
      'flavor',
      abbr: 'f',
      allowed: ['dev', 'uat', 'prod'],
      defaultsTo: 'dev',
      help: 'Build flavor / scheme.',
    );
    argParser.addOption(
      'type',
      abbr: 't',
      allowed: ['apk', 'appbundle', 'ipa'],
      defaultsTo: 'apk',
      help: 'Build output type.',
    );
    argParser.addOption(
      'mode',
      abbr: 'm',
      allowed: ['debug', 'profile', 'release'],
      defaultsTo: 'release',
      help: 'Build mode.',
    );
  }

  @override
  Future<void> run() async {
    final hasArgs = argResults!.arguments.isNotEmpty;
    final cliConfig = await CliConfig.load();

    final flavor = hasArgs
        ? argResults!['flavor'] as String
        : _promptSelect('Select flavor:', ['dev', 'uat', 'prod'],
            defaultValue: cliConfig.defaultFlavor);

    final type = hasArgs
        ? argResults!['type'] as String
        : _promptSelect('Select build type:', ['apk', 'appbundle', 'ipa'],
            defaultValue: cliConfig.defaultBuildType);

    final mode = hasArgs
        ? argResults!['mode'] as String
        : _promptSelect('Select build mode:', ['debug', 'profile', 'release'],
            defaultValue: cliConfig.defaultMode);

    final args = ['build', type, '--flavor', flavor, '--$mode'];

    await printExec(args);
    await runFlutter(args, spinnerMsg: 'Building $type ($flavor / $mode)...');

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

  String _promptSelect(String prompt, List<String> options, {String? defaultValue}) {
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

  String _outputPath(String type, String flavor, String mode) {
    final cwd = Directory.current.path;
    return switch (type) {
      'apk'       => '$cwd/build/app/outputs/flutter-apk',
      'appbundle' => '$cwd/build/app/outputs/bundle/$flavor${_capitalize(mode)}',
      'ipa'       => '$cwd/build/ios/ipa',
      _           => '$cwd/build',
    };
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Future<void> _copyToClipboard(String text) async {
    final process = await Process.start('pbcopy', [], runInShell: true);
    process.stdin.write(text);
    await process.stdin.close();
    await process.exitCode;
  }

  String _hyperlink(String url, String label) {
    final uri = url.startsWith('http') ? url : 'file://$url';
    return '\x1B]8;;$uri\x07$label\x1B]8;;\x07';
  }
}

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
        : _promptSelect('Select gen mode:', ['build', 'watch']);

    final brArgs = ['pub', 'run', 'build_runner', mode, '--delete-conflicting-outputs'];
    await printExec(brArgs);

    if (mode == 'watch') {
      i('Starting build_runner watch... (Ctrl+C to stop)');
      await runFlutterInteractive(brArgs);
    } else {
      await runFlutter(brArgs, spinnerMsg: 'Running build_runner build...');
      s('✅ Code generation completed.');
    }
  }

  String _promptSelect(String prompt, List<String> options) {
    final index = Select.withTheme(theme: cliTheme, prompt: prompt, options: options).interact();
    return options[index];
  }
}

class DoctorCommand extends Command {
  @override
  String get name => MenuOption.doctor.cliTitle;

  @override
  String get description => MenuOption.doctor.description;

  @override
  Future<void> run() async {
    printExec(['doctor', '-v']);
    await runFlutterInteractive(['doctor', '-v']);
  }
}

class CleanCommand extends Command {
  @override
  String get name => MenuOption.clean.cliTitle;

  @override
  String get description => MenuOption.clean.description;

  @override
  Future<void> run() async {
    printExec(['clean']);
    await runFlutter(['clean'], spinnerMsg: 'Cleaning Flutter build...');
    s('✅ Flutter clean completed.');
  }
}

class DeviceCommand extends Command {
  @override
  String get name => MenuOption.device.cliTitle;

  @override
  String get description => MenuOption.device.description;

  @override
  Future<void> run() async {
    printExec(['devices']);
    await runFlutterInteractive(['devices']);
  }
}

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
    printExec(['emulators', '--launch', selectedId]);
    await runFlutterInteractive(['emulators', '--launch', selectedId]);
  }
}
