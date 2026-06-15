# flutter_base

Flutter production boilerplate — BLoC/Cubit, GoRouter, Hive, Dio/Retrofit, Firebase (FlutterFire).

Based on [itachi1611/flutter_temp_bloc](https://github.com/itachi1611/flutter_temp_bloc).

## Installation

```sh
git clone <repo-url>
cd flutter_base
flutter pub get
flutter run --flavor dev
```

## Pub packages

| Package | Usage |
|---|---|
| [intl](https://pub.dev/packages/intl) | Multi language* |
| [intl_utils](https://pub.dev/packages/intl_utils) | Multi language utils* |
| [bloc](https://pub.dev/packages/bloc) | State management* |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc) | State management* |
| [equatable](https://pub.dev/packages/equatable) | Value equality for Cubit states* |
| [go_router](https://pub.dev/packages/go_router) | Declarative navigation |
| [hive](https://pub.dev/packages/hive) | Platform-independent local storage |
| [hive_generator](https://pub.dev/packages/hive_generator) | Hive adapter code generation |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Key-value persistent storage |
| [get_storage](https://pub.dev/packages/get_storage) | Fast key-value storage |
| [connectivity_plus](https://pub.dev/packages/connectivity_plus) | Network connectivity status |
| [dio](https://pub.dev/packages/dio) | HTTP client |
| [retrofit](https://pub.dev/packages/retrofit) | Type-safe REST API client |
| [retrofit_generator](https://pub.dev/packages/retrofit_generator) | Retrofit code generation |
| [pretty_dio_logger](https://pub.dev/packages/pretty_dio_logger) | Dio request/response logging |
| [google_fonts](https://pub.dev/packages/google_fonts) | Google Fonts (Lato) |
| [path_provider](https://pub.dev/packages/path_provider) | File system paths |
| [permission_handler](https://pub.dev/packages/permission_handler) | Runtime permission management |
| [url_launcher](https://pub.dev/packages/url_launcher) | Open URLs in browser |
| [another_flushbar](https://pub.dev/packages/another_flushbar) | In-app notification bar |
| [gap](https://pub.dev/packages/gap) | Spacing widget |
| [animations](https://pub.dev/packages/animations) | Pre-built page transitions |
| [lottie](https://pub.dev/packages/lottie) | Lottie animation player |
| [device_info_plus](https://pub.dev/packages/device_info_plus) | Device information |
| [package_info_plus](https://pub.dev/packages/package_info_plus) | App version and build info |
| [json_annotation](https://pub.dev/packages/json_annotation) | JSON serialization annotations |
| [json_serializable](https://pub.dev/packages/json_serializable) | JSON serialization code generation |
| [timezone](https://pub.dev/packages/timezone) | Timezone support |
| [logger](https://pub.dev/packages/logger) | Structured console logging |
| [build_runner](https://pub.dev/packages/build_runner) | Code generation runner |
| [flutter_lints](https://pub.dev/packages/flutter_lints) | Lint rules |

> \* Recommended to keep regardless of project

### Firebase (pending — configure via FlutterFire)

| Package | Usage |
|---|---|
| [firebase_core](https://pub.dev/packages/firebase_core) | Firebase core |
| [firebase_messaging](https://pub.dev/packages/firebase_messaging) | Push notifications (FCM) |
| [firebase_analytics](https://pub.dev/packages/firebase_analytics) | Analytics |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Local notification display |

## Flavors

The app supports three build flavors: `dev`, `uat`, `prod`. Always pass `--flavor` when running or building:

```sh
flutter run --flavor dev
flutter build apk --flavor prod --release
```

## Firebase setup

```sh
dart pub global activate flutterfire_cli
flutterfire configure
```

## Changing package name

```sh
# 1. Uncomment change_app_package_name in pubspec.yaml
# 2. Run:
flutter pub run change_app_package_name:main com.new.package.name
# 3. Re-comment the package
```

## iOS setup (Mac ARM)

```sh
sudo arch -x86_64 gem install ffi
sudo arch -x86_64 pod install
```
