import 'dart:io';

import 'package:cli_config/cli_config.dart';

/// CLI configuration loaded from `cli_config.yaml` or `cli_config.local.yaml`.
///
/// Values are resolved in priority order:
/// 1. Environment variables
/// 2. `cli_config.local.yaml` (personal override, not committed)
/// 3. `cli_config.yaml` (team default)
/// 4. Hard-coded fallback defaults
class CliConfig {
  /// The default flavor used when no `--flavor` flag is passed.
  final String defaultFlavor;

  /// The default build type (e.g. `apk`, `appbundle`, `ipa`).
  final String defaultBuildType;

  /// The default build/run mode (e.g. `debug`, `release`).
  final String defaultMode;

  CliConfig._({
    required this.defaultFlavor,
    required this.defaultBuildType,
    required this.defaultMode,
  });

  /// Loads the CLI config, applying the priority order described in [CliConfig].
  static Future<CliConfig> load() async {
    // Personal override takes priority over the team default.
    final localFile   = File('cli_config.local.yaml');
    final defaultFile = File('cli_config.yaml');
    final configFile  = localFile.existsSync() ? localFile : defaultFile;

    final fileContents = configFile.existsSync()
        ? configFile.readAsStringSync()
        : null;

    final config = Config.fromConfigFileContents(
      environment: Platform.environment,
      fileContents: fileContents,
      fileSourceUri: configFile.uri,
    );

    return CliConfig._(
      defaultFlavor:    config.optionalString('default_flavor')     ?? 'dev',
      defaultBuildType: config.optionalString('default_build_type') ?? 'apk',
      defaultMode:      config.optionalString('default_mode')       ?? 'release',
    );
  }
}
