import 'package:args/command_runner.dart';

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
    await printExec(['pub', 'cache', 'clean']);
    try {
      await runFlutter(['pub', 'cache', 'clean'], spinnerMsg: 'Cleaning pub cache...');
      s('✅ Pub cache cleaned.');
    } catch (_) {
      e('❌ Pub cache clean failed.');
    }
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
