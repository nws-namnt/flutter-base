/// Menu option definitions for the dart_cli interactive interface.
///
/// Each [MenuOption] maps a human-readable [title] to a [cliTitle] used as the
/// command name in the `args` package runner, and a [description] shown in help
/// text.
enum MenuOption {
  basic(
    title: 'Basic command',
    description: 'Basic tools wrapper',
    cliTitle: 'basic',
  ),
  run(
    title: 'Run',
    description: 'Run project on a connected device or emulator.',
    cliTitle: 'run',
  ),
  build(
    title: 'Build',
    description: 'Build project with selected flavor(dev/uat/prod)',
    cliTitle: 'build',
  ),
  gen(
    title: 'Generate model',
    description: 'Code generation model utilities.',
    cliTitle: 'gen',
  ),
  doctor(
    title: 'Doctor',
    description: 'Check environment & dependencies.',
    cliTitle: 'doctor',
  ),
  clean(
    title: 'Clean',
    description: 'Clean project and temporary files.',
    cliTitle: 'clean',
  ),
  device(
    title: 'Device',
    description: 'List connected devices.',
    cliTitle: 'device',
  ),
  emulator(
    title: 'Emulator',
    description: 'List or run available emulators.',
    cliTitle: 'emulator',
  ),
  pub(
    title: 'Pub',
    description: 'Pub tools wrapper (cache repair/clean).',
    cliTitle: 'pub',
  ),
  get(
    title: 'Pub Get',
    description: 'Get package dependencies.',
    cliTitle: 'get',
  ),
  cacheClean(
    title: 'Pub Cache Clean',
    description: 'Clean pub cache.',
    cliTitle: 'cache-clean',
  ),
  cacheRepair(
    title: 'Pub Cache Repair',
    description: 'Repair pub cache.',
    cliTitle: 'cache-repair',
  ),
  back(
    title: 'Back',
    description: 'Back to previous menu level.',
    cliTitle: 'back',
  ),
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
  MenuItem(option: MenuOption.exit),
];
