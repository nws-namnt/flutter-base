# dart_cli — Custom Flutter Development CLI

An interactive command-line tool for Flutter development workflows. Wraps common `flutter` and `dart pub` commands behind a navigable menu, with FVM (Flutter Version Manager) detection, colored output, and animated spinners.

---

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Menu Structure](#menu-structure)
- [Commands](#commands)
  - [Basic Commands](#basic-commands)
  - [Pub Commands](#pub-commands)
  - [Dart Doc Commands](#dart-doc-commands)
- [Configuration](#configuration)
- [FVM Support](#fvm-support)
- [Project Structure](#project-structure)

---

## Requirements

- Dart SDK `^3.8.1`
- Flutter SDK (or FVM)

---

## Installation

### Clone the repository

```bash
cd pkgs/dart_cli
dart pub get
```

### Option 1 — Global activation (recommended for development)

Activate the package globally so `dart_cli` is available from any directory:

```bash
dart pub global activate --source path .
```

Run the CLI:

```bash
dart_cli           # opens interactive menu
dart_cli <command> # runs a specific command directly
```

> Make sure `~/.pub-cache/bin` is on your `$PATH`. Add this to your shell profile if needed:
> ```bash
> export PATH="$PATH:$HOME/.pub-cache/bin"
> ```

### Option 2 — Compile to binary (recommended for distribution)

Produces a self-contained executable with fast startup and no Dart SDK dependency:

```bash
dart compile exe bin/cli_runner.dart -o dart_cli
```

Run directly:

```bash
./dart_cli           # interactive menu
./dart_cli <command> # direct command
```

Move to `$PATH` for global access:

```bash
sudo mv dart_cli /usr/local/bin/
```

### Option 3 — Shell script wrapper (recommended for team setup)

Create a `run.sh` in the package root:

```bash
#!/bin/bash
# run.sh — wrapper for dart_cli
# Automatically uses FVM if available, falls back to system dart.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v fvm &> /dev/null; then
    fvm dart run "$SCRIPT_DIR/bin/cli_runner.dart" "$@"
else
    dart run "$SCRIPT_DIR/bin/cli_runner.dart" "$@"
fi
```

Make it executable:

```bash
chmod +x run.sh
```

Run:

```bash
./run.sh           # interactive menu
./run.sh <command> # direct command
./run.sh --help
```

> This option requires the Dart SDK (or FVM) to be installed but avoids the global activation step. Useful for sharing within a team via the repo — everyone just runs `./run.sh`.

---

## Usage

### Interactive menu

Running without arguments opens the full interactive menu:

```bash
dart_cli
```

Navigate with arrow keys, confirm with Enter.

### Direct command invocation

Commands can also be called directly without going through the menu:

```bash
dart_cli run --flavor dev --mode debug --device <device_id>
dart_cli build --flavor prod --type apk --mode release
dart_cli gen
dart_cli doctor
dart_cli clean
dart_cli device
dart_cli emulator
dart_cli get
dart_cli cache-clean
dart_cli cache-repair
dart_cli gen-doc
dart_cli view-doc
```

### Help

```bash
dart_cli --help
dart_cli <command> --help
```

---

## Menu Structure

```
Main menu
├── Basic command
│   ├── Run
│   ├── Build
│   ├── Generate model
│   ├── Doctor
│   ├── Clean
│   ├── Device
│   ├── Emulator
│   ├── Back
│   └── Exit
├── Pub
│   ├── Pub Get
│   ├── Pub Cache Clean
│   ├── Pub Cache Repair
│   ├── Back
│   └── Exit
├── Dart doc
│   ├── Gen doc
│   ├── View doc
│   ├── Back
│   └── Exit
└── Exit
```

---

## Commands

### Basic Commands

#### `run`

Runs the Flutter app on a connected device or emulator.

**Interactive mode** — prompts for flavor, run mode, and device selection:

```bash
dart_cli run
```

**Direct mode** — pass all options as flags:

```bash
dart_cli run --flavor dev --mode debug --device <device_id>
```

| Option     | Abbr | Values                        | Default      |
|------------|------|-------------------------------|--------------|
| `--flavor` | `-f` | `dev`, `uat`, `prod`          | `dev`        |
| `--mode`   | `-m` | `debug`, `profile`, `release` | `debug`      |
| `--device` | `-d` | any device id                 | _(prompted)_ |

When run interactively, the device list is fetched live via `flutter devices --machine` and presented as a selector. The default flavor and mode are read from `cli_config.yaml` if present.

---

#### `build`

Builds the Flutter app for a target flavor and output type.

```bash
dart_cli build
dart_cli build --flavor prod --type apk --mode release
```

| Option     | Abbr | Values                        | Default   |
|------------|------|-------------------------------|-----------|
| `--flavor` | `-f` | `dev`, `uat`, `prod`          | `dev`     |
| `--type`   | `-t` | `apk`, `appbundle`, `ipa`     | `apk`     |
| `--mode`   | `-m` | `debug`, `profile`, `release` | `release` |

After a successful build, the output path is printed and automatically:
- copied to the clipboard (macOS only, via `pbcopy`)
- opened in Finder

Output paths by type:

| Type        | Path                                       |
|-------------|--------------------------------------------|
| `apk`       | `build/app/outputs/flutter-apk/`           |
| `appbundle` | `build/app/outputs/bundle/<flavor><Mode>/` |
| `ipa`       | `build/ios/ipa/`                           |

---

#### `gen`

Runs `build_runner` for code generation (Retrofit, JSON serializable, Hive adapters).

```bash
dart_cli gen          # interactive mode — prompts for build or watch
dart_cli gen build    # one-time build
dart_cli gen watch    # watch mode (Ctrl+C to stop)
```

Executes: `flutter pub run build_runner <mode> --delete-conflicting-outputs`

---

#### `doctor`

Runs `flutter doctor -v` interactively (stdout shared with terminal).

```bash
dart_cli doctor
```

---

#### `clean`

Cleans Flutter build artifacts.

```bash
dart_cli clean
```

Executes: `flutter clean`

---

#### `device`

Lists all connected devices in real time.

```bash
dart_cli device
```

Executes: `flutter devices`

---

#### `emulator`

Fetches available emulators and lets you select one to launch.

```bash
dart_cli emulator
```

Parses `flutter emulators` output, presents a selector, then runs `flutter emulators --launch <id>`.

---

### Pub Commands

#### `get`

Fetches package dependencies.

```bash
dart_cli get
```

Executes: `flutter pub get`

---

#### `cache-clean`

Deletes the local pub cache.

```bash
dart_cli cache-clean
```

Executes: `flutter pub cache clean`

---

#### `cache-repair`

Reinstall all packages in the pub cache from their sources.

```bash
dart_cli cache-repair
```

Executes: `flutter pub cache repair`

---

### Dart Doc Commands

#### `gen-doc`

Generates API documentation for the project at the current working directory.

```bash
dart_cli gen-doc
```

Resolves the Dart executable via FVM when available, then executes:

```
fvm dart doc .   # with FVM
dart doc .       # without FVM
```

Output is written to `doc/api/`. Run this before `view-doc`.

---

#### `view-doc`

Serves the generated API documentation locally via a Python HTTP server.

```bash
dart_cli view-doc
```

Starts `python3 -m http.server 8080` inside `doc/api/` and opens it for browsing at:

```
http://localhost:8080
```

Press **Ctrl+C** to stop the server and return to the menu. Requires `doc/api/` to exist — run `gen-doc` first if it does not.

---

## Configuration

The CLI reads from a YAML config file to set default values for flavor, build type, and run mode. This avoids having to re-select the same options every session.

**File lookup order** (first found wins):

1. `cli_config.local.yaml` — personal overrides, not committed to git
2. `cli_config.yaml` — team-shared defaults

**Example `cli_config.yaml`:**

```yaml
default_flavor: dev
default_build_type: apk
default_mode: debug
```

**Example `cli_config.local.yaml`** (personal override):

```yaml
default_flavor: uat
default_build_type: appbundle
default_mode: release
```

Add `cli_config.local.yaml` to `.gitignore` to keep personal overrides local.

Supported keys:

| Key                  | Values                        | Hardcoded default |
|----------------------|-------------------------------|-------------------|
| `default_flavor`     | `dev`, `uat`, `prod`          | `dev`             |
| `default_build_type` | `apk`, `appbundle`, `ipa`     | `apk`             |
| `default_mode`       | `debug`, `profile`, `release` | `release`         |

---

## FVM Support

The CLI automatically detects FVM at startup by checking `which fvm`. If FVM is found, all Flutter commands are prefixed with `fvm` (e.g. `fvm flutter pub get`). The detection result is cached for the entire session — `which fvm` runs at most once.

The resolved executable is printed before each command runs:

```
Execute: fvm flutter pub get
Execute: flutter doctor -v
```

No configuration is required. If FVM is not installed, the CLI falls back to calling `flutter` directly.

---

## Project Structure

```
pkgs/dart_cli/
├── bin/
│   └── cli_runner.dart        # Entry point — menu or direct dispatch
├── lib/
│   ├── cli_config.dart        # Config loader (cli_config.yaml / env vars)
│   ├── cli_menu.dart          # Runner (CommandRunner) + interactive menu
│   ├── cli_models.dart        # MenuOption enum + firstLevelMenu data
│   ├── cli_utils.dart         # FVM detection, runFlutter, printExec, logging
│   └── cmd/
│       ├── index.dart         # Barrel export
│       ├── basic_cmd.dart     # RunCommand, BuildCommand, GenCommand, DoctorCommand,
│       │                      # CleanCommand, DeviceCommand, EmulatorCommand
│       ├── pub_cmd.dart       # GetCommand, CacheCleanCommand, CacheRepairCommand
│       └── dart_doc_cmd.dart  # GenDocCommand, ViewDocCommand
└── pubspec.yaml
```
