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
    addCommand(PubCommand());
  }
}

Future<void> get menu async {
  final runner = Runner();

  while(true) {
    final option = _firstLevelMenu();

    if(option == MenuOption.exit) {
      t('👋 Goodbye!');
      return;
    }

    if(option == MenuOption.basic) {
      final basicCmd = _showBasicMenu(option);
      if(basicCmd == MenuOption.back) {
        continue;
      }

      if(basicCmd == MenuOption.exit) {
        t('👋 Goodbye!');
        break;
      }

      await runner.run([basicCmd.cliTitle]);
      print("\n----------------------------------------\n");
      print("🔄 Returning to menu...\n");
      continue;
    }

    if (option == MenuOption.pub) {
      final pubCmd = _showBasicMenu(option);
      if (pubCmd == MenuOption.back) {
        continue;
      }

      if (pubCmd == MenuOption.exit) {
        t('👋 Goodbye!');
        break;
      }

      await runner.run([MenuOption.pub.cliTitle, pubCmd.cliTitle]);
      print("\n----------------------------------------\n");
      print("🔄 Returning to menu...\n");
      continue;
    }
  }
}

MenuOption _firstLevelMenu() {
  final optionsCli = firstLevelMenu.map((e) => e.option.title).toList();
  final option = Select.withTheme(
    theme: cliTheme,
    prompt: 'Choose main command: ',
    options: optionsCli.map((e) => e.firstLetterUppercase).toList(),
  ).interact();

  i('You selected: ${firstLevelMenu[option].option.title}');
  return firstLevelMenu[option].option;
}

MenuOption _showBasicMenu(MenuOption mainOption) {
  final selectedOption = firstLevelMenu.firstWhere((e) => e.option == mainOption);
  final options = selectedOption.items!.map((e) => e.title).toList();
  final option = Select.withTheme(
    theme: cliTheme,
    prompt: 'Choose an action:',
    options: options,
  ).interact();

  i('You selected: ${selectedOption.items![option].title}');
  return selectedOption.items![option];
}
