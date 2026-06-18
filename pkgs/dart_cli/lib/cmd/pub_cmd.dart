import 'package:args/command_runner.dart';
import 'package:dart_cli/cli_models.dart' show MenuOption;

class PubCommand extends Command {
  @override
  String get name => MenuOption.pub.cliTitle;

  @override
  String get description => MenuOption.pub.description;

  PubCommand() {
    addSubcommand(_CacheRepairCommand());
    addSubcommand(_CacheCleanCommand());
  }
}

class _CacheRepairCommand extends Command {
  @override
  String get name => 'Cache-repair';

  @override
  String get description => 'Run pub cache repair.';

  @override
  void run() {
    print('Pub cache repair.');
  }
}

class _CacheCleanCommand extends Command {
  @override
  String get name => 'Cache-clean';

  @override
  String get description => 'Run pub cache clean.';

  @override
  void run() {
    print('Pub cache clean.');
  }
}
