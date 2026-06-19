import 'package:args/command_runner.dart';
import 'package:dart_cli/cli_menu.dart' show menu, Runner;
import 'package:dart_cli/cli_utils.dart' show e;

/// Entry point for the dart_cli tool.
///
/// When called without arguments, launches the interactive menu. When called
/// with arguments, delegates directly to the [Runner] command runner.
Future<void> main(List<String> args) async {
  try {
    if (args.isEmpty) {
      await menu;
      return;
    }

    await Runner().run(args);
  } on UsageException catch (err1) {
    e(err1.toString());
  } catch (err2) {
    e('❌ Unexpected error: $err2');
  }
}
