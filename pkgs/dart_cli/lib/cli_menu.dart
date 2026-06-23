import 'package:args/command_runner.dart' show CommandRunner;
import 'package:interact_cli/interact_cli.dart';

import 'cli_models.dart';
import 'cli_utils.dart';
import 'cmd/index.dart';

/// Command runner that registers all available CLI sub-commands.
class Runner extends CommandRunner {
  /// Creates a [Runner] and registers all available commands.
  Runner() : super('dart_cli', 'A custom Flutter development CLI tool.') {
    addCommand(RunCommand());
    addCommand(BuildCommand());
    addCommand(GenCommand());
    addCommand(PigeonCommand());
    addCommand(DoctorCommand());
    addCommand(CleanCommand());
    addCommand(DeviceCommand());
    addCommand(EmulatorCommand());
    addCommand(GetCommand());
    addCommand(CacheCleanCommand());
    addCommand(CacheRepairCommand());
    addCommand(GenDocCommand());
    addCommand(ViewDocCommand());
  }
}

/// Runs the interactive menu loop until the user selects Exit.
Future<void> get menu async {
  final runner = Runner();

  while (true) {
    final option = _firstLevelMenu();

    if (option == MenuOption.exit) {
      t('👋 Goodbye!');
      return;
    }

    if (option == MenuOption.basic) {
      final basicCmd = _showSubMenu(option);
      if (basicCmd == MenuOption.back) continue;
      if (basicCmd == MenuOption.exit) { t('👋 Goodbye!'); break; }

      await runner.run([basicCmd.cliTitle]);
      print('\n----------------------------------------\n');
      print('🔄 Returning to menu...\n');
      continue;
    }

    if (option == MenuOption.pub) {
      final pubCmd = _showSubMenu(option);
      if (pubCmd == MenuOption.back) continue;
      if (pubCmd == MenuOption.exit) { t('👋 Goodbye!'); break; }

      await runner.run([pubCmd.cliTitle]);
      print('\n----------------------------------------\n');
      print('🔄 Returning to menu...\n');
      continue;
    }

    if (option == MenuOption.dartDoc) {
      final docCmd = _showSubMenu(option);
      if (docCmd == MenuOption.back) continue;
      if (docCmd == MenuOption.exit) { t('👋 Goodbye!'); break; }

      await runner.run([docCmd.cliTitle]);
      print('\n----------------------------------------\n');
      print('🔄 Returning to menu...\n');
      continue;
    }
  }
}

// ─── Level 1: Main menu ────────────────────────────────────────────────────

/// Displays the main menu and returns the selected [MenuOption].
MenuOption _firstLevelMenu() {
  final titles = firstLevelMenu.map((e) => e.option.title.firstLetterUppercase).toList();
  final index = Select.withTheme(
    theme: cliTheme,
    prompt: 'Choose main command:',
    options: titles,
  ).interact();
  i('You selected: ${firstLevelMenu[index].option.title}');
  return firstLevelMenu[index].option;
}

// ─── Level 2: Sub-menu ─────────────────────────────────────────────────────

/// Displays the sub-menu for [mainOption] and returns the selected [MenuOption].
MenuOption _showSubMenu(MenuOption mainOption) {
  final menuItem = firstLevelMenu.firstWhere((e) => e.option == mainOption);
  final options  = menuItem.items!.map((e) => e.title).toList();
  final index = Select.withTheme(
    theme: cliTheme,
    prompt: 'Choose an action:',
    options: options,
  ).interact();
  i('You selected: ${menuItem.items![index].title}');
  return menuItem.items![index];
}
