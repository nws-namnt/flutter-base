import 'package:args/command_runner.dart';

import '../cli_models.dart' show MenuOption;
import '../cli_utils.dart';

class PubCommand extends Command {
  @override
  String get name => MenuOption.pub.cliTitle;

  @override
  String get description => MenuOption.pub.description;

  PubCommand() {
    addSubcommand(_GetCommand());
    addSubcommand(_CacheCleanCommand());
    addSubcommand(_CacheRepairCommand());
  }
}

class _GetCommand extends Command {
  @override
  String get name => MenuOption.get.cliTitle; // 'get'

  @override
  String get description => MenuOption.get.description;

  @override
  Future<void> run() async {
    await printExec(['pub', 'get']);
    await runFlutter(['pub', 'get'], spinnerMsg: 'Running pub get...');
    s('✅ Pub get completed.');
  }
}

class _CacheCleanCommand extends Command {
  @override
  String get name => MenuOption.cacheClean.cliTitle; // 'clean'

  @override
  String get description => MenuOption.cacheClean.description;

  @override
  Future<void> run() async {
    await printExec(['pub', 'cache', 'clean', '--force']);
    await runFlutter(['pub', 'cache', 'clean', '--force'], spinnerMsg: 'Cleaning pub cache...');
    s('✅ Pub cache cleaned.');
  }
}

class _CacheRepairCommand extends Command {
  @override
  String get name => MenuOption.cacheRepair.cliTitle; // 'repair'

  @override
  String get description => MenuOption.cacheRepair.description;

  @override
  Future<void> run() async {
    await printExec(['pub', 'cache', 'repair']);
    await runFlutter(['pub', 'cache', 'repair'], spinnerMsg: 'Repairing pub cache...');
    s('✅ Pub cache repaired.');
  }
}
