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

| Package                                                           | Usage                                    |
|-------------------------------------------------------------------|------------------------------------------|
| [intl](https://pub.dev/packages/intl)                             | Multi language*                          |
| [intl_utils](https://pub.dev/packages/intl_utils)                 | Multi language utils*                    |
| [bloc](https://pub.dev/packages/bloc)                             | State management*                        |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc)             | State management*                        |
| [equatable](https://pub.dev/packages/equatable)                   | Value equality for Cubit states*         |
| [go_router](https://pub.dev/packages/go_router)                   | Declarative navigation                   |
| [hive](https://pub.dev/packages/hive)                             | Platform-independent local storage       |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Key-value persistent storage             |
| [get_storage](https://pub.dev/packages/get_storage)               | Fast key-value storage                   |
| [connectivity_plus](https://pub.dev/packages/connectivity_plus)   | Network connectivity status              |
| [dio](https://pub.dev/packages/dio)                               | HTTP client                              |
| [retrofit](https://pub.dev/packages/retrofit)                     | Type-safe REST API client                |
| [retrofit_generator](https://pub.dev/packages/retrofit_generator) | Retrofit code generation                 |
| [pretty_dio_logger](https://pub.dev/packages/pretty_dio_logger)   | Dio request/response logging             |
| [google_fonts](https://pub.dev/packages/google_fonts)             | Google Fonts (Lato)                      |
| [path_provider](https://pub.dev/packages/path_provider)           | File system paths                        |
| [permission_handler](https://pub.dev/packages/permission_handler) | Runtime permission management            |
| [url_launcher](https://pub.dev/packages/url_launcher)             | Open URLs in browser                     |
| [another_flushbar](https://pub.dev/packages/another_flushbar)     | In-app notification bar                  |
| [gap](https://pub.dev/packages/gap)                               | Spacing widget                           |
| [animations](https://pub.dev/packages/animations)                 | Pre-built page transitions               |
| [lottie](https://pub.dev/packages/lottie)                         | Lottie animation player                  |
| [device_info_plus](https://pub.dev/packages/device_info_plus)     | Device information                       |
| [package_info_plus](https://pub.dev/packages/package_info_plus)   | App version and build info               |
| [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)         | Load `.env` config per flavor at runtime |
| [json_annotation](https://pub.dev/packages/json_annotation)       | JSON serialization annotations           |
| [json_serializable](https://pub.dev/packages/json_serializable)   | JSON serialization code generation       |
| [timezone](https://pub.dev/packages/timezone)                     | Timezone support                         |
| [logger](https://pub.dev/packages/logger)                         | Structured console logging               |
| [cached_network_image](https://pub.dev/packages/cached_network_image) | Cached network image widget (see `CachedImageWidget`) |
| [flutter_cache_manager](https://pub.dev/packages/flutter_cache_manager) | File cache backing `cached_network_image` |
| [cached_network_image_platform_interface](https://pub.dev/packages/cached_network_image_platform_interface) | Web render options for `cached_network_image` |
| [build_runner](https://pub.dev/packages/build_runner)             | Code generation runner                   |
| [flutter_lints](https://pub.dev/packages/flutter_lints)           | Lint rules                               |

> \* Recommended to keep regardless of project

### Firebase (FlutterFire)

| Package                                                                             | Usage                                             |
|-------------------------------------------------------------------------------------|---------------------------------------------------|
| [firebase_core](https://pub.dev/packages/firebase_core)                             | Firebase core — required by all Firebase packages |
| [firebase_messaging](https://pub.dev/packages/firebase_messaging)                   | Push notifications (FCM)                          |
| [firebase_remote_config](https://pub.dev/packages/firebase_remote_config)           | Remote feature flags and config                   |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Display FCM messages as local notifications       |

## Flavors

The app supports three build flavors: `dev`, `uat`, `prod`. Always pass `--flavor` when running or building:

```sh
flutter run --flavor dev
flutter build apk --flavor prod --release
```

## Firebase setup

This project uses three separate Firebase projects, one per flavor (`dev` / `uat` / `prod`).

### Step 1 — Create Firebase projects

Go to [Firebase Console](https://console.firebase.google.com) and create three projects:

| Flavor | Suggested project name |
|--------|------------------------|
| dev    | `flutter-base-dev`     |
| uat    | `flutter-base-uat`     |
| prod   | `flutter-base-prod`    |

For **each project**, register two apps:
- **Android** — package name: `com.fox.base.flutter` (or your renamed package)
- **iOS** — bundle ID: `com.fox.base.flutter`

> Enable **Cloud Messaging** and **Remote Config** in each project.

### Step 2 — Install Firebase CLI and log in

```sh
# Install Firebase CLI (once)
npm install -g firebase-tools

# Log in
firebase login
```

### Step 3 — Install FlutterFire CLI

```sh
# With FVM
fvm dart pub global activate flutterfire_cli

# Without FVM
dart pub global activate flutterfire_cli
```

### Step 4 — Configure each flavor

Run the following command three times, replacing `<project-id>` with the actual Firebase project ID:

```sh
# dev
fvm dart pub global run flutterfire_cli:flutterfire configure \
  --project=flutter-base-dev \
  --out=lib/firebase/dev/firebase_options.dart \
  --platforms=android,ios

# uat
fvm dart pub global run flutterfire_cli:flutterfire configure \
  --project=flutter-base-uat \
  --out=lib/firebase/uat/firebase_options.dart \
  --platforms=android,ios

# prod
fvm dart pub global run flutterfire_cli:flutterfire configure \
  --project=flutter-base-prod \
  --out=lib/firebase/prod/firebase_options.dart \
  --platforms=android,ios
```

> Without FVM, replace `fvm dart pub global run flutterfire_cli:flutterfire` with `flutterfire`.

Each run generates:
- `lib/firebase/{flavor}/firebase_options.dart`
- `android/app/google-services.json` ← **copy manually** (see step 5)
- `ios/Runner/GoogleService-Info.plist` ← **copy manually** (see step 5)

> `firebase_options.dart` is committed to git. `google-services.json` and `GoogleService-Info.plist` are gitignored — **do not commit**.

### Step 5 — Place native config files per flavor

**Android** — copy each file into the corresponding flavor src directory:

```
android/app/src/dev/google-services.json
android/app/src/uat/google-services.json
android/app/src/prod/google-services.json
```

**iOS** — copy into a flavor subdirectory (create the directory if it does not exist):

```
ios/config/dev/GoogleService-Info.plist
ios/config/uat/GoogleService-Info.plist
ios/config/prod/GoogleService-Info.plist
```

Then add a Run Script build phase in Xcode to copy the correct file for the active build configuration:

```sh
# Xcode → Build Phases → Run Script
cp "${PROJECT_DIR}/config/${FLUTTER_BUILD_MODE}/GoogleService-Info.plist" \
   "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
```

### Step 6 — Android flavor config in build.gradle

Add to `android/app/build.gradle.kts`:

```kotlin
android {
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        create("uat") {
            dimension = "env"
            applicationIdSuffix = ".uat"
            versionNameSuffix = "-uat"
        }
        create("prod") {
            dimension = "env"
        }
    }
}
```

### Step 7 — Add Google Services plugin (Android)

`android/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

`android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

### Verify

```sh
flutter pub get
flutter run --flavor dev
```

## Changing package name

```sh
# 1. Uncomment change_app_package_name in pubspec.yaml
# 2. Run:
flutter pub run change_app_package_name:main com.new.package.name
# 3. Re-comment the package
```

## iOS setup

This project uses Swift Package Manager — no CocoaPods required.

```sh
# Regenerate Flutter SPM config after adding/removing packages
fvm flutter build ios --config-only
```
