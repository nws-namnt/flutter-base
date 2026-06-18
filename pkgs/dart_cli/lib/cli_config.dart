import 'dart:io';

import 'package:cli_config/cli_config.dart';

class CliConfig {
  final String defaultFlavor;
  final String defaultBuildType;
  final String defaultMode;

  CliConfig._({
    required this.defaultFlavor,
    required this.defaultBuildType,
    required this.defaultMode,
  });

  /// Loads config with priority:
  /// ENV var > cli_config.local.yaml > cli_config.yaml > hardcoded default
  static Future<CliConfig> load() async {
    // Personal override takes priority over team default
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