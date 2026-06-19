/// Menu option definitions for the dart_cli interactive interface.
///
/// Each [MenuOption] maps a human-readable [title] to a [cliTitle] used as the
/// command name in the `args` package runner, and a [description] shown in help
/// text.
enum MenuOption {
  /// Parent menu entry for Basic tools.
  basic(
    title: 'Basic command',
    description: 'Basic tools wrapper',
    cliTitle: 'basic',
  ),
  /// Runs the project on a connected device or emulator.
  run(
    title: 'Run',
    description: 'Run project on a connected device or emulator.',
    cliTitle: 'run',
  ),
  /// Builds the project with selected flavor(dev/uat/prod).
  build(
    title: 'Build',
    description: 'Build project with selected flavor(dev/uat/prod)',
    cliTitle: 'build',
  ),
  /// Generates model classes from database schema.
  gen(
    title: 'Generate model',
    description: 'Code generation model utilities.',
    cliTitle: 'gen',
  ),
  /// Checks environment and dependencies.
  doctor(
    title: 'Doctor',
    description: 'Check environment & dependencies.',
    cliTitle: 'doctor',
  ),
  /// Cleans the project and temporary files.
  clean(
    title: 'Clean',
    description: 'Clean project and temporary files.',
    cliTitle: 'clean',
  ),
  /// Lists connected devices.
  device(
    title: 'Device',
    description: 'List connected devices.',
    cliTitle: 'device',
  ),
  /// Lists or runs available emulators.
  emulator(
    title: 'Emulator',
    description: 'List or run available emulators.',
    cliTitle: 'emulator',
  ),

  /// Parent menu entry for Pub tools.
  pub(
    title: 'Pub',
    description: 'Pub tools wrapper (cache repair/clean).',
    cliTitle: 'pub',
  ),
  /// Gets package dependencies.
  get(
    title: 'Pub Get',
    description: 'Get package dependencies.',
    cliTitle: 'get',
  ),
  /// Cleans pub cache.
  cacheClean(
    title: 'Pub Cache Clean',
    description: 'Clean pub cache.',
    cliTitle: 'cache-clean',
  ),
  /// Repairs pub cache.
  cacheRepair(
    title: 'Pub Cache Repair',
    description: 'Repair pub cache.',
    cliTitle: 'cache-repair',
  ),

  /// Parent menu entry for Dart documentation tools.
  dartDoc(
    title: 'Dart doc',
    description: 'Dart documentation tools (generate & view).',
    cliTitle: 'dart-doc',
  ),
  /// Generates dart doc for the project at the current working directory.
  genDoc(
    title: 'Gen doc',
    description: 'Generate dart doc for the current project.',
    cliTitle: 'gen-doc',
  ),
  /// Serves the generated doc locally via python3 http.server on port 8080.
  viewDoc(
    title: 'View doc',
    description: 'Serve generated docs locally at http://localhost:8080.',
    cliTitle: 'view-doc',
  ),

  /// Parent menu entry for navigation.
  /// Returns to the previous menu level.
  back(
    title: 'Back',
    description: 'Back to previous menu level.',
    cliTitle: 'back',
  ),
  /// Exits the cli application.
  exit(
    title: 'Exit',
    description: 'Exit the cli application.',
    cliTitle: 'exit',
  );

  /// Human-readable label shown in the interactive menu.
  final String title;

  /// Short description shown in `--help` output.
  final String description;

  /// Command name used by the [args] runner (e.g. `dart_cli run`).
  final String cliTitle;

  const MenuOption({
    required this.title,
    required this.description,
    required this.cliTitle,
  });
}

/// A menu item pairing a [MenuOption] with an optional list of sub-options.
class MenuItem {
  /// The option this menu item represents.
  final MenuOption option;

  /// Sub-options shown when this item is selected, or null for leaf items.
  final List<MenuOption>? items;

  /// Creates a [MenuItem] for [option], optionally with nested [items].
  MenuItem({
    required this.option,
    this.items,
  });
}

/// Top-level menu structure displayed on the interactive main screen.
final List<MenuItem> firstLevelMenu = [
  MenuItem(
    option: MenuOption.basic,
    items: [
      MenuOption.run,
      MenuOption.build,
      MenuOption.gen,
      MenuOption.doctor,
      MenuOption.clean,
      MenuOption.device,
      MenuOption.emulator,
      MenuOption.back,
      MenuOption.exit,
    ],
  ),
  MenuItem(
    option: MenuOption.pub,
    items: [
      MenuOption.get,
      MenuOption.cacheClean,
      MenuOption.cacheRepair,
      MenuOption.back,
      MenuOption.exit,
    ],
  ),
  MenuItem(
    option: MenuOption.dartDoc,
    items: [
      MenuOption.genDoc,
      MenuOption.viewDoc,
      MenuOption.back,
      MenuOption.exit,
    ],
  ),
  MenuItem(option: MenuOption.exit),
];
