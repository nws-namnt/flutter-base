import 'package:args/command_runner.dart' show CommandRunner;
import 'package:interact_cli/interact_cli.dart';

import 'cli_models.dart';
import 'cli_utils.dart';
import 'cmd/index.dart';

class Runner extends CommandRunner {
  Runner() : super('dart_cli', 'A custom Flutter development CLI tool.') {
    addCommand(RunCommand());
    addCommand(BuildCommand());
    addCommand(GenCommand());
    addCommand(DoctorCommand());
    addCommand(CleanCommand());
    addCommand(DeviceCommand());
    addCommand(EmulatorCommand());
    addCommand(GetCommand());
    addCommand(CacheCleanCommand());
    addCommand(CacheRepairCommand());
  }
}

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
  }
}

// ─── Level 1: Main menu ────────────────────────────────────────────────────
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

// ─── Level 2: Sub submenu ────────────────────────────────────────────────
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

