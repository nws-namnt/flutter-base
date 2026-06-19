import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:interact_cli/interact_cli.dart' hide Spinner;

import '../cli_models.dart' show MenuOption;
import '../cli_utils.dart';

class GetCommand extends Command {
  @override
  String get name => MenuOption.get.cliTitle;

  @override
  String get description => MenuOption.get.description;

  @override
  Future<void> run() async {
    await printExec(['pub', 'get']);
    try {
      await runFlutter(['pub', 'get'], spinnerMsg: 'Running pub get...');
      s('✅ Pub get completed.');
    } catch (_) {
      e('❌ Pub get failed.');
    }
  }
}

class CacheCleanCommand extends Command {
  @override
  String get name => MenuOption.cacheClean.cliTitle;

  @override
  String get description => MenuOption.cacheClean.description;

  @override
  Future<void> run() async {
    // Step 1: List current global activations
    i('📦 Fetching global activated packages...');
    final globalPackages = await _getGlobalPackages();

    if (globalPackages.isEmpty) {
      w('⚠️  No global packages found.');
    } else {
      i('Global packages that will be re-activated after clean:');
      for (final pkg in globalPackages) {
        t('  • $pkg');
      }
    }

    print('');

    // Step 2: Confirm before cleaning
    final confirmed = Confirm.withTheme(
      theme: cliTheme,
      prompt: 'This will delete the entire pub cache. Continue?',
      defaultValue: false,
    ).interact();

    if (!confirmed) {
      w('⚠️  Cancelled.');
      return;
    }

    print('');

    // Step 3: Clean pub cache
    await printExec(['pub', 'cache', 'clean']);
    try {
      await runFlutter(['pub', 'cache', 'clean'], spinnerMsg: 'Cleaning pub cache...');
      s('✅ Pub cache cleaned.');
    } catch (_) {
      e('❌ Pub cache clean failed.');
      return;
    }

    if (globalPackages.isEmpty) return;

    print('');

    // Step 4: Re-activate all global packages
    i('♻️  Re-activating global packages...');
    final results = <String, bool>{};

    for (final pkg in globalPackages) {
      try {
        await runDart(
          ['pub', 'global', 'activate', pkg],
          spinnerMsg: 'Activating $pkg...',
        );
        results[pkg] = true;
      } catch (_) {
        results[pkg] = false;
      }
    }

    // Step 5: Print re-activation summary
    print('');
    i('Re-activation results:');
    for (final entry in results.entries) {
      if (entry.value) {
        s('  ✅ ${entry.key}');
      } else {
        e('  ❌ ${entry.key} — failed');
      }
    }

    final failed = results.values.where((v) => !v).length;
    print('');
    if (failed == 0) {
      s('✅ All packages re-activated successfully.');
    } else {
      w('⚠️  $failed package(s) failed to re-activate. Re-run manually if needed.');
    }
  }

  /// Returns list of package names from `dart pub global list`.
  Future<List<String>> _getGlobalPackages() async {
    final exec = await dartExec;
    final result = await Process.run(
      exec.first,
      [...exec.skip(1), 'pub', 'global', 'list'],
      runInShell: true,
    );

    if (result.exitCode != 0) return [];

    // Each line format: "package_name version"
    return result.stdout
        .toString()
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.split(' ').first)
        .toList();
  }
}

class CacheRepairCommand extends Command {
  @override
  String get name => MenuOption.cacheRepair.cliTitle;

  @override
  String get description => MenuOption.cacheRepair.description;

  @override
  Future<void> run() async {
    await printExec(['pub', 'cache', 'repair']);
    try {
      await runFlutter(['pub', 'cache', 'repair'], spinnerMsg: 'Repairing pub cache...');
      s('✅ Pub cache repaired.');
    } catch (_) {
      e('❌ Pub cache repair failed.');
    }
  }
}
