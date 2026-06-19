/// A custom Flutter development CLI tool.
///
/// Provides an interactive menu and direct command execution for common
/// Flutter workflows: run, build, code generation, pub cache management,
/// and device/emulator control.
///
/// ## Usage
///
/// Launch the interactive menu:
/// ```sh
/// dart run bin/cli_runner.dart
/// ```
///
/// Or run a command directly:
/// ```sh
/// dart run bin/cli_runner.dart build --flavor dev --type apk
/// ```
///
/// ## Key types
///
/// - [Runner] — registers and dispatches all sub-commands.
/// - [MenuOption] — enum of all available commands.
/// - [CliConfig] — loads per-user defaults from `cli_config.yaml`.
/// - [promptSelect] — shared interactive prompt helper.
// ignore: unnecessary_library_name
library dart_cli;

export 'cli_config.dart';
export 'cli_menu.dart';
export 'cli_models.dart';
export 'cli_utils.dart';
export 'cmd/index.dart';
